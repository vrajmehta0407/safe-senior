'use strict';
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function run() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_guardians (
      id          SERIAL PRIMARY KEY,
      user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      guardian_id INTEGER NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
      is_primary  BOOLEAN NOT NULL DEFAULT false,
      created_at  TIMESTAMPTZ DEFAULT NOW(),
      UNIQUE (user_id, guardian_id)
    )
  `);
  console.log('✓ user_guardians table ready');

  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_user_guardians_user ON user_guardians(user_id)
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS trusted_senders (
      id         SERIAL PRIMARY KEY,
      user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      sender     VARCHAR(100) NOT NULL,
      label      VARCHAR(255),
      created_at TIMESTAMPTZ DEFAULT NOW(),
      UNIQUE (user_id, sender)
    )
  `);
  console.log('✓ trusted_senders table ready');

  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_trusted_senders_user ON trusted_senders(user_id)
  `);

  console.log('Migration complete.');
  await pool.end();
}

run().catch(e => {
  console.error('Migration failed:', e.message);
  process.exit(1);
});
