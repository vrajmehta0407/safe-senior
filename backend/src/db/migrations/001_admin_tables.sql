-- Safe Senior — Admin Foundation Migration
-- Run once against your Postgres database:
--   psql $DATABASE_URL -f src/db/migrations/001_admin_tables.sql

-- ── 1. admins table (completely separate from users) ─────────────────────────
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

-- ── 2. Audit log — every admin action writes here ────────────────────────────
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

CREATE INDEX IF NOT EXISTS idx_admin_audit_admin
  ON admin_audit_log(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_action_time
  ON admin_audit_log(action, created_at DESC);

-- ── 3. Add is_suspended to users (used by admin suspend/reactivate) ──────────
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN NOT NULL DEFAULT false;
