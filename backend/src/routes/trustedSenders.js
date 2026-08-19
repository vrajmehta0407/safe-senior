// routes/trustedSenders.js — CRUD for per-user trusted sender allowlist
const express = require('express');
const router  = express.Router();
const pool    = require('../db/pool');
const auth    = require('../middleware/auth');

// All routes require user auth
router.use(auth);

// GET /trusted-senders — list trusted senders for the current user
router.get('/', async (req, res, next) => {
  try {
    const result = await pool.query(
      'SELECT id, sender, label, created_at FROM trusted_senders WHERE user_id = $1 ORDER BY label',
      [req.userId]
    );
    return res.json({ success: true, trustedSenders: result.rows });
  } catch (err) { next(err); }
});

// POST /trusted-senders — add a trusted sender
router.post('/', async (req, res, next) => {
  try {
    const { sender, label } = req.body;
    if (!sender || typeof sender !== 'string' || sender.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'sender is required.' });
    }
    const result = await pool.query(
      `INSERT INTO trusted_senders (user_id, sender, label) VALUES ($1, $2, $3)
       ON CONFLICT (user_id, sender) DO UPDATE SET label = EXCLUDED.label
       RETURNING id, sender, label, created_at`,
      [req.userId, sender.trim().toUpperCase(), (label || sender).trim()]
    );
    return res.status(201).json({ success: true, trustedSender: result.rows[0] });
  } catch (err) { next(err); }
});

// DELETE /trusted-senders/:id — remove a trusted sender
router.delete('/:id', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid id.' });
    const result = await pool.query(
      'DELETE FROM trusted_senders WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, req.userId]
    );
    if (result.rowCount === 0) return res.status(404).json({ success: false, message: 'Not found.' });
    return res.json({ success: true });
  } catch (err) { next(err); }
});

module.exports = router;
