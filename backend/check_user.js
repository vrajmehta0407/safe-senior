'use strict';
const bcrypt = require('bcryptjs');
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function main() {
  // Show all users
  const all = await pool.query('SELECT id, name, phone_number, email, password_hash, is_suspended FROM users ORDER BY id');
  console.log('\n=== ALL USERS ===');
  for (const u of all.rows) {
    console.log(`id=${u.id} | phone=${u.phone_number} | email=${u.email} | suspended=${u.is_suspended}`);
    console.log(`  hash=${u.password_hash}`);
    
    // Test the PIN against the hash
    const match040705 = await bcrypt.compare('040705', u.password_hash);
    console.log(`  bcrypt.compare('040705', hash) => ${match040705}`);
  }

  await pool.end();
}

main().catch(e => { console.error('Error:', e.message); process.exit(1); });
