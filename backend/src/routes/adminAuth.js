'use strict';

const express   = require('express');
const bcrypt    = require('bcryptjs');
const jwt       = require('jsonwebtoken');
const speakeasy = require('speakeasy');
const qrcode    = require('qrcode');

const pool      = require('../db/pool');
const { adminLoginRateLimiter }              = require('../middleware/rateLimit');
const { adminAuthMiddleware: adminAuth }     = require('../middleware/adminAuth');

const router = express.Router();

// ─── Helpers ─────────────────────────────────────────────────────────────────

/**
 * Write a row to admin_audit_log.
 * Non-throwing — log failures should never block the response.
 */
async function auditLog({ adminId = null, action, targetType = null, targetId = null, metadata = null, ip }) {
  try {
    await pool.query(
      `INSERT INTO admin_audit_log (admin_id, action, target_type, target_id, metadata, ip_address)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [adminId, action, targetType, targetId, metadata ? JSON.stringify(metadata) : null, ip]
    );
  } catch (err) {
    console.error('[auditLog] Failed to write audit entry:', err.message);
  }
}

/**
 * Sign an admin JWT with its own secret and a short 2h expiry.
 * The `type: 'admin'` claim is checked in adminAuth middleware so
 * a normal user JWT can NEVER pass admin auth even if JWT_SECRET leaked.
 */
function signAdminToken(adminId, role) {
  return jwt.sign(
    { adminId, role, type: 'admin' },
    process.env.ADMIN_JWT_SECRET,
    { expiresIn: '2h' }
  );
}

// ─── POST /auth/login ─────────────────────────────────────────────────────────

router.post('/login', adminLoginRateLimiter, async (req, res, next) => {
  const { email, password } = req.body;
  const ip = req.ip;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'email and password are required.' });
  }

  try {
    // Look up admin by email ONLY (never touches users table)
    const result = await pool.query(
      `SELECT id, name, email, password_hash, role, is_active, totp_secret, totp_enabled
       FROM admins
       WHERE email = $1 LIMIT 1`,
      [email.toLowerCase().trim()]
    );

    // Always do a bcrypt compare even on miss to prevent timing attacks
    const dummyHash = '$2a$12$invalidhashfortimingnormalization...............................';
    const adminRow  = result.rowCount > 0 ? result.rows[0] : null;
    const hashToCompare = adminRow ? adminRow.password_hash : dummyHash;

    const match = await bcrypt.compare(password, hashToCompare);

    if (!adminRow || !match || !adminRow.is_active) {
      // Log failure — but use generic message regardless of reason
      await auditLog({
        adminId: adminRow?.id ?? null,
        action: 'login_failed',
        metadata: { email, reason: !adminRow ? 'not_found' : !match ? 'wrong_password' : 'inactive' },
        ip,
      });
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }

    // ── 2FA check ────────────────────────────────────────────────────────────
    const twoFaRequired = process.env.ADMIN_2FA_REQUIRED === 'true';

    if (twoFaRequired && adminRow.totp_enabled) {
      // Don't issue token yet — client must complete TOTP step
      // Issue a short-lived pre-auth token (5 min) just to carry adminId through the 2FA step
      const preAuthToken = jwt.sign(
        { adminId: adminRow.id, role: adminRow.role, type: 'admin_preauth' },
        process.env.ADMIN_JWT_SECRET,
        { expiresIn: '5m' }
      );
      return res.status(200).json({
        success: true,
        requires2FA: true,
        preAuthToken,
        message: 'TOTP code required to complete login.',
      });
    }

    // Issue full admin token
    const token = signAdminToken(adminRow.id, adminRow.role);

    // Update last_login_at
    await pool.query('UPDATE admins SET last_login_at = NOW() WHERE id = $1', [adminRow.id]);

    // Audit success
    await auditLog({ adminId: adminRow.id, action: 'login_success', ip });

    return res.status(200).json({
      success: true,
      token,
      admin: { id: adminRow.id, name: adminRow.name, email: adminRow.email, role: adminRow.role },
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/login/2fa ──────────────────────────────────────────────────────
// Called after /login when requires2FA === true.
// Body: { preAuthToken, totpCode }

router.post('/login/2fa', adminLoginRateLimiter, async (req, res, next) => {
  const { preAuthToken, totpCode } = req.body;

  if (!preAuthToken || !totpCode) {
    return res.status(400).json({ success: false, message: 'preAuthToken and totpCode are required.' });
  }

  try {
    let decoded;
    try {
      decoded = jwt.verify(preAuthToken, process.env.ADMIN_JWT_SECRET);
    } catch {
      return res.status(401).json({ success: false, message: 'Invalid or expired pre-auth token.' });
    }

    if (decoded.type !== 'admin_preauth') {
      return res.status(401).json({ success: false, message: 'Invalid token type.' });
    }

    const result = await pool.query(
      'SELECT id, name, email, role, is_active, totp_secret FROM admins WHERE id = $1 LIMIT 1',
      [decoded.adminId]
    );

    if (result.rowCount === 0 || !result.rows[0].is_active) {
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }

    const admin = result.rows[0];

    const valid = speakeasy.totp.verify({
      secret:   admin.totp_secret,
      encoding: 'base32',
      token:    String(totpCode).trim(),
      window:   1, // allow ±30s clock drift
    });

    if (!valid) {
      await auditLog({ adminId: admin.id, action: 'login_2fa_failed', ip: req.ip });
      return res.status(401).json({ success: false, message: 'Invalid TOTP code.' });
    }

    // Issue full token
    const token = signAdminToken(admin.id, admin.role);
    await pool.query('UPDATE admins SET last_login_at = NOW() WHERE id = $1', [admin.id]);
    await auditLog({ adminId: admin.id, action: 'login_success_2fa', ip: req.ip });

    return res.status(200).json({
      success: true,
      token,
      admin: { id: admin.id, name: admin.name, email: admin.email, role: admin.role },
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/totp/setup ─────────────────────────────────────────────────────
// Authenticated. Generates a new TOTP secret for the admin.
// Returns { otpauthUrl, base32Secret } — admin scans in Google Authenticator.
// Does NOT enable 2FA yet — must call /totp/confirm to verify and activate.

router.post('/totp/setup', adminAuth, async (req, res, next) => {
  try {
    const secret = speakeasy.generateSecret({
      name:   `SafeSenior Admin (${req.admin.adminId})`,
      length: 32,
    });

    // Save the secret (not yet enabled)
    await pool.query(
      'UPDATE admins SET totp_secret = $1, totp_enabled = false WHERE id = $2',
      [secret.base32, req.admin.adminId]
    );

    const otpauthUrl = await qrcode.toDataURL(secret.otpauth_url);

    await auditLog({ adminId: req.admin.adminId, action: 'totp_setup_initiated', ip: req.ip });

    return res.status(200).json({
      success:      true,
      base32Secret: secret.base32,
      otpauthUrl,   // data:image/png;base64,... — display as <img> in admin UI
      message:      'Scan the QR code with your authenticator app, then call /totp/confirm with a valid code to activate 2FA.',
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /auth/totp/confirm ───────────────────────────────────────────────────
// Authenticated. Verifies a TOTP code to confirm enrollment and activates 2FA.

router.post('/totp/confirm', adminAuth, async (req, res, next) => {
  const { totpCode } = req.body;

  if (!totpCode) {
    return res.status(400).json({ success: false, message: 'totpCode is required.' });
  }

  try {
    const result = await pool.query(
      'SELECT totp_secret FROM admins WHERE id = $1 LIMIT 1',
      [req.admin.adminId]
    );

    if (result.rowCount === 0 || !result.rows[0].totp_secret) {
      return res.status(400).json({ success: false, message: 'No TOTP secret found. Call /totp/setup first.' });
    }

    const valid = speakeasy.totp.verify({
      secret:   result.rows[0].totp_secret,
      encoding: 'base32',
      token:    String(totpCode).trim(),
      window:   1,
    });

    if (!valid) {
      return res.status(400).json({ success: false, message: 'TOTP code incorrect. Try again or re-scan the QR code.' });
    }

    await pool.query('UPDATE admins SET totp_enabled = true WHERE id = $1', [req.admin.adminId]);
    await auditLog({ adminId: req.admin.adminId, action: 'totp_enabled', ip: req.ip });

    return res.status(200).json({
      success: true,
      message: '2FA activated. Set ADMIN_2FA_REQUIRED=true in .env to enforce it on all logins.',
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
