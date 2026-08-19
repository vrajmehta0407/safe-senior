'use strict';

const express        = require('express');
const pool           = require('../db/pool');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// ─── Bundled fallback (used ONLY if DB is unreachable) ───────────────────────
const BUNDLED_FALLBACK = [
  { pattern: 'Your KYC is expired. Update immediately or your account will be blocked. Call',                  type: 'sms',  severity: 'high-risk'  },
  { pattern: 'Congratulations! You have won a lottery of Rs. 25,00,000. Send OTP to claim',                   type: 'sms',  severity: 'high-risk'  },
  { pattern: 'Dear customer, your SBI account is suspended. Click here to verify',                             type: 'sms',  severity: 'high-risk'  },
  { pattern: 'URGENT: Your Aadhaar will be deactivated. Update via this link',                                 type: 'sms',  severity: 'high-risk'  },
  { pattern: 'Income Tax Department: Refund of Rs. is pending. Submit bank details at',                        type: 'sms',  severity: 'high-risk'  },
  { pattern: 'Your parcel is on hold at customs. Pay Rs. 250 handling fee to release',                         type: 'sms',  severity: 'high-risk'  },
  { pattern: 'OTP for transaction is. Never share this OTP with anyone including bank officials',              type: 'sms',  severity: 'suspicious' },
  { pattern: 'Your electricity connection will be disconnected tonight. Call this number immediately',         type: 'call', severity: 'high-risk'  },
  { pattern: 'CBI officer speaking. A case has been registered against your Aadhaar number',                  type: 'call', severity: 'high-risk'  },
  { pattern: 'Amazon Prime subscription renewing Rs. 1499. To cancel call',                                   type: 'call', severity: 'high-risk'  },
  { pattern: 'Your Google Pay account has been hacked. Verify with screen share',                             type: 'call', severity: 'high-risk'  },
  { pattern: 'Narcotics Control Bureau: Drug shipment linked to your mobile number',                          type: 'call', severity: 'high-risk'  },
  { pattern: 'TRAI is going to block your mobile number. Press 9 to speak with officer',                      type: 'call', severity: 'high-risk'  },
  { pattern: 'Microsoft support: Your computer has virus. Call immediately to fix remotely',                  type: 'call', severity: 'high-risk'  },
  { pattern: 'Police FIR registered against your number for cybercrime. Call to resolve',                     type: 'call', severity: 'high-risk'  },
];

// ─── GET /scam-patterns/active ───────────────────────────────────────────────
/**
 * Public read-only endpoint — Flutter app fetches this on startup/refresh.
 * Returns active patterns from DB + top community-reported senders.
 * Falls back to BUNDLED_FALLBACK if DB is unavailable.
 */
router.get('/active', async (req, res, next) => {
  try {
    const dbPatterns = await pool.query(
      `SELECT id, pattern, type, severity, category, language, updated_at
       FROM scam_patterns
       WHERE is_active = true
       ORDER BY severity DESC, updated_at DESC`
    );

    // Also merge top community-reported senders (last 90 days)
    const communityResult = await pool.query(
      `SELECT DISTINCT sender AS pattern, type, classification AS severity
       FROM scam_reports
       WHERE timestamp > NOW() - INTERVAL '90 days'
         AND classification IN ('suspicious', 'high-risk')
       ORDER BY classification DESC
       LIMIT 100`
    );

    // Merge — DB patterns first (authoritative), then community
    const seen   = new Set();
    const merged = [];

    for (const p of dbPatterns.rows) {
      const key = `${p.type}::${p.pattern}`;
      if (!seen.has(key)) { seen.add(key); merged.push(p); }
    }
    for (const p of communityResult.rows) {
      const key = `${p.type}::${p.pattern}`;
      if (!seen.has(key)) { seen.add(key); merged.push(p); }
    }

    return res.status(200).json({
      success:   true,
      version:   `db-${dbPatterns.rowCount}`,
      patterns:  merged,
      updatedAt: new Date().toISOString(),
    });
  } catch (err) {
    // Graceful fallback — serve bundled list on DB failure
    console.error('[scam-patterns/active] DB error, serving fallback:', err.message);
    return res.status(200).json({
      success:   true,
      version:   'fallback-1.0.0',
      patterns:  BUNDLED_FALLBACK,
      updatedAt: new Date().toISOString(),
      _fallback: true,
    });
  }
});

// ─── GET /scam-patterns/latest ───────────────────────────────────────────────
// Keep backward compatibility — same response as /active
router.get('/latest', async (req, res, next) => {
  // Redirect internally to /active logic
  req.url = '/active';
  return router.handle(req, res, next);
});

// ─── POST /scam-patterns/report ──────────────────────────────────────────────
/**
 * Authenticated — user submits a scam report.
 * Body: { type, sender, classification, body_preview }
 */
router.post('/report', authMiddleware, async (req, res, next) => {
  try {
    const { type, sender, classification, body_preview } = req.body;

    if (!type || !sender || !classification) {
      return res.status(400).json({ success: false, message: 'type, sender, and classification are required.' });
    }
    if (!['sms', 'call'].includes(type)) {
      return res.status(400).json({ success: false, message: "type must be 'sms' or 'call'." });
    }
    if (!['safe', 'suspicious', 'high-risk'].includes(classification)) {
      return res.status(400).json({ success: false, message: "classification must be 'safe', 'suspicious', or 'high-risk'." });
    }

    const result = await pool.query(
      `INSERT INTO scam_reports (user_id, type, sender, classification, body_preview)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, user_id, type, sender, classification, body_preview, timestamp`,
      [req.userId, type, sender.trim(), classification, body_preview ? body_preview.trim() : null]
    );

    return res.status(201).json({ success: true, report: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
