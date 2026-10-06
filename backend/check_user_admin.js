require('dotenv').config();
const pool = require('./src/db/pool');
const bcrypt = require('bcryptjs');

async function check() {
  const users = await pool.query(
    "SELECT id, name, email, phone_number, created_at FROM users WHERE phone_number LIKE '%8866565480%' OR phone_number LIKE '%88866565480%'"
  );
  console.log('Target Users:', JSON.stringify(users.rows, null, 2));

  const allUsers = await pool.query("SELECT id, name, email, phone_number FROM users");
  console.log('All Users:', JSON.stringify(allUsers.rows, null, 2));

  const admins = await pool.query("SELECT id, name, email, role FROM admins");
  console.log('Admins:', JSON.stringify(admins.rows, null, 2));

  process.exit(0);
}

check().catch(err => {
  console.error(err);
  process.exit(1);
});
