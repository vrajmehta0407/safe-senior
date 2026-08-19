-- Migration 003: Trusted senders allowlist + multi-guardian join table

-- Trusted senders: users can mark senders as safe so detection skips them
CREATE TABLE IF NOT EXISTS trusted_senders (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sender      VARCHAR(100) NOT NULL,   -- normalized to uppercase
  label       VARCHAR(200),            -- friendly name shown in UI
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, sender)
);
CREATE INDEX IF NOT EXISTS idx_trusted_senders_user ON trusted_senders(user_id);

-- Multi-guardian join table (supplements existing guardians table)
CREATE TABLE IF NOT EXISTS user_guardians (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  guardian_id INTEGER NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
  is_primary  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, guardian_id)
);
CREATE INDEX IF NOT EXISTS idx_user_guardians_user ON user_guardians(user_id);
