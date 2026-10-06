'use strict';

const rateLimit = require('express-rate-limit');

/**
 * In-memory store for exponential backoff tracking.
 * Tracks attempts, failures, and backoff lockout timestamps per key.
 */
class ExponentialBackoffStore {
  constructor(cleanupIntervalMs = 60000) {
    this.records = new Map();
    this.cleanupTimer = setInterval(() => this.cleanup(), cleanupIntervalMs);
    if (this.cleanupTimer && this.cleanupTimer.unref) {
      this.cleanupTimer.unref();
    }
  }

  get(key) {
    return this.records.get(key);
  }

  /**
   * Check whether key is currently blocked or exceeded quota.
   * Returns { blocked: boolean, retryAfterSec: number, retryAfterMs: number, attempts: number, failures: number }
   */
  check(key, maxAllowed, windowMs) {
    const now = Date.now();
    let record = this.records.get(key);

    if (record) {
      // If the sliding window has elapsed and we are not currently blocked by backoff, reset window.
      if (now - record.firstAttemptAt > windowMs && now >= record.blockedUntil) {
        this.records.delete(key);
        record = null;
      }
    }

    if (!record) {
      return { blocked: false, retryAfterSec: 0, retryAfterMs: 0, attempts: 0, failures: 0 };
    }

    // 1. Check if blocked by exponential backoff
    if (now < record.blockedUntil) {
      const retryAfterMs = record.blockedUntil - now;
      return {
        blocked: true,
        retryAfterMs,
        retryAfterSec: Math.ceil(retryAfterMs / 1000),
        attempts: record.attempts,
        failures: record.failures,
      };
    }

    // 2. Check if total attempts exceed max allowed in current window
    if (record.attempts >= maxAllowed) {
      const windowRemainingMs = Math.max(1000, (record.firstAttemptAt + windowMs) - now);
      return {
        blocked: true,
        retryAfterMs: windowRemainingMs,
        retryAfterSec: Math.ceil(windowRemainingMs / 1000),
        attempts: record.attempts,
        failures: record.failures,
      };
    }

    return { blocked: false, retryAfterSec: 0, retryAfterMs: 0, attempts: record.attempts, failures: record.failures };
  }

  /**
   * Record a new request attempt.
   */
  recordAttempt(key, windowMs) {
    const now = Date.now();
    let record = this.records.get(key);
    if (!record || (now - record.firstAttemptAt > windowMs && now >= record.blockedUntil)) {
      record = {
        attempts: 1,
        failures: 0,
        firstAttemptAt: now,
        lastAttemptAt: now,
        blockedUntil: 0,
      };
      this.records.set(key, record);
    } else {
      record.attempts += 1;
      record.lastAttemptAt = now;
    }
    return record;
  }

  /**
   * Record a failure (400, 401, 403) and calculate exponential backoff if threshold met.
   */
  recordFailure(key, baseDelayMs, backoffFactor, maxDelayMs, threshold, windowMs) {
    const now = Date.now();
    let record = this.records.get(key);
    if (!record) {
      record = {
        attempts: 1,
        failures: 1,
        firstAttemptAt: now,
        lastAttemptAt: now,
        blockedUntil: 0,
      };
      this.records.set(key, record);
    } else {
      record.failures += 1;
      record.lastAttemptAt = now;
    }

    // Calculate exponential delay when failures reach or exceed threshold
    const excess = Math.max(0, record.failures - threshold + 1);
    if (excess > 0) {
      const delay = Math.min(
        maxDelayMs,
        Math.round(baseDelayMs * Math.pow(backoffFactor, excess - 1))
      );
      record.blockedUntil = Math.max(record.blockedUntil, now + delay);
    }
    return record;
  }

  /**
   * On successful authentication (200, 201), reset failure and backoff counters.
   */
  recordSuccess(key) {
    this.records.delete(key);
  }

  /**
   * Reset store (used for tests or administrative reset).
   */
  reset(key) {
    if (key) {
      this.records.delete(key);
    } else {
      this.records.clear();
    }
  }

  /**
   * Clean up expired records.
   */
  cleanup() {
    const now = Date.now();
    for (const [key, record] of this.records.entries()) {
      if (now - record.lastAttemptAt > 2 * 60 * 60 * 1000 && now >= record.blockedUntil) {
        this.records.delete(key);
      }
    }
  }

  destroy() {
    if (this.cleanupTimer) clearInterval(this.cleanupTimer);
  }
}

// Global backoff store instance for auth routes
const authBackoffStore = new ExponentialBackoffStore();

/**
 * Returns dynamic configuration for rate limiters read from process.env with robust defaults.
 */
function getRateLimitConfig() {
  return {
    auth: {
      windowMs:      parseInt(process.env.RATE_LIMIT_AUTH_WINDOW_MS, 10) || 15 * 60 * 1000,
      ipMax:         parseInt(process.env.RATE_LIMIT_AUTH_IP_MAX, 10) || 10,
      accountMax:    parseInt(process.env.RATE_LIMIT_AUTH_ACCOUNT_MAX, 10) || 5,
      baseDelayMs:   parseInt(process.env.RATE_LIMIT_AUTH_BASE_DELAY_MS, 10) || 1000,
      backoffFactor: parseFloat(process.env.RATE_LIMIT_AUTH_BACKOFF_FACTOR) || 2,
      maxDelayMs:    parseInt(process.env.RATE_LIMIT_AUTH_MAX_DELAY_MS, 10) || 5 * 60 * 1000,
    },
    otp: {
      windowMs:      parseInt(process.env.RATE_LIMIT_OTP_WINDOW_MS, 10) || 15 * 60 * 1000,
      ipMax:         parseInt(process.env.RATE_LIMIT_OTP_IP_MAX || process.env.RATE_LIMIT_OTP_MAX, 10) || 5,
      accountMax:    parseInt(process.env.RATE_LIMIT_OTP_ACCOUNT_MAX || process.env.RATE_LIMIT_OTP_MAX, 10) || 3,
      baseDelayMs:   parseInt(process.env.RATE_LIMIT_OTP_BASE_DELAY_MS || process.env.RATE_LIMIT_AUTH_BASE_DELAY_MS, 10) || 1000,
      backoffFactor: parseFloat(process.env.RATE_LIMIT_OTP_BACKOFF_FACTOR || process.env.RATE_LIMIT_AUTH_BACKOFF_FACTOR) || 2,
      maxDelayMs:    parseInt(process.env.RATE_LIMIT_OTP_MAX_DELAY_MS || process.env.RATE_LIMIT_AUTH_MAX_DELAY_MS, 10) || 5 * 60 * 1000,
    },
    adminLogin: {
      windowMs:      parseInt(process.env.RATE_LIMIT_ADMIN_LOGIN_WINDOW_MS, 10) || 15 * 60 * 1000,
      ipMax:         parseInt(process.env.RATE_LIMIT_ADMIN_LOGIN_MAX, 10) || 5,
      accountMax:    parseInt(process.env.RATE_LIMIT_ADMIN_LOGIN_ACCOUNT_MAX || process.env.RATE_LIMIT_ADMIN_LOGIN_MAX, 10) || 5,
      baseDelayMs:   parseInt(process.env.RATE_LIMIT_ADMIN_LOGIN_BASE_DELAY_MS || process.env.RATE_LIMIT_AUTH_BASE_DELAY_MS, 10) || 1000,
      backoffFactor: parseFloat(process.env.RATE_LIMIT_ADMIN_LOGIN_BACKOFF_FACTOR || process.env.RATE_LIMIT_AUTH_BACKOFF_FACTOR) || 2,
      maxDelayMs:    parseInt(process.env.RATE_LIMIT_ADMIN_LOGIN_MAX_DELAY_MS || process.env.RATE_LIMIT_AUTH_MAX_DELAY_MS, 10) || 5 * 60 * 1000,
    },
    public: {
      windowMs:      parseInt(process.env.RATE_LIMIT_PUBLIC_WINDOW_MS, 10) || 15 * 60 * 1000,
      max:           parseInt(process.env.RATE_LIMIT_PUBLIC_MAX, 10) || 100,
    },
    authenticated: {
      windowMs:      parseInt(process.env.RATE_LIMIT_AUTH_USER_WINDOW_MS, 10) || 15 * 60 * 1000,
      max:           parseInt(process.env.RATE_LIMIT_AUTH_USER_MAX, 10) || 500,
    },
  };
}

/**
 * Extracts normalized account identifiers (email and/or phone) from request body.
 */
function extractAccountIdentifiers(req) {
  if (!req.body || typeof req.body !== 'object') return [];
  const ids = new Set();

  const candidates = [
    req.body.phone_or_email,
    req.body.identifier,
    req.body.email,
    req.body.phone_number,
    req.body.phone,
  ];

  for (const c of candidates) {
    if (typeof c === 'string' && c.trim()) {
      const val = c.trim();
      if (val.includes('@')) {
        ids.add(`email:${val.toLowerCase()}`);
      } else {
        const digits = val.replace(/\D/g, '');
        if (digits) {
          ids.add(`phone:${digits}`);
        } else {
          ids.add(`raw:${val.toLowerCase()}`);
        }
      }
    }
  }

  return Array.from(ids);
}

/**
 * Factory for creating auth rate limiters that combine per-IP and per-account limits
 * with exponential backoff rather than a hard lockout.
 */
function createAuthBackoffLimiter(options = {}) {
  const store = options.store || authBackoffStore;
  const type = options.type || 'auth';

  return function authBackoffMiddleware(req, res, next) {
    if (process.env.NODE_ENV === 'test' && store === authBackoffStore) {
      return next();
    }
    const baseConfig = getRateLimitConfig()[type] || getRateLimitConfig().auth;
    const config = { ...baseConfig, ...options };
    const ip = req.ip || (req.socket && req.socket.remoteAddress) || '127.0.0.1';
    const ipKey = `ip:${ip}`;
    const accountIds = extractAccountIdentifiers(req);

    // 1. Check Per-IP backoff & limit
    const ipCheck = store.check(ipKey, config.ipMax, config.windowMs);
    if (ipCheck.blocked) {
      res.set('Retry-After', String(ipCheck.retryAfterSec));
      res.set('RateLimit-Limit', String(config.ipMax));
      res.set('RateLimit-Remaining', '0');
      res.set('RateLimit-Reset', String(ipCheck.retryAfterSec));
      return res.status(429).json({
        success: false,
        message: `Too many authentication attempts from this IP. Please wait ${ipCheck.retryAfterSec} second${ipCheck.retryAfterSec === 1 ? '' : 's'} before trying again.`,
        retryAfter: ipCheck.retryAfterSec,
      });
    }

    // 2. Check Per-Account backoff & limit
    for (const accId of accountIds) {
      const accKey = `acc:${accId}`;
      const accCheck = store.check(accKey, config.accountMax, config.windowMs);
      if (accCheck.blocked) {
        res.set('Retry-After', String(accCheck.retryAfterSec));
        res.set('RateLimit-Limit', String(config.accountMax));
        res.set('RateLimit-Remaining', '0');
        res.set('RateLimit-Reset', String(accCheck.retryAfterSec));
        return res.status(429).json({
          success: false,
          message: `Too many authentication attempts for this account. Please wait ${accCheck.retryAfterSec} second${accCheck.retryAfterSec === 1 ? '' : 's'} before trying again.`,
          retryAfter: accCheck.retryAfterSec,
        });
      }
    }

    // 3. Record attempt synchronously
    store.recordAttempt(ipKey, config.windowMs);
    for (const accId of accountIds) {
      store.recordAttempt(`acc:${accId}`, config.windowMs);
    }

    // Set standard rate limit headers
    const remaining = Math.max(0, config.ipMax - ipCheck.attempts - 1);
    res.set('RateLimit-Limit', String(config.ipMax));
    res.set('RateLimit-Remaining', String(remaining));

    // 4. Hook into response finish: reset on success, apply exponential backoff on auth failure
    res.on('finish', () => {
      const status = res.statusCode;
      if (status >= 200 && status < 300) {
        // Successful authentication: clear failure counters and backoff
        for (const accId of accountIds) {
          store.recordSuccess(`acc:${accId}`);
        }
        store.recordSuccess(ipKey);
      } else if (status === 401 || status === 400 || status === 403) {
        // Failed authentication: increment failures and apply exponential backoff
        for (const accId of accountIds) {
          store.recordFailure(
            `acc:${accId}`,
            config.baseDelayMs,
            config.backoffFactor,
            config.maxDelayMs,
            config.accountMax,
            config.windowMs
          );
        }
        store.recordFailure(
          ipKey,
          config.baseDelayMs,
          config.backoffFactor,
          config.maxDelayMs,
          config.ipMax,
          config.windowMs
        );
      }
    });

    next();
  };
}

/**
 * Stricter auth rate limiter for standard authentication endpoints:
 * login, signup, password reset.
 */
const authRateLimiter = createAuthBackoffLimiter({ type: 'auth' });

/**
 * OTP Rate Limiter:
 * Stricter limit on OTP requests/verifications (default: 3 attempts per 15 min per account, 5 per IP),
 * with exponential backoff on repeated failures.
 */
const otpRateLimiter = createAuthBackoffLimiter({ type: 'otp' });

/**
 * Admin Login Rate Limiter:
 * Strict limits on admin login endpoints (default: 5 per 15 min),
 * with exponential backoff on failure.
 */
const adminLoginRateLimiter = createAuthBackoffLimiter({ type: 'adminLogin' });

/**
 * Moderate rate limiter for public endpoints (e.g. /health, /api/scam-patterns/active, etc.)
 * Protects against scraping and resource exhaustion without affecting normal users.
 */
function createPublicRateLimiter(customOptions = {}) {
  const currentConfig = getRateLimitConfig().public;
  return rateLimit({
    windowMs:        customOptions.windowMs || currentConfig.windowMs,
    max:             customOptions.max || currentConfig.max,
    standardHeaders: true,
    legacyHeaders:   false,
    validate:        { xForwardedForHeader: false, default: false },
    keyGenerator: (req) => req.ip || (req.socket && req.socket.remoteAddress) || '127.0.0.1',
    handler: (req, res) => {
      res.status(429).json({
        success: false,
        message: customOptions.message || 'Too many requests on public endpoint. Please try again later.',
      });
    },
    ...customOptions,
  });
}

const publicRateLimiter = createPublicRateLimiter();

/**
 * Looser rate limiter for authenticated user actions (e.g. scam report, guardian sync, trusted senders).
 * Keyed per authenticated user ID (or admin ID), falling back to IP if not yet authenticated.
 */
function createAuthenticatedRateLimiter(customOptions = {}) {
  const currentConfig = getRateLimitConfig().authenticated;
  return rateLimit({
    windowMs:        customOptions.windowMs || currentConfig.windowMs,
    max:             customOptions.max || currentConfig.max,
    standardHeaders: true,
    legacyHeaders:   false,
    validate:        { xForwardedForHeader: false, default: false },
    keyGenerator: (req) => {
      if (req.userId) return `user_${req.userId}`;
      if (req.admin && req.admin.adminId) return `admin_${req.admin.adminId}`;
      return req.ip || (req.socket && req.socket.remoteAddress) || '127.0.0.1';
    },
    handler: (req, res) => {
      res.status(429).json({
        success: false,
        message: customOptions.message || 'Too many requests. Please slow down.',
      });
    },
    ...customOptions,
  });
}

const authenticatedRateLimiter = createAuthenticatedRateLimiter();

/**
 * Reset all rate limit stores (useful in test teardown or administrative reset).
 */
function resetRateLimits() {
  authBackoffStore.reset();
}

module.exports = {
  // Primary limiters
  authRateLimiter,
  otpRateLimiter,
  adminLoginRateLimiter,
  publicRateLimiter,
  authenticatedRateLimiter,

  // Factories & utilities
  createAuthBackoffLimiter,
  createPublicRateLimiter,
  createAuthenticatedRateLimiter,
  getRateLimitConfig,
  extractAccountIdentifiers,
  resetRateLimits,
  ExponentialBackoffStore,
  authBackoffStore,
};
