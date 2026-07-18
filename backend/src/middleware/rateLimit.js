'use strict';

const rateLimit = require('express-rate-limit');

/**
 * otpRateLimiter
 * Allows 3 OTP requests per phone number (or IP fallback) per 15 minutes.
 * Keyed on req.body.phone || req.ip so each phone number has its own counter.
 */
const otpRateLimiter = rateLimit({
  windowMs:        15 * 60 * 1000,  // 15 minutes
  max:             3,
  standardHeaders: true,
  legacyHeaders:   false,
  keyGenerator: (req) => {
    // Prefer the phone number from body so limits are per-phone, not per-IP.
    // Fallback to IP if phone is not in the body yet.
    return (req.body && req.body.phone_number) || req.ip;
  },
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Too many OTP requests. Please wait 15 minutes before trying again.',
    });
  },
});

/**
 * authRateLimiter
 * Allows 10 login attempts per IP per 15 minutes.
 */
const authRateLimiter = rateLimit({
  windowMs:        15 * 60 * 1000,  // 15 minutes
  max:             10,
  standardHeaders: true,
  legacyHeaders:   false,
  keyGenerator: (req) => req.ip,
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Too many login attempts. Please try again in 15 minutes.',
    });
  },
});

module.exports = { otpRateLimiter, authRateLimiter };
