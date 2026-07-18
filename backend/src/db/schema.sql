-- Safe Senior Database Schema
-- Run this on first startup to initialize all tables

-- NOTE: guardians must be created before users because users references it.
-- However, users must exist before guardians can reference users.
-- We solve this with a deferred/nullable FK on users.guardian_id.

CREATE TABLE IF NOT EXISTS guardians (
  id           SERIAL PRIMARY KEY,
  user_id      INTEGER NOT NULL,  -- FK added below after users table
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
