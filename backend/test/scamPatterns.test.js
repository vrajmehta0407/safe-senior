'use strict';

/**
 * backend/test/scamPatterns.test.js
 * Tests for /api/scam-patterns routes.
 *
 * Run: npm test   (from the backend/ directory)
 */

require('dotenv').config();
const request = require('supertest');

const dbAvailable = !!process.env.DATABASE_URL;
const describeIfDb = dbAvailable ? describe : describe.skip;

let app;
if (dbAvailable) {
  app = require('../src/index');
}

// ─── GET /api/scam-patterns/latest ────────────────────────────────────────

describeIfDb('GET /api/scam-patterns/latest', () => {
  test('200 and returns patterns array (no auth required)', async () => {
    const res = await request(app)
      .get('/api/scam-patterns/latest')
      .expect(200);

    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.patterns)).toBe(true);
  });

  test('each pattern has expected shape', async () => {
    const res = await request(app)
      .get('/api/scam-patterns/latest')
      .expect(200);

    for (const pattern of res.body.patterns) {
      expect(typeof pattern.id).toBe('number');
      expect(typeof pattern.pattern_text).toBe('string');
    }
  });
});

// ─── POST /api/scam-patterns/report ───────────────────────────────────────

describeIfDb('POST /api/scam-patterns/report', () => {
  test('401 when no auth token is provided', async () => {
    const res = await request(app)
      .post('/api/scam-patterns/report')
      .send({
        type:           'sms',
        sender:         'TestSender',
        classification: 'suspicious',
      })
      .expect(401);

    expect(res.body.success).toBe(false);
  });

  test('401 when invalid auth token is provided', async () => {
    const res = await request(app)
      .post('/api/scam-patterns/report')
      .set('Authorization', 'Bearer bad.token.here')
      .send({
        type:           'sms',
        sender:         'TestSender',
        classification: 'suspicious',
      })
      .expect(401);

    expect(res.body.success).toBe(false);
  });
});
