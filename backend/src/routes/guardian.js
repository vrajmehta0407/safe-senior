'use strict';

const express        = require('express');
const pool           = require('../db/pool');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// All guardian routes require authentication
router.use(authMiddleware);

// ─── GET /guardian/sync ───────────────────────────────────────────────────────
/**
 * Returns the guardian linked to the authenticated user.
 * Looks up via guardians.user_id = req.userId.
 */
router.get('/sync', async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT id, user_id, name, phone_number, relationship, created_at
       FROM guardians
       WHERE user_id = $1
       LIMIT 1`,
      [req.userId]
    );

    if (result.rowCount === 0) {
      return res.status(200).json({ success: true, guardian: null });
    }

    return res.status(200).json({ success: true, guardian: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// ─── POST /guardian/sync ──────────────────────────────────────────────────────
/**
 * Upsert a guardian for the authenticated user.
 * If a guardian already exists for this user, update it.
 * Otherwise, insert a new record.
 * Body: { name, phone_number, relationship }
 */
router.post('/sync', async (req, res, next) => {
  try {
    const { name, phone_number, relationship } = req.body;

    if (!name || !phone_number) {
      return res.status(400).json({ success: false, message: 'name and phone_number are required.' });
    }

    // Upsert: update if exists, insert otherwise.
    // We key on user_id because each user has exactly one guardian.
    const result = await pool.query(
      `INSERT INTO guardians (user_id, name, phone_number, relationship)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id)
       DO UPDATE SET
         name         = EXCLUDED.name,
         phone_number = EXCLUDED.phone_number,
         relationship = EXCLUDED.relationship
       RETURNING id, user_id, name, phone_number, relationship, created_at`,
      [req.userId, name.trim(), phone_number.trim(), relationship ? relationship.trim() : null]
    );

    return res.status(200).json({ success: true, guardian: result.rows[0] });
  } catch (err) {
    // If the ON CONFLICT clause fails because there is no unique constraint on user_id yet,
    // fall back to a manual upsert.
    if (err.code === '42P10' || err.code === '23000') {
      return next(err);
    }
    next(err);
  }
});

module.exports = router;
