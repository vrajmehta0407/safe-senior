'use strict';

/**
 * backend/test/guardians.test.js
 * Tests for /api/guardians CRUD routes (multi-guardian system).
 *
 * Run: npm test   (from the backend/ directory)
 */

const request = require('supertest');

const dbAvailable = !!process.env.DATABASE_URL;
const describeIfDb = dbAvailable ? describe : describe.skip;

let app;
if (dbAvailable) {
  app = require('../src/index');
}

// ─── GET /api/guardians ───────────────────────────────────────────────────

describeIfDb('GET /api/guardians', () => {
  test('401 when unauthenticated', async () => {
    const res = await request(app)
      .get('/api/guardians')
      .expect(401);

    expect(res.body.success).toBe(false);
  });

  test('401 when token is invalid', async () => {
    const res = await request(app)
      .get('/api/guardians')
      .set('Authorization', 'Bearer not.a.real.token')
      .expect(401);

    expect(res.body.success).toBe(false);
  });
});

// ─── POST /api/guardians ──────────────────────────────────────────────────

describeIfDb('POST /api/guardians', () => {
  test('401 when unauthenticated', async () => {
    const res = await request(app)
      .post('/api/guardians')
      .send({ name: 'Test Guardian', phone_number: '+10000000099' })
      .expect(401);

    expect(res.body.success).toBe(false);
  });

  test('401 when token is invalid', async () => {
    const res = await request(app)
      .post('/api/guardians')
      .set('Authorization', 'Bearer bad.token')
      .send({ name: 'Test Guardian', phone_number: '+10000000099' })
      .expect(401);

    expect(res.body.success).toBe(false);
  });
});

// ─── DELETE /api/guardians/:id ────────────────────────────────────────────

describeIfDb('DELETE /api/guardians/:id', () => {
  test('401 when unauthenticated', async () => {
    const res = await request(app)
      .delete('/api/guardians/999')
      .expect(401);

    expect(res.body.success).toBe(false);
  });

  test('401 when token is invalid', async () => {
    const res = await request(app)
      .delete('/api/guardians/999')
      .set('Authorization', 'Bearer bad.token')
      .expect(401);

    expect(res.body.success).toBe(false);
  });
});

// ─── PATCH /api/guardians/:id/set-primary ─────────────────────────────────

describeIfDb('PATCH /api/guardians/:id/set-primary', () => {
  test('401 when unauthenticated', async () => {
    const res = await request(app)
      .patch('/api/guardians/999/set-primary')
      .expect(401);

    expect(res.body.success).toBe(false);
  });

  test('401 when token is invalid', async () => {
    const res = await request(app)
      .patch('/api/guardians/999/set-primary')
      .set('Authorization', 'Bearer bad.token')
      .expect(401);

    expect(res.body.success).toBe(false);
  });
});
