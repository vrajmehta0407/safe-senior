'use strict';

const jwt = require('jsonwebtoken');

/**
 * JWT authentication middleware.
 *
 * Expects an `Authorization: Bearer <token>` header.
 * On success, attaches `req.userId` (integer) and `req.userPayload` (full decoded payload).
 * On failure, returns 401.
 */
function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];

  if (!authHeader) {
    return res.status(401).json({ success: false, message: 'Authorization header missing.' });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
    return res.status(401).json({ success: false, message: 'Authorization header must be: Bearer <token>' });
  }

  const token = parts[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId      = decoded.userId;   // integer user id
    req.userPayload = decoded;
    return next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Token expired. Please log in again.' });
    }
    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json({ success: false, message: 'Invalid token.' });
    }
    return res.status(401).json({ success: false, message: 'Authentication failed.' });
  }
}

module.exports = authMiddleware;
