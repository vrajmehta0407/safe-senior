// routes/guardians.js — multiple guardian contacts per user (join table)
const express = require('express');
const router  = express.Router();
const pool    = require('../db/pool');
const auth    = require('../middleware/auth');

router.use(auth);

// GET /guardians — list all guardians for current user
router.get('/', async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT ug.id, ug.is_primary, g.name, g.phone_number, g.relationship
       FROM user_guardians ug
       JOIN guardians g ON g.id = ug.guardian_id
       WHERE ug.user_id = $1
       ORDER BY ug.is_primary DESC, g.name`,
      [req.userId]
    );
    return res.json({ success: true, guardians: result.rows });
  } catch (err) { next(err); }
});

// POST /guardians — add a guardian
router.post('/', async (req, res, next) => {
  try {
    const { name, phone_number, relationship, is_primary } = req.body;
    if (!name || !phone_number) {
      return res.status(400).json({ success: false, message: 'name and phone_number required.' });
    }
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      // Insert or find guardian by phone
      let guardianRes = await client.query(
        `INSERT INTO guardians (user_id, name, phone_number, relationship)
         VALUES ($1,$2,$3,$4)
         ON CONFLICT DO NOTHING RETURNING id`,
        [req.userId, name.trim(), phone_number.trim(), relationship || 'family']
      );
      if (guardianRes.rowCount === 0) {
        guardianRes = await client.query(
          'SELECT id FROM guardians WHERE user_id=$1 AND phone_number=$2',
          [req.userId, phone_number.trim()]
        );
      }
      const guardianId = guardianRes.rows[0].id;
      // If setting as primary, unset others
      if (is_primary) {
        await client.query(
          'UPDATE user_guardians SET is_primary = false WHERE user_id = $1',
          [req.userId]
        );
      }
      const link = await client.query(
        `INSERT INTO user_guardians (user_id, guardian_id, is_primary)
         VALUES ($1,$2,$3)
         ON CONFLICT (user_id, guardian_id) DO UPDATE SET is_primary = EXCLUDED.is_primary
         RETURNING id, is_primary`,
        [req.userId, guardianId, is_primary ?? false]
      );
      await client.query('COMMIT');
      return res.status(201).json({ success: true, link: link.rows[0], guardianId });
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  } catch (err) { next(err); }
});

// DELETE /guardians/:id — remove guardian link
router.delete('/:id', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid id.' });
    const result = await pool.query(
      'DELETE FROM user_guardians WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, req.userId]
    );
    if (result.rowCount === 0) return res.status(404).json({ success: false, message: 'Not found.' });
    return res.json({ success: true });
  } catch (err) { next(err); }
});

// PATCH /guardians/:id/set-primary — set one guardian as primary
router.patch('/:id/set-primary', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid id.' });
    await pool.query('UPDATE user_guardians SET is_primary=false WHERE user_id=$1', [req.userId]);
    const result = await pool.query(
      'UPDATE user_guardians SET is_primary=true WHERE id=$1 AND user_id=$2 RETURNING id',
      [id, req.userId]
    );
    if (result.rowCount === 0) return res.status(404).json({ success: false, message: 'Not found.' });
    return res.json({ success: true });
  } catch (err) { next(err); }
});

module.exports = router;
