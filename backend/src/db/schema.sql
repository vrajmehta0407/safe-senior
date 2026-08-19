-- Safe Senior Database Schema
-- Run this on first startup to initialize all tables

-- NOTE: guardians must be created before users because users references it.
-- However, users must exist before guardians can reference users.
-- We solve this with a deferred/nullable FK on users.guardian_id.

CREATE TABLE IF NOT EXISTS guardians (
  id           SERIAL PRIMARY KEY,
  user_id      INTEGER NOT NULL UNIQUE,  -- UNIQUE required for ON CONFLICT (user_id) upsert in guardian.js
  name         VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  relationship VARCHAR(100),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(255) NOT NULL,
  phone_number  VARCHAR(20) UNIQUE NOT NULL,
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  guardian_id   INTEGER REFERENCES guardians(id) ON DELETE SET NULL
);

-- Add the FK from guardians → users now that users exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'guardians_user_id_fkey'
      AND table_name = 'guardians'
  ) THEN
    ALTER TABLE guardians
      ADD CONSTRAINT guardians_user_id_fkey
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS otps (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER REFERENCES users(id) ON DELETE CASCADE,
  code_hash   VARCHAR(255) NOT NULL,
  purpose     VARCHAR(20) NOT NULL CHECK (purpose IN ('login', '2fa', 'reset')),
  expires_at  TIMESTAMPTZ NOT NULL,
  attempts    INTEGER DEFAULT 0,
  verified_at TIMESTAMPTZ,
  ip_address  VARCHAR(45),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS scam_reports (
  id             SERIAL PRIMARY KEY,
  user_id        INTEGER REFERENCES users(id) ON DELETE SET NULL,
  type           VARCHAR(10) NOT NULL CHECK (type IN ('sms', 'call')),
  sender         VARCHAR(100) NOT NULL,
  classification VARCHAR(20) NOT NULL CHECK (classification IN ('safe', 'suspicious', 'high-risk')),
  body_preview   TEXT,
  timestamp      TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_users_phone         ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_email         ON users(email);
CREATE INDEX IF NOT EXISTS idx_otps_user_purpose   ON otps(user_id, purpose);
CREATE INDEX IF NOT EXISTS idx_scam_reports_sender ON scam_reports(sender);
CREATE INDEX IF NOT EXISTS idx_guardians_user_id   ON guardians(user_id);

-- ── Admin Foundation (Phase 1) ────────────────────────────────────────────────
-- admins table is completely separate from users — a bug in user-facing code
-- can never grant admin rights.

CREATE TABLE IF NOT EXISTS admins (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(255) NOT NULL,
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role          VARCHAR(20)  NOT NULL DEFAULT 'support'
                  CHECK (role IN ('superadmin', 'support')),
  is_active     BOOLEAN      NOT NULL DEFAULT true,
  totp_secret   VARCHAR(255),          -- null until TOTP enrolled
  totp_enabled  BOOLEAN      NOT NULL DEFAULT false,
  last_login_at TIMESTAMPTZ,
  created_at    TIMESTAMPTZ  DEFAULT NOW()
);

-- Every admin action that changes data must write a row here
CREATE TABLE IF NOT EXISTS admin_audit_log (
  id          SERIAL PRIMARY KEY,
  admin_id    INTEGER      REFERENCES admins(id) ON DELETE SET NULL,
  action      VARCHAR(100) NOT NULL,
  target_type VARCHAR(50),
  target_id   INTEGER,
  metadata    JSONB,
  ip_address  VARCHAR(45),
  created_at  TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_audit_admin      ON admin_audit_log(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_action_time ON admin_audit_log(action, created_at DESC);

-- Add is_suspended to users (admin can suspend/reactivate accounts)
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN NOT NULL DEFAULT false;

-- ── Phase 3: Scam Patterns in DB ─────────────────────────────────────────────
-- Replaces the static bundled JSON so admins can update rules without app releases.

CREATE TABLE IF NOT EXISTS scam_patterns (
  id           SERIAL PRIMARY KEY,
  pattern      TEXT         NOT NULL,
  type         VARCHAR(10)  NOT NULL CHECK (type IN ('sms', 'call', 'both')),
  severity     VARCHAR(20)  NOT NULL CHECK (severity IN ('suspicious', 'high-risk')),
  category     VARCHAR(50),
  language     VARCHAR(10)  NOT NULL DEFAULT 'en',
  is_active    BOOLEAN      NOT NULL DEFAULT true,
  source       VARCHAR(20)  NOT NULL DEFAULT 'bundled' CHECK (source IN ('bundled', 'community', 'admin')),
  created_by   INTEGER      REFERENCES admins(id) ON DELETE SET NULL,
  created_at   TIMESTAMPTZ  DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scam_patterns_active   ON scam_patterns(is_active, type);
CREATE INDEX IF NOT EXISTS idx_scam_patterns_severity ON scam_patterns(severity);

-- Multi-guardian join table
CREATE TABLE IF NOT EXISTS user_guardians (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  guardian_id INTEGER NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
  is_primary  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, guardian_id)
);
CREATE INDEX IF NOT EXISTS idx_user_guardians_user ON user_guardians(user_id);

-- Trusted senders allowlist
CREATE TABLE IF NOT EXISTS trusted_senders (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sender     VARCHAR(100) NOT NULL,
  label      VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, sender)
);
CREATE INDEX IF NOT EXISTS idx_trusted_senders_user ON trusted_senders(user_id);

