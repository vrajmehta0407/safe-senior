'use strict';

const express  = require('express');
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const crypto   = require('crypto');

const pool     = require('../db/pool');
const { sendOtp }          = require('../services/msg91');
const { otpRateLimiter, authRateLimiter } = require('../middleware/rateLimit');
const authMiddleware       = require('../middleware/auth');

const router = express.Router();

// ─── Helpers ────────────────────────────────────────────────────────────────

/** Generate a cryptographically random 6-digit OTP string */
function generateOtp() {
  // Use crypto.randomInt for uniform distribution (no modulo bias)
  const code = crypto.randomInt(100000, 999999);
  return String(code);
}

/** Sign a JWT that expires in 7 days */
function signToken(userId) {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

/** Strip sensitive fields before returning user data */
function safeUser(user) {
  const { password_hash, ...rest } = user;
  return rest;
}

// ─── POST /auth/signup ───────────────────────────────────────────────────────

router.post('/signup', async (req, res, next) => {
  try {
    const { name, phone_number, email, password } = req.body;

    // Basic input validation
    if (!name || !phone_number || !email || !password) {
      return res.status(400).json({ success: false, message: 'name, phone_number, email, and password are required.' });
    }
    if (password.length < 8) {
      return res.status(400).json({ success: false, message: 'Password must be at least 8 characters.' });
    }

    // Check for duplicate phone or email
    const existing = await pool.query(
      'SELECT id FROM users WHERE phone_number = $1 OR email = $2 LIMIT 1',
      [phone_number, email.toLowerCase()]
    );
    if (existing.rowCount > 0) {
      return res.status(409).json({ success: false, message: 'An account with this phone number or email already exists.' });
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Insert user
    const result = await pool.query(
      `INSERT INTO users (name, phone_number, email, password_hash)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, phone_number, email, created_at`,
      [name.trim(), phone_number.trim(), email.toLowerCase().trim(), password_hash]
    );

    const user  = result.rows[0];
    const token = signToken(user.id);

    return res.status(201).json({
      success: true,
      token,
      user: safeUser(user),
    });
  } catch (err) {
    // Postgres unique violation (race condition guard)
    if (err.code === '23505') {
      return res.status(409).json({ success: false, message: 'An account with this phone number or email already exists.' });
    }
    next(err);
  }
});

// ─── POST /auth/login ────────────────────────────────────────────────────────

router.post('/login', authRateLimiter, async (req, res, next) => {
  try {
    const { phone_or_email, password } = req.body;

    if (!phone_or_email || !password) {
      return res.status(400).json({ success: false, message: 'phone_or_email and password are required.' });
    }

    // Lookup by email OR phone
    const result = await pool.query(
      `SELECT id, name, phone_number, email, password_hash, created_at, guardian_id
       FROM users
       WHERE email = $1 OR phone_number = $2
       LIMIT 1`,
      [phone_or_email.toLowerCase().trim(), phone_or_email.trim()]
    );

    if (result.rowCount === 0) {
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }

    const user = result.rows[0];

    // Constant-time password comparison
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }

    const token = signToken(user.id);

    return res.status(200).json({
      success: true,
      token,
      user: safeUser(user),
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/otp/request ──────────────────────────────────────────────────

router.post('/otp/request', otpRateLimiter, async (req, res, next) => {
  try {
    const { phone_number, purpose } = req.body;

    if (!phone_number || !purpose) {
      return res.status(400).json({ success: false, message: 'phone_number and purpose are required.' });
    }
    if (!['login', '2fa', 'reset'].includes(purpose)) {
      return res.status(400).json({ success: false, message: "purpose must be 'login', '2fa', or 'reset'." });
    }

    // Find the user
    const userResult = await pool.query(
      'SELECT id FROM users WHERE phone_number = $1 LIMIT 1',
      [phone_number.trim()]
    );
    if (userResult.rowCount === 0) {
      // Return generic message to avoid user enumeration
      return res.status(200).json({ success: true, message: 'If an account exists, an OTP has been sent.' });
    }

    const userId = userResult.rows[0].id;

    // Generate OTP and hash it
    const otp      = generateOtp();
    const codeHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + 8 * 60 * 1000); // 8 minutes
    const ipAddress = req.ip;

    // Invalidate any existing unverified OTPs for this user+purpose
    await pool.query(
      `UPDATE otps SET verified_at = NOW()
       WHERE user_id = $1 AND purpose = $2 AND verified_at IS NULL AND expires_at > NOW()`,
      [userId, purpose]
    );

    // Insert new OTP record
    await pool.query(
      `INSERT INTO otps (user_id, code_hash, purpose, expires_at, ip_address)
       VALUES ($1, $2, $3, $4, $5)`,
      [userId, codeHash, purpose, expiresAt, ipAddress]
    );

    // Send OTP via MSG91
    try {
      await sendOtp(phone_number, otp);
    } catch (smsErr) {
      console.error('[otp/request] MSG91 send failed:', smsErr.message);
      // Don't expose SMS errors to clients but log them
      return res.status(502).json({ success: false, message: 'Failed to send OTP. Please try again.' });
    }

    return res.status(200).json({ success: true, message: 'OTP sent.' });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/otp/verify ───────────────────────────────────────────────────

router.post('/otp/verify', async (req, res, next) => {
  try {
    const { phone_number, code, purpose } = req.body;

    if (!phone_number || !code || !purpose) {
      return res.status(400).json({ success: false, message: 'phone_number, code, and purpose are required.' });
    }
    if (!['login', '2fa', 'reset'].includes(purpose)) {
      return res.status(400).json({ success: false, message: "purpose must be 'login', '2fa', or 'reset'." });
    }

    const verified = await verifyOtpForPhone(phone_number, code, purpose);

    if (!verified.success) {
      return res.status(verified.status).json({ success: false, message: verified.message });
    }

    return res.status(200).json({ success: true, verified: true });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/2fa/verify ───────────────────────────────────────────────────

router.post('/2fa/verify', authMiddleware, async (req, res, next) => {
  try {
    const { phone_number, code } = req.body;

    if (!phone_number || !code) {
      return res.status(400).json({ success: false, message: 'phone_number and code are required.' });
    }

    const verified = await verifyOtpForPhone(phone_number, code, '2fa');

    if (!verified.success) {
      return res.status(verified.status).json({ success: false, message: verified.message });
    }

    return res.status(200).json({ success: true, verified: true, message: '2FA verified successfully.' });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/reset-password ───────────────────────────────────────────────

router.post('/reset-password', async (req, res, next) => {
  try {
    const { phone_number, new_password, otp_code } = req.body;

    if (!phone_number || !new_password || !otp_code) {
      return res.status(400).json({ success: false, message: 'phone_number, new_password, and otp_code are required.' });
    }
    if (new_password.length < 8) {
      return res.status(400).json({ success: false, message: 'New password must be at least 8 characters.' });
    }

    // Verify the reset OTP first
    const verified = await verifyOtpForPhone(phone_number, otp_code, 'reset');
    if (!verified.success) {
      return res.status(verified.status).json({ success: false, message: verified.message });
    }

    // Hash and save new password
    const password_hash = await bcrypt.hash(new_password, 10);
    const updateResult  = await pool.query(
      'UPDATE users SET password_hash = $1 WHERE phone_number = $2 RETURNING id',
      [password_hash, phone_number.trim()]
    );

    if (updateResult.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    return res.status(200).json({ success: true, message: 'Password updated successfully.' });
  } catch (err) {
    next(err);
  }
});

// ─── Internal OTP verification helper ────────────────────────────────────────

/**
 * Looks up the latest unverified OTP for a given phone+purpose,
 * checks expiry + attempt count, and verifies the bcrypt hash.
 *
 * @returns {{success: boolean, status: number, message: string}}
 */
async function verifyOtpForPhone(phone_number, code, purpose) {
  // Find the user
  const userResult = await pool.query(
    'SELECT id FROM users WHERE phone_number = $1 LIMIT 1',
    [phone_number.trim()]
  );
  if (userResult.rowCount === 0) {
    return { success: false, status: 404, message: 'No account found for this phone number.' };
  }
  const userId = userResult.rows[0].id;

  // Find latest OTP record for user+purpose that hasn't been verified
  const otpResult = await pool.query(
    `SELECT id, code_hash, expires_at, attempts
     FROM otps
     WHERE user_id = $1
       AND purpose = $2
       AND verified_at IS NULL
     ORDER BY created_at DESC
     LIMIT 1`,
    [userId, purpose]
  );

  if (otpResult.rowCount === 0) {
    return { success: false, status: 400, message: 'No pending OTP found. Please request a new one.' };
  }

  const otpRow = otpResult.rows[0];

  // Check expiry
  if (new Date(otpRow.expires_at) < new Date()) {
    return { success: false, status: 400, message: 'OTP has expired. Please request a new one.' };
  }

  // Check max attempts (5)
  if (otpRow.attempts >= 5) {
    return { success: false, status: 429, message: 'Maximum OTP attempts exceeded. Please request a new OTP.' };
  }

  // Verify bcrypt hash
  const match = await bcrypt.compare(String(code), otpRow.code_hash);

  if (!match) {
    // Increment attempt counter
    await pool.query(
      'UPDATE otps SET attempts = attempts + 1 WHERE id = $1',
      [otpRow.id]
    );
    const remaining = 4 - otpRow.attempts; // otpRow.attempts is pre-increment
    return {
      success: false,
      status:  400,
      message: `Incorrect OTP. ${remaining > 0 ? `${remaining} attempts remaining.` : 'No attempts remaining.'}`,
    };
  }

  // Mark as verified
  await pool.query(
    'UPDATE otps SET verified_at = NOW() WHERE id = $1',
    [otpRow.id]
  );

  return { success: true };
}

module.exports = router;
