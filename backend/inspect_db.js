'use strict';
require('dotenv').config();
const pool = require('./src/db/pool');

async function inspect() {
  try {
    console.log('--- DATABASE INSPECTOR ---');
    console.log('Database URL:', process.env.DATABASE_URL.replace(/:[^:@]+@/, ':****@'));
    
    // Check connection
    const res = await pool.query('SELECT current_database(), version()');
    console.log('Connected to DB:', res.rows[0].current_database);
    console.log('PostgreSQL Version:', res.rows[0].version.split('\n')[0]);
    console.log('\n--- TABLES ---');

    const tablesRes = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);

    for (const row of tablesRes.rows) {
      const t = row.table_name;
      const countRes = await pool.query(`SELECT COUNT(*) FROM "${t}"`);
      const count = countRes.rows[0].count;
      console.log(`Table: ${t} (${count} rows)`);

      // Sample data
      const sampleRes = await pool.query(`SELECT * FROM "${t}" LIMIT 5`);
      if (sampleRes.rows.length > 0) {
        // Redact password_hash
        const cleaned = sampleRes.rows.map(r => {
          const copy = { ...r };
          if (copy.password_hash) copy.password_hash = '[REDACTED BCRYPT HASH]';
          if (copy.code_hash) copy.code_hash = '[REDACTED HASH]';
          return copy;
        });
        console.dir(cleaned, { depth: null, colors: false });
      }
      console.log('-----------------------------------');
    }
  } catch (err) {
    console.error('Database query error:', err.message);
  } finally {
    await pool.end();
  }
}

inspect();
