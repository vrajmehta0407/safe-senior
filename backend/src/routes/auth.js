'use strict';

/**
 * Authentication routes — email OTP + Android SMS Gateway OTP.
 *
 * POST /auth/signup
 * POST /auth/login
 * POST /auth/otp/request   — sends OTP to user's registered email AND SMS
 * POST /auth/otp/verify    — verifies OTP by email or phone_number
 * POST /auth/2fa/verify    — requires auth header
 * POST /auth/reset-password
 * GET  /auth/me
 */

const express = require('express');
const bcrypt  = require('bcryptjs');
const jwt     = require('jsonwebtoken');
const crypto  = require('crypto');

const pool              = require('../db/pool');
const { sendEmailOtp }    = require('../services/emailOtp');
const { sendSmsOtp, normalisePhone } = require('../services/androidSmsGateway');
const { otpRateLimiter, authRateLimiter } = require('../middleware/rateLimit');
const authMiddleware    = require('../middleware/auth');

const router = express.Router();

// ── Bootstrap temp_otps table (for pre-registration OTPs — no user_id FK) ───
// This runs once when the module loads. Safe to call on every restart.
pool.query(`
  CREATE TABLE IF NOT EXISTS temp_otps (
    id         SERIAL PRIMARY KEY,
    identifier TEXT        NOT NULL,          -- phone or email
    code_hash  TEXT        NOT NULL,
    purpose    TEXT        NOT NULL DEFAULT 'verification',
    expires_at TIMESTAMPTZ NOT NULL,
    attempts   INT         NOT NULL DEFAULT 0,
    verified   BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  )
`).catch(err => console.error('[auth] temp_otps table init failed:', err.message));

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Cryptographically-uniform 6-digit OTP */
function generateOtp() {
  return String(crypto.randomInt(100000, 999999));
}

/** JWT valid for 7 days */
function signToken(userId) {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
}

/** Strip sensitive fields before sending user data */
function safeUser(u) {
  const { password_hash, ...rest } = u;
  return rest;
}

/**
 * Look up a user by email OR phone_number (with E.164 normalization fallback).
 * Returns the full row or null.
 */
async function findUser(identifier) {
  const id = (identifier || '').trim();
  if (!id) return null;
  if (id.includes('@')) {
    const result = await pool.query(
      `SELECT id, name, phone_number, email, password_hash, created_at, guardian_id
       FROM users
       WHERE email = $1
       LIMIT 1`,
      [id.toLowerCase()]
    );
    return result.rows[0] || null;
  }
  const normPhone = normalisePhone(id);
  const result = await pool.query(
    `SELECT id, name, phone_number, email, password_hash, created_at, guardian_id
     FROM users
     WHERE phone_number = $1 OR phone_number = $2
     LIMIT 1`,
    [id, normPhone]
  );
  return result.rows[0] || null;
}

// ─── POST /auth/email-otp/request ───────────────────────────────────────────
// Dispatches real Email OTP via Gmail SMTP to registering users
router.post('/email-otp/request', async (req, res, next) => {
  try {
    const { email } = req.body;
    const cleanEmail = (email || '').trim().toLowerCase();

    if (!cleanEmail || !cleanEmail.includes('@')) {
      return res.status(400).json({ success: false, message: 'A valid email address is required.' });
    }

    const otp = generateOtp();
    const codeHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 min

    // Invalidate any old pending OTPs for this identifier
    await pool.query(
      `UPDATE temp_otps SET verified = TRUE WHERE identifier = $1 AND verified = FALSE`,
      [cleanEmail]
    );
    // Persist to DB so it survives restarts
    await pool.query(
      `INSERT INTO temp_otps (identifier, code_hash, purpose, expires_at) VALUES ($1, $2, 'verification', $3)`,
      [cleanEmail, codeHash, expiresAt]
    );

    console.log(`[email-otp/request] Generated OTP for ${cleanEmail}`);

    try {
      await sendEmailOtp(cleanEmail, otp, 'verification');
      console.log(`[email-otp/request] Email OTP dispatched to ${cleanEmail}`);
    } catch (emailErr) {
      console.error('[email-otp/request] Email dispatch error:', emailErr.message);
      // Still respond success — OTP is in DB; user can resend
    }

    return res.status(200).json({
      success: true,
      message: `Verification code sent to ${cleanEmail}.`,
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/email-otp/verify ────────────────────────────────────────────
router.post('/email-otp/verify', async (req, res, next) => {
  try {
    const { email, code } = req.body;
    const cleanEmail = (email || '').trim().toLowerCase();
    const cleanCode = (code || '').trim();

    if (!cleanEmail || !cleanCode) {
      return res.status(400).json({ success: false, message: 'email and code are required.' });
    }

    const result = await pool.query(
      `SELECT id, code_hash, expires_at, attempts FROM temp_otps
       WHERE identifier = $1 AND purpose = 'verification' AND verified = FALSE
       ORDER BY created_at DESC LIMIT 1`,
      [cleanEmail]
    );

    if (result.rowCount === 0) {
      return res.status(400).json({ success: false, message: 'No pending verification code found for this email. Please request a new code.' });
    }

    const row = result.rows[0];
    if (new Date() > new Date(row.expires_at)) {
      await pool.query('UPDATE temp_otps SET verified = TRUE WHERE id = $1', [row.id]);
      return res.status(400).json({ success: false, message: 'Verification code has expired. Please request a new code.' });
    }
    if (row.attempts >= 5) {
      await pool.query('UPDATE temp_otps SET verified = TRUE WHERE id = $1', [row.id]);
      return res.status(429).json({ success: false, message: 'Maximum attempts exceeded. Please request a new code.' });
    }

    const match = await bcrypt.compare(cleanCode, row.code_hash);
    if (!match) {
      await pool.query('UPDATE temp_otps SET attempts = attempts + 1 WHERE id = $1', [row.id]);
      return res.status(400).json({ success: false, message: 'Incorrect verification code. Please check your email inbox.' });
    }

    await pool.query('UPDATE temp_otps SET verified = TRUE WHERE id = $1', [row.id]);
    console.log(`[email-otp/verify] Successfully verified email ${cleanEmail}`);
    return res.status(200).json({ success: true, verified: true });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/phone-otp/request ───────────────────────────────────────────
// Dispatches real SMS OTP via androidSmsGateway; also emails if email is provided
router.post('/phone-otp/request', async (req, res, next) => {
  try {
    const { phone_number, email } = req.body;
    const rawPhone = (phone_number || '').trim();

    if (!rawPhone) {
      return res.status(400).json({ success: false, message: 'phone_number is required.' });
    }

    const phone = normalisePhone(rawPhone);
    const otp = generateOtp();
    const codeHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 min

    // Invalidate old pending OTPs for this phone (raw or normalized)
    await pool.query(
      `UPDATE temp_otps SET verified = TRUE WHERE (identifier = $1 OR identifier = $2) AND verified = FALSE`,
      [phone, rawPhone]
    );
    // Persist to DB — survives backend restarts
    await pool.query(
      `INSERT INTO temp_otps (identifier, code_hash, purpose, expires_at) VALUES ($1, $2, 'verification', $3)`,
      [phone, codeHash, expiresAt]
    );

    console.log(`[phone-otp/request] Generated OTP for ${phone} (raw: ${rawPhone})`);

    // Dispatch real SMS
    let smsSuccess = false;
    try {
      await sendSmsOtp(phone, otp, 'verification');
      smsSuccess = true;
      console.log(`[phone-otp/request] SMS OTP dispatched to ${phone}`);
    } catch (smsErr) {
      console.error('[phone-otp/request] SMS dispatch error:', smsErr.message);
    }

    // Also dispatch email if provided (best-effort, non-blocking)
    if (email && email.includes('@')) {
      sendEmailOtp(email.trim().toLowerCase(), otp, 'verification').catch(e => {
        console.error('[phone-otp/request] Email fallback dispatch error:', e.message);
      });
    }

    return res.status(200).json({
      success: true,
      message: smsSuccess
        ? `Verification code sent via SMS to ${phone}.`
        : email
          ? `SMS unavailable — code sent to ${email}.`
          : `Verification code generated. SMS delivery may be delayed.`,
      smsSent: smsSuccess,
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/phone-otp/verify ────────────────────────────────────────────
router.post('/phone-otp/verify', async (req, res, next) => {
  try {
    const { phone_number, code } = req.body;
    const rawPhone = (phone_number || '').trim();
    const cleanCode = (code || '').trim();

    if (!rawPhone || !cleanCode) {
      return res.status(400).json({ success: false, message: 'phone_number and code are required.' });
    }

    const phone = normalisePhone(rawPhone);
    const result = await pool.query(
      `SELECT id, code_hash, expires_at, attempts FROM temp_otps
       WHERE (identifier = $1 OR identifier = $2) AND purpose = 'verification' AND verified = FALSE
       ORDER BY created_at DESC LIMIT 1`,
      [phone, rawPhone]
    );

    if (result.rowCount === 0) {
      return res.status(400).json({ success: false, message: 'No pending verification code found for this number. Please request a new code.' });
    }

    const row = result.rows[0];
    if (new Date() > new Date(row.expires_at)) {
      await pool.query('UPDATE temp_otps SET verified = TRUE WHERE id = $1', [row.id]);
      return res.status(400).json({ success: false, message: 'Verification code has expired. Please request a new code.' });
    }
    if (row.attempts >= 5) {
      await pool.query('UPDATE temp_otps SET verified = TRUE WHERE id = $1', [row.id]);
      return res.status(429).json({ success: false, message: 'Maximum attempts exceeded. Please request a new code.' });
    }

    const match = await bcrypt.compare(cleanCode, row.code_hash);
    if (!match) {
      await pool.query('UPDATE temp_otps SET attempts = attempts + 1 WHERE id = $1', [row.id]);
      return res.status(400).json({ success: false, message: 'Incorrect verification code. Please check your SMS.' });
    }

    await pool.query('UPDATE temp_otps SET verified = TRUE WHERE id = $1', [row.id]);
    console.log(`[phone-otp/verify] Successfully verified phone ${phone}`);
    return res.status(200).json({ success: true, verified: true });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/signup ────────────────────────────────────────────────────────

router.post('/signup', async (req, res, next) => {
  try {
    const { name, phone_number, email, password } = req.body;

    if (!name || !phone_number || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'name, phone_number, email, and password are required.',
      });
    }
    if (password.length < 4) {
      return res.status(400).json({
        success: false,
        message: 'PIN/Password must be at least 4 digits.',
      });
    }

    // Duplicate check
    const existing = await pool.query(
      'SELECT id FROM users WHERE phone_number = $1 OR email = $2 LIMIT 1',
      [phone_number.trim(), email.toLowerCase().trim()]
    );
    if (existing.rowCount > 0) {
      return res.status(409).json({
        success: false,
        message: 'An account with this phone number or email already exists.',
      });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const result = await pool.query(
      `INSERT INTO users (name, phone_number, email, password_hash)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, phone_number, email, created_at`,
      [name.trim(), phone_number.trim(), email.toLowerCase().trim(), password_hash]
    );

    const user  = result.rows[0];
    const token = signToken(user.id);

    return res.status(201).json({ success: true, token, user: safeUser(user) });
  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({
        success: false,
        message: 'An account with this phone number or email already exists.',
      });
    }
    next(err);
  }
});

// ─── POST /auth/login ─────────────────────────────────────────────────────────

router.post('/login', authRateLimiter, async (req, res, next) => {
  try {
    const { phone_or_email, password } = req.body;

    if (!phone_or_email || !password) {
      return res.status(400).json({
        success: false,
        message: 'phone_or_email and password are required.',
      });
    }

    const user = await findUser(phone_or_email);
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }

    const token = signToken(user.id);
    return res.status(200).json({ success: true, token, user: safeUser(user) });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/otp/request ───────────────────────────────────────────────────
//
//  Body: { identifier: "<email or phone>", purpose: "login|2fa|reset" }
//  Also accepts: { phone_number, purpose } for backwards compat.
//  OTP is ALWAYS sent to the user's registered email address.

router.post('/otp/request', otpRateLimiter, async (req, res, next) => {
  try {
    const { purpose } = req.body;
    // Accept either 'identifier' or legacy 'phone_number'/'email'
    const identifier = req.body.identifier || req.body.email || req.body.phone_number;

    if (!identifier || !purpose) {
      return res.status(400).json({
        success: false,
        message: 'identifier (email or phone_number) and purpose are required.',
      });
    }
    if (!['login', '2fa', 'reset'].includes(purpose)) {
      return res.status(400).json({
        success: false,
        message: "purpose must be 'login', '2fa', or 'reset'.",
      });
    }

    // Find user by email or phone
    const user = await findUser(identifier);

    // Generic response to prevent user enumeration
    if (!user) {
      return res.status(200).json({
        success: true,
        message: 'If an account exists, an OTP has been sent to the registered email.',
      });
    }

    const { id: userId, email: userEmail, phone_number: userPhone } = user;

    // Generate and hash OTP
    const otp       = generateOtp();
    const codeHash  = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 min
    console.log(`[otp/request] Generated OTP for user ${userId} (${userEmail}) purpose=${purpose}`);

    // Invalidate previous unverified OTPs for same user+purpose
    await pool.query(
      `UPDATE otps SET verified_at = NOW()
       WHERE user_id = $1 AND purpose = $2 AND verified_at IS NULL AND expires_at > NOW()`,
      [userId, purpose]
    );

    // Store new OTP
    await pool.query(
      `INSERT INTO otps (user_id, code_hash, purpose, expires_at, ip_address)
       VALUES ($1, $2, $3, $4, $5)`,
      [userId, codeHash, purpose, expiresAt, req.ip]
    );

    // ── Delivery: Email ───────────────────────────────────────────────────
    try {
      await sendEmailOtp(userEmail, otp, purpose);
    } catch (emailErr) {
      console.error('[otp/request] Email send failed:', emailErr.message);
      // In dev mode, OTP was already printed to console — don't 502
      if (process.env.SMTP_USER && process.env.SMTP_USER !== 'mock') {
        return res.status(502).json({
          success: false,
          message: 'Failed to send OTP email. Please try again later.',
        });
      }
    }

    // ── Delivery: SMS via Android SMS Gateway (best-effort) ───────────────
    if (userPhone && process.env.SMS_GW_MODE !== 'off') {
      sendSmsOtp(userPhone, otp, purpose).catch((smsErr) => {
        // Non-fatal — email already delivered above
        console.error('[otp/request] SMS send failed:', smsErr.message);
      });
    }

    return res.status(200).json({
      success: true,
      message: 'OTP sent to your registered email address and phone number.',
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/otp/verify ────────────────────────────────────────────────────
//
//  Accepts: { identifier, code, purpose }  OR legacy { phone_number, code, purpose }

router.post('/otp/verify', otpRateLimiter, async (req, res, next) => {
  try {
    const { code, purpose } = req.body;
    const identifier = req.body.identifier || req.body.email || req.body.phone_number;

    if (!identifier || !code || !purpose) {
      return res.status(400).json({
        success: false,
        message: 'identifier (email or phone_number), code, and purpose are required.',
      });
    }
    if (!['login', '2fa', 'reset'].includes(purpose)) {
      return res.status(400).json({
        success: false,
        message: "purpose must be 'login', '2fa', or 'reset'.",
      });
    }

    const verified = await verifyOtp(identifier, code, purpose);
    if (!verified.success) {
      return res.status(verified.status).json({ success: false, message: verified.message });
    }

    return res.status(200).json({ success: true, verified: true });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/2fa/verify ────────────────────────────────────────────────────

router.post('/2fa/verify', authMiddleware, async (req, res, next) => {
  try {
    const { code } = req.body;
    const identifier = req.body.identifier || req.body.email || req.body.phone_number;

    if (!identifier || !code) {
      return res.status(400).json({
        success: false,
        message: 'identifier (email or phone_number) and code are required.',
      });
    }

    const verified = await verifyOtp(identifier, code, '2fa');
    if (!verified.success) {
      return res.status(verified.status).json({ success: false, message: verified.message });
    }

    return res.status(200).json({
      success: true,
      verified: true,
      message: '2FA verified successfully.',
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/reset-password ────────────────────────────────────────────────

router.post('/reset-password', authRateLimiter, async (req, res, next) => {
  try {
    const { new_password, otp_code } = req.body;
    const identifier = req.body.identifier || req.body.email || req.body.phone_number;

    if (!identifier || !new_password || !otp_code) {
      return res.status(400).json({
        success: false,
        message: 'identifier (email or phone_number), new_password, and otp_code are required.',
      });
    }
    if (new_password.length < 4) {
      return res.status(400).json({
        success: false,
        message: 'New PIN/Password must be at least 4 digits.',
      });
    }

    const verified = await verifyOtp(identifier, otp_code, 'reset');
    if (!verified.success) {
      return res.status(verified.status).json({ success: false, message: verified.message });
    }

    const password_hash = await bcrypt.hash(new_password, 10);
    const id = identifier.trim();
    const updateResult = await pool.query(
      `UPDATE users SET password_hash = $1
       WHERE email = $2 OR phone_number = $3
       RETURNING id`,
      [password_hash, id.toLowerCase(), id]
    );

    if (updateResult.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    return res.status(200).json({ success: true, message: 'Password updated successfully.' });
  } catch (err) {
    next(err);
  }
});

// ─── GET /auth/me ─────────────────────────────────────────────────────────────

// GET /auth/me — returns current user from JWT (used for session restore)
router.get('/me', authMiddleware, async (req, res, next) => {
  try {
    const result = await pool.query(
      'SELECT id, name, email, phone_number, is_suspended, created_at FROM users WHERE id = $1',
      [req.userId]
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }
    return res.status(200).json({ success: true, user: result.rows[0] });
  } catch (err) { next(err); }
});

// ─── Internal OTP verification helper ────────────────────────────────────────

/**
 * Finds user by email or phone, then checks the latest OTP record.
 * @returns {{ success: boolean, status: number, message: string }}
 */
async function verifyOtp(identifier, code, purpose) {
  const id = identifier.trim();
  console.log(`[otp/verify] identifier="${id}" purpose="${purpose}" code="${code}"`);

  const user = await findUser(id);
  if (!user) {
    console.log(`[otp/verify] FAIL — no user found for identifier="${id}"`);
    return { success: false, status: 404, message: 'No account found for this identifier.' };
  }
  const userId = user.id;

  const otpResult = await pool.query(
    `SELECT id, code_hash, expires_at, attempts
     FROM otps
     WHERE user_id = $1 AND purpose = $2 AND verified_at IS NULL
     ORDER BY created_at DESC
     LIMIT 1`,
    [userId, purpose]
  );

  if (otpResult.rowCount === 0) {
    console.log(`[otp/verify] FAIL — no pending OTP for user=${userId} purpose="${purpose}"`);
    return { success: false, status: 400, message: 'No pending OTP found. Please request a new one.' };
  }

  const row = otpResult.rows[0];
  const now = new Date();
  const exp = new Date(row.expires_at);
  console.log(`[otp/verify] OTP id=${row.id} expires=${exp.toISOString()} now=${now.toISOString()} expired=${exp < now}`);

  if (exp < now) {
    return { success: false, status: 400, message: 'OTP has expired. Please request a new one.' };
  }

  if (row.attempts >= 5) {
    return { success: false, status: 429, message: 'Maximum OTP attempts exceeded. Please request a new OTP.' };
  }

  const match = await bcrypt.compare(String(code), row.code_hash);
  console.log(`[otp/verify] bcrypt match=${match} for code="${code}"`);
  if (!match) {
    await pool.query('UPDATE otps SET attempts = attempts + 1 WHERE id = $1', [row.id]);
    const remaining = 4 - row.attempts;
    return {
      success: false,
      status:  400,
      message: `Incorrect OTP. ${remaining > 0 ? `${remaining} attempts remaining.` : 'No attempts remaining.'}`,
    };
  }

  await pool.query('UPDATE otps SET verified_at = NOW() WHERE id = $1', [row.id]);
  console.log(`[otp/verify] SUCCESS — OTP ${row.id} verified for user=${userId}`);
  return { success: true };
}

// ─── POST /auth/forgot-password (alias for OTP request with purpose=reset) ───
// Kept for backward compat with older flutter screens. Accepts { email }.
router.post('/forgot-password', otpRateLimiter, async (req, res, next) => {
  try {
    const { email, phone_number, identifier } = req.body;
    const id = identifier || email || phone_number;
    if (!id) {
      return res.status(400).json({ success: false, message: 'email is required.' });
    }
    const userResult = await pool.query(
      `SELECT id, email FROM users WHERE email = $1 OR phone_number = $2 LIMIT 1`,
      [id.toLowerCase().trim(), id.trim()]
    );
    // Generic response to prevent enumeration
    if (userResult.rowCount === 0) {
      return res.status(200).json({ success: true, message: 'If an account exists, a reset code has been sent to your email.' });
    }
    const { id: userId, email: userEmail } = userResult.rows[0];
    const otp = generateOtp();
    const codeHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    await pool.query(
      `UPDATE otps SET verified_at = NOW() WHERE user_id = $1 AND purpose = 'reset' AND verified_at IS NULL AND expires_at > NOW()`,
      [userId]
    );
    await pool.query(
      `INSERT INTO otps (user_id, code_hash, purpose, expires_at, ip_address) VALUES ($1, $2, 'reset', $3, $4)`,
      [userId, codeHash, expiresAt, req.ip]
    );
    try {
      await sendEmailOtp(userEmail, otp, 'reset');
    } catch (emailErr) {
      console.error('[forgot-password] Email send failed:', emailErr.message);
      if (process.env.SMTP_USER && process.env.SMTP_USER !== 'mock') {
        return res.status(502).json({ success: false, message: 'Failed to send reset email. Please try again.' });
      }
    }

    // Best-effort SMS delivery
    if (process.env.SMS_GW_MODE !== 'off') {
      const phResult = await pool.query('SELECT phone_number FROM users WHERE id = $1', [userId]);
      const userPhone = phResult.rows[0]?.phone_number;
      if (userPhone) {
        sendSmsOtp(userPhone, otp, 'reset').catch((smsErr) => {
          console.error('[forgot-password] SMS send failed:', smsErr.message);
        });
      }
    }

    return res.status(200).json({ success: true, message: 'Password reset code sent to your registered email address and phone number.' });
  } catch (err) { next(err); }
});

module.exports = router;
