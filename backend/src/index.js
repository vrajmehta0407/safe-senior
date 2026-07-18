'use strict';

// Load environment variables FIRST before any other module reads process.env
require('dotenv').config();

const express = require('express');
const cors    = require('cors');
const fs      = require('fs');
const path    = require('path');

const pool           = require('./db/pool');
const authRoutes     = require('./routes/auth');
const guardianRoutes = require('./routes/guardian');
const scamRoutes     = require('./routes/scamPatterns');

const app  = express();
const PORT = process.env.PORT || 3000;

// ─── CORS ─────────────────────────────────────────────────────────────────────

const corsOptions = process.env.NODE_ENV === 'production'
  ? {
      // In production lock down to known origins.
      // Update ALLOWED_ORIGINS in Railway env vars as needed.
      origin: (origin, callback) => {
        const allowed = (process.env.ALLOWED_ORIGINS || '')
          .split(',')
          .map((o) => o.trim())
          .filter(Boolean);

        // Allow requests with no origin (mobile apps, curl, Postman)
        if (!origin || allowed.length === 0 || allowed.includes(origin)) {
          callback(null, true);
        } else {
          callback(new Error(`CORS: origin ${origin} not allowed`));
        }
      },
      credentials: true,
    }
  : { origin: '*', credentials: false };   // dev: allow all

app.use(cors(corsOptions));

// ─── Body parsing ─────────────────────────────────────────────────────────────

app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Trust the proxy (Railway, Heroku, nginx) so req.ip is the real client IP
app.set('trust proxy', 1);

// ─── Health check ─────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.status(200).json({
    status:    'ok',
    timestamp: new Date().toISOString(),
    uptime:    Math.floor(process.uptime()),
  });
});

// ─── Routes ───────────────────────────────────────────────────────────────────

app.use('/auth',          authRoutes);
app.use('/guardian',      guardianRoutes);
app.use('/scam-patterns', scamRoutes);

// 404 handler for unmatched routes
app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found.' });
});

// ─── Global error handler ─────────────────────────────────────────────────────

// Must have 4 parameters to be recognised as Express error middleware
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, _next) => {
  console.error('[error]', err.message);
  if (process.env.NODE_ENV !== 'production') {
    console.error(err.stack);
  }

  // CORS errors
  if (err.message && err.message.startsWith('CORS:')) {
    return res.status(403).json({ success: false, message: err.message });
  }

  // Postgres FK / constraint errors
  if (err.code === '23503') {
    return res.status(400).json({ success: false, message: 'Referenced record does not exist.' });
  }
  if (err.code === '23505') {
    return res.status(409).json({ success: false, message: 'Duplicate entry — record already exists.' });
  }

  res.status(500).json({
    success: false,
    message: process.env.NODE_ENV === 'production'
      ? 'Internal server error.'
      : err.message,
  });
});

// ─── Schema initialisation ────────────────────────────────────────────────────

async function initSchema() {
  const schemaPath = path.join(__dirname, 'db', 'schema.sql');
  const sql = fs.readFileSync(schemaPath, 'utf8');

  const client = await pool.connect();
  try {
    await client.query(sql);
    console.log('[db] Schema initialised successfully.');
  } catch (err) {
    console.error('[db] Schema initialisation failed:', err.message);
    // Non-fatal — tables may already exist. Only crash on connection failures.
    if (err.code === 'ECONNREFUSED' || err.code === '3D000') {
      throw err;
    }
  } finally {
    client.release();
  }
}

// ─── Startup ──────────────────────────────────────────────────────────────────

async function start() {
  try {
    // Verify DB connectivity
    await pool.query('SELECT 1');
    console.log('[db] Connected to PostgreSQL.');

    // Run schema SQL
    await initSchema();

    // Start HTTP server
    app.listen(PORT, () => {
      console.log(`[server] Safe Senior backend running on port ${PORT} (${process.env.NODE_ENV || 'development'})`);
    });
  } catch (err) {
    console.error('[startup] Fatal error:', err.message);
    process.exit(1);
  }
}

start();

module.exports = app; // exported for testing
