'use strict';
const bcrypt = require('bcryptjs');
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

function normalisePhone(raw) {
  const stripped = String(raw || '').replace(/[\s\-().]/g, '');
  if (stripped.startsWith('+')) return stripped;
  if (stripped.startsWith('91') && stripped.length === 12) return '+' + stripped;
  if (stripped.startsWith('0') && stripped.length === 11) return '+91' + stripped.slice(1);
  if (stripped.length === 10) return '+91' + stripped;
  return '+' + stripped;
}

async function cleanupDb() {
  console.log('Starting DB Cleanup and User Consolidation...');

  // Hash the desired PIN: 040705
  const pinHash = await bcrypt.hash('040705', 10);

  // 1. Move all foreign keys pointing to user 2 to user 3
  await pool.query('UPDATE guardians SET user_id = 3 WHERE user_id = 2').catch(e => console.log('guardians update:', e.message));
  await pool.query('UPDATE scam_reports SET user_id = 3 WHERE user_id = 2').catch(e => console.log('scam_reports update:', e.message));
  await pool.query('UPDATE otps SET user_id = 3 WHERE user_id = 2').catch(e => console.log('otps update:', e.message));

  // 2. Delete user 2 (duplicate of 8866565480)
  await pool.query('DELETE FROM users WHERE id = 2').catch(e => console.log('delete user 2:', e.message));

  // 3. Update user 3 with canonical data and PIN 040705
  await pool.query(`
    UPDATE users
    SET name = 'Vraj Mehta',
        phone_number = '+918866565480',
        email = 'vrajmehta934@gmail.com',
        password_hash = $1,
        is_suspended = false
    WHERE id = 3
  `, [pinHash]);

  // Also update user 1 to have PIN 040705 just in case
  await pool.query(`
    UPDATE users
    SET password_hash = $1,
        is_suspended = false
    WHERE id = 1
  `, [pinHash]);

  // 4. Ensure all existing phone numbers in users are normalized
  const allUsers = await pool.query('SELECT id, phone_number FROM users');
  for (const u of allUsers.rows) {
    const norm = normalisePhone(u.phone_number);
    if (norm !== u.phone_number) {
      await pool.query('UPDATE users SET phone_number = $1 WHERE id = $2', [norm, u.id]);
    }
  }

  // 5. Verify the state
  const finalUsers = await pool.query('SELECT id, name, phone_number, email, is_suspended FROM users ORDER BY id');
  console.log('✅ Final Users in DB:', finalUsers.rows);

  const testMatch = await bcrypt.compare('040705', pinHash);
  console.log('✅ PIN 040705 bcrypt verification test:', testMatch);

  await pool.end();
}

cleanupDb().catch(err => {
  console.error('❌ Error during cleanup:', err);
  process.exit(1);
});
