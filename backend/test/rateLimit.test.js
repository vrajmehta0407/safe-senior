'use strict';

process.env.NODE_ENV = 'test';

const request = require('supertest');
const express = require('express');
const {
  createAuthBackoffLimiter,
  createPublicRateLimiter,
  createAuthenticatedRateLimiter,
  getRateLimitConfig,
  ExponentialBackoffStore,
  extractAccountIdentifiers,
  resetRateLimits,
} = require('../src/middleware/rateLimit');

describe('Rate Limiting System', () => {
  beforeEach(() => {
    resetRateLimits();
  });

  describe('Configuration Thresholds', () => {
    const originalEnv = { ...process.env };

    afterEach(() => {
      process.env = { ...originalEnv };
    });

    test('loads default values when env vars are not set', () => {
      delete process.env.RATE_LIMIT_AUTH_WINDOW_MS;
      delete process.env.RATE_LIMIT_AUTH_IP_MAX;
      delete process.env.RATE_LIMIT_AUTH_ACCOUNT_MAX;
      delete process.env.RATE_LIMIT_PUBLIC_MAX;
      delete process.env.RATE_LIMIT_AUTH_USER_MAX;

      const config = getRateLimitConfig();
      expect(config.auth.windowMs).toBe(15 * 60 * 1000);
      expect(config.auth.ipMax).toBe(10);
      expect(config.auth.accountMax).toBe(5);
      expect(config.public.max).toBe(100);
      expect(config.authenticated.max).toBe(500);
    });

    test('overrides default values from environment variables', () => {
      process.env.RATE_LIMIT_AUTH_WINDOW_MS = '60000';
      process.env.RATE_LIMIT_AUTH_IP_MAX = '20';
      process.env.RATE_LIMIT_AUTH_ACCOUNT_MAX = '8';
      process.env.RATE_LIMIT_AUTH_BASE_DELAY_MS = '2000';
      process.env.RATE_LIMIT_AUTH_BACKOFF_FACTOR = '3';
      process.env.RATE_LIMIT_AUTH_MAX_DELAY_MS = '60000';
      process.env.RATE_LIMIT_PUBLIC_MAX = '150';
      process.env.RATE_LIMIT_AUTH_USER_MAX = '1000';

      const config = getRateLimitConfig();
      expect(config.auth.windowMs).toBe(60000);
      expect(config.auth.ipMax).toBe(20);
      expect(config.auth.accountMax).toBe(8);
      expect(config.auth.baseDelayMs).toBe(2000);
      expect(config.auth.backoffFactor).toBe(3);
      expect(config.auth.maxDelayMs).toBe(60000);
      expect(config.public.max).toBe(150);
      expect(config.authenticated.max).toBe(1000);
    });
  });

  describe('extractAccountIdentifiers', () => {
    test('extracts and normalizes email', () => {
      const req = { body: { email: '  TestUser@Example.COM  ' } };
      const ids = extractAccountIdentifiers(req);
      expect(ids).toContain('email:testuser@example.com');
    });

    test('extracts and normalizes phone number to digits', () => {
      const req = { body: { phone_number: '+1 (555) 123-4567' } };
      const ids = extractAccountIdentifiers(req);
      expect(ids).toContain('phone:15551234567');
    });

    test('extracts both email and phone when provided in signup', () => {
      const req = {
        body: {
          email: 'user@domain.com',
          phone_number: '+91 98765 43210',
        },
      };
      const ids = extractAccountIdentifiers(req);
      expect(ids).toEqual(
        expect.arrayContaining(['email:user@domain.com', 'phone:919876543210'])
      );
    });

    test('extracts phone_or_email field', () => {
      const reqEmail = { body: { phone_or_email: 'hello@world.org' } };
      expect(extractAccountIdentifiers(reqEmail)).toContain('email:hello@world.org');

      const reqPhone = { body: { phone_or_email: '9876543210' } };
      expect(extractAccountIdentifiers(reqPhone)).toContain('phone:9876543210');
    });

    test('returns empty array if no body or identifiers', () => {
      expect(extractAccountIdentifiers({})).toEqual([]);
      expect(extractAccountIdentifiers({ body: {} })).toEqual([]);
      expect(extractAccountIdentifiers({ body: { otherField: 'val' } })).toEqual([]);
    });
  });

  describe('ExponentialBackoffStore', () => {
    let store;

    beforeEach(() => {
      store = new ExponentialBackoffStore(100000);
    });

    afterEach(() => {
      store.destroy();
    });

    test('allows attempts within max quota', () => {
      const key = 'test-key';
      expect(store.check(key, 3, 60000).blocked).toBe(false);

      store.recordAttempt(key, 60000);
      store.recordAttempt(key, 60000);
      expect(store.check(key, 3, 60000).blocked).toBe(false);

      store.recordAttempt(key, 60000);
      // Now max 3 reached
      const check = store.check(key, 3, 60000);
      expect(check.blocked).toBe(true);
      expect(check.retryAfterSec).toBeGreaterThan(0);
    });

    test('applies exponential backoff on repeated failures without hard lockout', () => {
      const key = 'fail-key';
      const baseDelay = 1000;
      const factor = 2;
      const maxDelay = 10000;
      const threshold = 3;

      // Failures 1 and 2: below threshold, not blocked
      store.recordFailure(key, baseDelay, factor, maxDelay, threshold, 60000);
      expect(store.check(key, 10, 60000).blocked).toBe(false);

      store.recordFailure(key, baseDelay, factor, maxDelay, threshold, 60000);
      expect(store.check(key, 10, 60000).blocked).toBe(false);

      // Failure 3: threshold reached -> baseDelay 1000ms backoff
      store.recordFailure(key, baseDelay, factor, maxDelay, threshold, 60000);
      let check = store.check(key, 10, 60000);
      expect(check.blocked).toBe(true);
      expect(check.retryAfterMs).toBeLessThanOrEqual(1000);

      // Failure 4: factor * baseDelay = 2000ms
      store.recordFailure(key, baseDelay, factor, maxDelay, threshold, 60000);
      check = store.check(key, 10, 60000);
      expect(check.blocked).toBe(true);
      expect(check.retryAfterMs).toBeGreaterThan(1000);
      expect(check.retryAfterMs).toBeLessThanOrEqual(2000);

      // Failure 5: factor^2 * baseDelay = 4000ms
      store.recordFailure(key, baseDelay, factor, maxDelay, threshold, 60000);
      check = store.check(key, 10, 60000);
      expect(check.blocked).toBe(true);
      expect(check.retryAfterMs).toBeGreaterThan(2000);
      expect(check.retryAfterMs).toBeLessThanOrEqual(4000);
    });

    test('caps exponential backoff at maxDelayMs', () => {
      const key = 'cap-key';
      const baseDelay = 1000;
      const factor = 2;
      const maxDelay = 3000;
      const threshold = 1;

      for (let i = 0; i < 10; i++) {
        store.recordFailure(key, baseDelay, factor, maxDelay, threshold, 60000);
      }

      const check = store.check(key, 20, 60000);
      expect(check.blocked).toBe(true);
      expect(check.retryAfterMs).toBeLessThanOrEqual(maxDelay);
    });

    test('successful attempt resets backoff and failures for that key', () => {
      const key = 'recover-key';
      store.recordFailure(key, 1000, 2, 5000, 1, 60000);
      expect(store.check(key, 10, 60000).blocked).toBe(true);

      // User enters correct credentials
      store.recordSuccess(key);
      expect(store.check(key, 10, 60000).blocked).toBe(false);
    });
  });

  describe('Auth Routes Middleware (Per-IP and Per-Account with Exponential Backoff)', () => {
    let app;
    let customStore;

    beforeEach(() => {
      customStore = new ExponentialBackoffStore();
      app = express();
      app.use(express.json());

      const testLimiter = createAuthBackoffLimiter({
        store: customStore,
        ipMax: 3,
        accountMax: 2,
        baseDelayMs: 500,
        backoffFactor: 2,
        maxDelayMs: 2000,
        windowMs: 10000,
      });

      app.post('/test/login', testLimiter, (req, res) => {
        const { password } = req.body;
        if (password === 'correct-password') {
          return res.status(200).json({ success: true, token: 'fake-jwt' });
        }
        return res.status(401).json({ success: false, message: 'Invalid credentials' });
      });
    });

    afterEach(() => {
      customStore.destroy();
    });

    test('enforces per-account rate limit and sets Retry-After header', async () => {
      // Attempt 1: wrong password
      const r1 = await request(app)
        .post('/test/login')
        .send({ email: 'target@example.com', password: 'wrong' })
        .expect(401);
      expect(r1.body.success).toBe(false);

      // Attempt 2: wrong password
      const r2 = await request(app)
        .post('/test/login')
        .send({ email: 'target@example.com', password: 'wrong' })
        .expect(401);
      expect(r2.body.success).toBe(false);

      // Attempt 3: account max is 2 -> blocked with 429
      const r3 = await request(app)
        .post('/test/login')
        .send({ email: 'target@example.com', password: 'wrong' })
        .expect(429);

      expect(r3.body.success).toBe(false);
      expect(r3.body.message).toMatch(/Too many authentication attempts/i);
      expect(r3.headers['retry-after']).toBeDefined();
      expect(r3.body.retryAfter).toBeGreaterThan(0);
    });

    test('attack on Account A does not lock out Account B from different identifier', async () => {
      // 2 failed attempts on Account A
      await request(app)
        .post('/test/login')
        .send({ email: 'victim-a@example.com', password: 'wrong' });
      await request(app)
        .post('/test/login')
        .send({ email: 'victim-a@example.com', password: 'wrong' });

      // Account A is now rate-limited
      const rA = await request(app)
        .post('/test/login')
        .send({ email: 'victim-a@example.com', password: 'wrong' })
        .expect(429);
      expect(rA.body.success).toBe(false);

      // But Account B can still log in successfully
      // (using a distinct IP representation or clean store)
      customStore.reset('ip:127.0.0.1'); // clear shared loopback IP counter to test account isolation
      const rB = await request(app)
        .post('/test/login')
        .send({ email: 'victim-b@example.com', password: 'correct-password' })
        .expect(200);
      expect(rB.body.success).toBe(true);
    });

    test('successful login clears backoff record for account', async () => {
      // 1 failed attempt
      await request(app)
        .post('/test/login')
        .send({ email: 'user@test.com', password: 'wrong' })
        .expect(401);

      // Successful login
      await request(app)
        .post('/test/login')
        .send({ email: 'user@test.com', password: 'correct-password' })
        .expect(200);

      // Record in store should be cleared
      expect(customStore.get('acc:email:user@test.com')).toBeUndefined();
    });
  });

  describe('Moderate Limits on Public Endpoints', () => {
    let app;

    beforeEach(() => {
      app = express();
      const limiter = createPublicRateLimiter({
        windowMs: 5000,
        max: 2,
        message: 'Public endpoint limit reached.',
      });
      app.get('/public/data', limiter, (_req, res) => {
        res.status(200).json({ success: true, data: 'public data' });
      });
    });

    test('allows up to limit and blocks on excess with 429', async () => {
      await request(app).get('/public/data').expect(200);
      await request(app).get('/public/data').expect(200);

      const res = await request(app).get('/public/data').expect(429);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe('Public endpoint limit reached.');
    });
  });

  describe('Looser Limits on Authenticated Endpoints', () => {
    let app;

    beforeEach(() => {
      app = express();
      // Fake auth middleware setting req.userId
      app.use((req, _res, next) => {
        if (req.headers['x-user-id']) {
          req.userId = parseInt(req.headers['x-user-id'], 10);
        }
        next();
      });

      const limiter = createAuthenticatedRateLimiter({
        windowMs: 5000,
        max: 3,
        message: 'User rate limit exceeded.',
      });

      app.get('/user/dashboard', limiter, (req, res) => {
        res.status(200).json({ success: true, userId: req.userId });
      });
    });

    test('tracks limits per authenticated userId', async () => {
      // User 1 makes 3 requests (reaches limit)
      await request(app).get('/user/dashboard').set('x-user-id', '1').expect(200);
      await request(app).get('/user/dashboard').set('x-user-id', '1').expect(200);
      await request(app).get('/user/dashboard').set('x-user-id', '1').expect(200);

      const rUser1Blocked = await request(app)
        .get('/user/dashboard')
        .set('x-user-id', '1')
        .expect(429);
      expect(rUser1Blocked.body.message).toBe('User rate limit exceeded.');

      // User 2 can still make requests because limits are per authenticated user
      const rUser2 = await request(app)
        .get('/user/dashboard')
        .set('x-user-id', '2')
        .expect(200);
      expect(rUser2.body.success).toBe(true);
    });
  });
});
