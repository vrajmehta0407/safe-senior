'use strict';

// Load environment variables FIRST before any other module reads process.env
require('dotenv').config();

const express = require('express');
const cors    = require('cors');
const fs      = require('fs');
const path    = require('path');

const pool            = require('./db/pool');
const authRoutes      = require('./routes/auth');
const guardianRoutes  = require('./routes/guardian');
const scamRoutes      = require('./routes/scamPatterns');
const adminAuthRoutes = require('./routes/adminAuth');
const adminRoutes     = require('./routes/admin');

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

app.use('/api/auth',          authRoutes);
app.use('/api/guardian',      guardianRoutes);
app.use('/api/scam-patterns', scamRoutes);
app.use('/api/trusted-senders', require('./routes/trustedSenders'));
app.use('/api/guardians',       require('./routes/guardians'));

// ─── Admin Routes (secret prefix, never guessable) ───────────────────────────

const ADMIN_PREFIX = process.env.ADMIN_ROUTE_PREFIX || '/api/ops-4e9f2c1a';

// Optional: IP allowlist middleware for the admin prefix
function adminIpGuard(req, res, next) {
  const allowlist = (process.env.ADMIN_IP_ALLOWLIST || '')
    .split(',')
    .map((ip) => ip.trim())
    .filter(Boolean);

  // If no allowlist is configured, skip this check
  if (allowlist.length === 0) return next();

  const clientIp = req.ip;
  if (!allowlist.includes(clientIp)) {
    // Return 404 (not 403) — don't reveal the route exists
    return res.status(404).json({ success: false, message: 'Route not found.' });
  }
  return next();
}

// Admin-only CORS — only the admin panel origin can call these routes
const adminCorsOrigin = process.env.ADMIN_ALLOWED_ORIGIN;
const adminCors = cors(
  adminCorsOrigin
    ? { origin: adminCorsOrigin, credentials: true }
    : corsOptions  // fall back to global CORS in dev (no ADMIN_ALLOWED_ORIGIN set)
);

app.use(ADMIN_PREFIX,            adminIpGuard);
app.use(ADMIN_PREFIX,            adminCors);
app.use(`${ADMIN_PREFIX}/auth`,  adminAuthRoutes);
app.use(ADMIN_PREFIX,            adminRoutes);

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

  // Database / service connectivity errors — downgrade to 503-style message but
  // return 200 with success:false so mobile clients can parse cleanly
  if (err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND' || err.code === 'ETIMEDOUT') {
    return res.status(200).json({
      success: false,
      message: 'A required service is temporarily unavailable. Please try again shortly.',
    });
  }

  // All other errors — return 200 with success:false and a readable message so the
  // Flutter Dio client never sees a 5xx that triggers an unhandled exception
  const statusCode = (res.headersSent || !err.status) ? 200 : (err.status < 500 ? err.status : 200);
  res.status(statusCode).json({
    success: false,
    message: process.env.NODE_ENV === 'production'
      ? 'Something went wrong. Please try again.'
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

if (process.env.NODE_ENV !== 'test') {
  start();
}

module.exports = app; // exported for testing
