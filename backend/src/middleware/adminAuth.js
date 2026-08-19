'use strict';

const jwt    = require('jsonwebtoken');
const pool   = require('../db/pool');

/**
 * Admin JWT authentication middleware.
 *
 * Uses a SEPARATE secret (ADMIN_JWT_SECRET) from the user JWT (JWT_SECRET),
 * so a regular user token can NEVER grant admin access.
 *
 * On success: attaches req.admin = { adminId, role }
 * On failure: returns 401 with a generic message (no info leakage)
 */
async function adminAuthMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];

  if (!authHeader) {
    return res.status(401).json({ success: false, message: 'Authorization header missing.' });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
    return res.status(401).json({ success: false, message: 'Authorization header must be: Bearer <token>' });
  }

  const token = parts[1];

  let decoded;
  try {
    decoded = jwt.verify(token, process.env.ADMIN_JWT_SECRET);
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Admin session expired. Please log in again.' });
    }
    // Generic message — don't reveal whether secret is wrong vs token malformed
    return res.status(401).json({ success: false, message: 'Invalid credentials.' });
  }

  // Verify the token was issued with the admin type claim
  if (decoded.type !== 'admin') {
    return res.status(401).json({ success: false, message: 'Invalid credentials.' });
  }

  // Confirm the admin still exists and is active (catches revocation mid-session)
  let adminRow;
  try {
    const result = await pool.query(
      'SELECT id, role, is_active FROM admins WHERE id = $1 LIMIT 1',
      [decoded.adminId]
    );
    if (result.rowCount === 0 || !result.rows[0].is_active) {
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }
    adminRow = result.rows[0];
  } catch (dbErr) {
    console.error('[adminAuth] DB check failed:', dbErr.message);
    return res.status(500).json({ success: false, message: 'Internal server error.' });
  }

  req.admin = { adminId: adminRow.id, role: adminRow.role };
  return next();
}

/**
 * requireSuperAdmin — additional role check, use AFTER adminAuthMiddleware.
 * Usage: router.post('/admins', adminAuth, requireSuperAdmin, handler)
 */
function requireSuperAdmin(req, res, next) {
  if (!req.admin || req.admin.role !== 'superadmin') {
    return res.status(403).json({ success: false, message: 'Superadmin access required.' });
  }
  return next();
}

module.exports = { adminAuthMiddleware, requireSuperAdmin };
