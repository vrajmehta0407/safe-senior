'use strict';
const bcrypt = require('bcryptjs');
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function main() {
  const phone = '8866565480';
  const pin   = '040705';
  const name  = 'Vraj Mehta';
  const email = 'vrajmehta_user@safesenior.local';

  const hash = await bcrypt.hash(pin, 10);

  // Check if user already exists (raw or normalised +91...)
  const existing = await pool.query(
    'SELECT id, phone_number FROM users WHERE phone_number = $1 OR phone_number = $2',
    [phone, '+91' + phone]
  );

  if (existing.rowCount > 0) {
    const row = existing.rows[0];
    await pool.query('UPDATE users SET password_hash = $1 WHERE id = $2', [hash, row.id]);
    console.log('✅ User PIN updated!  id=' + row.id + '  phone=' + row.phone_number);
  } else {
    const result = await pool.query(
      'INSERT INTO users (name, phone_number, email, password_hash) VALUES ($1, $2, $3, $4) RETURNING id, name, phone_number, email',
      [name, phone, email, hash]
    );
    const u = result.rows[0];
    console.log('✅ User created!  id=' + u.id + '  phone=' + u.phone_number + '  email=' + u.email);
  }

  await pool.end();
}

main().catch(e => { console.error('❌ Error:', e.message); process.exit(1); });
