#!/usr/bin/env node
'use strict';

/**
 * One-off CLI script to seed the first admin account.
 * NEVER expose this as an HTTP endpoint.
 *
 * Usage:
 *   node src/scripts/create-admin.js
 *
 * Or with env vars (for CI / non-interactive):
 *   ADMIN_NAME="Vraj" ADMIN_EMAIL="you@example.com" \
 *   ADMIN_PASSWORD="strongpassword" ADMIN_ROLE="superadmin" \
 *   node src/scripts/create-admin.js
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

const readline = require('readline');
const bcrypt   = require('bcryptjs');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

// ─── Helpers ─────────────────────────────────────────────────────────────────

function prompt(rl, question) {
  return new Promise((resolve) => rl.question(question, resolve));
}

function promptHidden(question) {
  return new Promise((resolve) => {
    process.stdout.write(question);
    const stdin = process.stdin;
    stdin.setRawMode(true);
    stdin.resume();
    stdin.setEncoding('utf8');

    let input = '';
    stdin.on('data', function handler(char) {
      if (char === '\n' || char === '\r' || char === '\u0004') {
        stdin.setRawMode(false);
        stdin.pause();
        stdin.removeListener('data', handler);
        process.stdout.write('\n');
        resolve(input);
      } else if (char === '\u0003') {
        process.exit();
      } else if (char === '\u007f') {
        input = input.slice(0, -1);
      } else {
        input += char;
      }
    });
  });
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('\n╔══════════════════════════════════════════╗');
  console.log('║   Safe Senior — Create Admin Account     ║');
  console.log('╚══════════════════════════════════════════╝\n');

  // Allow env-var override for non-interactive/CI use
  let name     = process.env.ADMIN_NAME;
  let email    = process.env.ADMIN_EMAIL;
  let password = process.env.ADMIN_PASSWORD;
  let role     = process.env.ADMIN_ROLE || 'superadmin';

  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  if (!name)  name  = await prompt(rl, 'Admin name:  ');
  if (!email) email = await prompt(rl, 'Admin email: ');
  rl.close();

  if (!password) {
    password = await promptHidden('Password (hidden): ');
  }

  // Validate
  name  = name.trim();
  email = email.toLowerCase().trim();

  if (!name || !email || !password) {
    console.error('\n✗ name, email, and password are all required.');
    process.exit(1);
  }
  if (password.length < 12) {
    console.error('\n✗ Password must be at least 12 characters for admin accounts.');
    process.exit(1);
  }
  if (!['superadmin', 'support'].includes(role)) {
    console.error('\n✗ ADMIN_ROLE must be "superadmin" or "support".');
    process.exit(1);
  }

  console.log(`\nCreating ${role} account for ${email}...`);

  // Check DB connection
  await pool.query('SELECT 1');

  // Check duplicate
  const existing = await pool.query('SELECT id FROM admins WHERE email = $1', [email]);
  if (existing.rowCount > 0) {
    console.error(`\n✗ An admin with email "${email}" already exists.`);
    process.exit(1);
  }

  // Hash password (cost 12 for admin — higher than user cost of 10)
  const password_hash = await bcrypt.hash(password, 12);

  const result = await pool.query(
    `INSERT INTO admins (name, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id, name, email, role, created_at`,
    [name, email, password_hash, role]
  );

  const admin = result.rows[0];

  console.log('\n✓ Admin account created successfully!');
  console.log('─────────────────────────────────────');
  console.log(`  ID:      ${admin.id}`);
  console.log(`  Name:    ${admin.name}`);
  console.log(`  Email:   ${admin.email}`);
  console.log(`  Role:    ${admin.role}`);
  console.log(`  Created: ${admin.created_at}`);
  console.log('─────────────────────────────────────');
  console.log('\nNext steps:');
  console.log('  1. Set ADMIN_JWT_SECRET in your .env file');
  console.log('  2. Set ADMIN_ROUTE_PREFIX to your secret path');
  console.log('  3. Start the backend and POST to <prefix>/auth/login\n');

  await pool.end();
}

main().catch((err) => {
  console.error('\n✗ Fatal error:', err.message);
  process.exit(1);
});
