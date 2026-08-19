'use strict';

/**
 * backend/test/auth.test.js
 * Integration tests for /api/auth routes.
 *
 * These tests use supertest to call routes directly without a running server.
 * They require DATABASE_URL to be set; in a CI environment without one, all
 * tests are skipped gracefully (describe.skip).
 *
 * Run: npm test   (from the backend/ directory)
 */

require('dotenv').config();
const request = require('supertest');

const dbAvailable = !!process.env.DATABASE_URL;
const describeIfDb = dbAvailable ? describe : describe.skip;

let app;
if (dbAvailable) {
  // Load app without starting the HTTP listener
  app = require('../src/index');
}

// ─── POST /api/auth/signup ─────────────────────────────────────────────────

describeIfDb('POST /api/auth/signup', () => {
  test('400 when required fields are missing', async () => {
    const res = await request(app)
      .post('/api/auth/signup')
      .send({ name: 'Test User' }) // missing phone, email, password
      .expect(400);

    expect(res.body.success).toBe(false);
    expect(res.body.message).toMatch(/required/i);
  });

  test('400 when password is too short', async () => {
    const res = await request(app)
      .post('/api/auth/signup')
      .send({
        name:         'Test User',
        phone_number: '+10000000001',
        email:        'test_short_pw@example.com',
        password:     '123',
      })
      .expect(400);

    expect(res.body.success).toBe(false);
    expect(res.body.message).toMatch(/8 character/i);
  });
});

// ─── POST /api/auth/login ──────────────────────────────────────────────────

describeIfDb('POST /api/auth/login', () => {
  test('400 when phone_or_email is missing', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ password: 'somepassword' })
      .expect(400);

    expect(res.body.success).toBe(false);
  });

  test('401 when credentials are wrong', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        phone_or_email: 'nobody_at_all@example.com',
        password:       'wrongpassword',
      })
      .expect(401);

    expect(res.body.success).toBe(false);
  });
});

// ─── POST /api/auth/otp/request ───────────────────────────────────────────

describeIfDb('POST /api/auth/otp/request', () => {
  test('400 when identifier is missing', async () => {
    const res = await request(app)
      .post('/api/auth/otp/request')
      .send({ purpose: 'login' })
      .expect(400);

    expect(res.body.success).toBe(false);
  });

  test('400 when purpose is invalid', async () => {
    const res = await request(app)
      .post('/api/auth/otp/request')
      .send({ identifier: 'test@example.com', purpose: 'not_a_real_purpose' })
      .expect(400);

    expect(res.body.success).toBe(false);
  });
});

// ─── POST /api/auth/otp/verify ────────────────────────────────────────────

describeIfDb('POST /api/auth/otp/verify', () => {
  test('400 when code is missing', async () => {
    const res = await request(app)
      .post('/api/auth/otp/verify')
      .send({ identifier: 'test@example.com', purpose: 'login' })
      .expect(400);

    expect(res.body.success).toBe(false);
  });

  test('4xx when code is wrong', async () => {
    const res = await request(app)
      .post('/api/auth/otp/verify')
      .send({
        identifier: 'nobody@example.com',
        code:       '000000',
        purpose:    'login',
      });

    // 400 (user not found) or 401 (wrong code) — both are correct failures
    expect(res.status).toBeGreaterThanOrEqual(400);
    expect(res.body.success).toBe(false);
  });
});

// ─── GET /api/auth/me ─────────────────────────────────────────────────────

describeIfDb('GET /api/auth/me', () => {
  test('401 when no token is provided', async () => {
    const res = await request(app)
      .get('/api/auth/me')
      .expect(401);

    expect(res.body.success).toBe(false);
  });

  test('401 when token is invalid', async () => {
    const res = await request(app)
      .get('/api/auth/me')
      .set('Authorization', 'Bearer invalid.token.here')
      .expect(401);

    expect(res.body.success).toBe(false);
  });
});
