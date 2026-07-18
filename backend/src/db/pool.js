'use strict';

const { Pool } = require('pg');

/**
 * Singleton pg Pool instance.
 * Reads DATABASE_URL from environment (set via dotenv before this is imported).
 */
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // Railway / Heroku-style Postgres requires SSL in production
  ssl: process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: false }
    : false,
  // Sensible defaults
  max: 10,               // max pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on('error', (err) => {
  console.error('[pool] Unexpected error on idle client:', err.message);
});

module.exports = pool;
