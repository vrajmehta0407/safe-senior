'use strict';

const express        = require('express');
const pool           = require('../db/pool');
const authMiddleware = require('../middleware/auth');
const { publicRateLimiter, authenticatedRateLimiter } = require('../middleware/rateLimit');

const router = express.Router();

// ─── Bundled fallback (used ONLY if DB is unreachable) ───────────────────────
const BUNDLED_FALLBACK = [
  { id: 1,  pattern: 'Your KYC is expired. Update immediately or your account will be blocked. Call',                  pattern_text: 'Your KYC is expired. Update immediately or your account will be blocked. Call',                  type: 'sms',  severity: 'high-risk'  },
  { id: 2,  pattern: 'Congratulations! You have won a lottery of Rs. 25,00,000. Send OTP to claim',                   pattern_text: 'Congratulations! You have won a lottery of Rs. 25,00,000. Send OTP to claim',                   type: 'sms',  severity: 'high-risk'  },
  { id: 3,  pattern: 'Dear customer, your SBI account is suspended. Click here to verify',                             pattern_text: 'Dear customer, your SBI account is suspended. Click here to verify',                             type: 'sms',  severity: 'high-risk'  },
  { id: 4,  pattern: 'URGENT: Your Aadhaar will be deactivated. Update via this link',                                 pattern_text: 'URGENT: Your Aadhaar will be deactivated. Update via this link',                                 type: 'sms',  severity: 'high-risk'  },
  { id: 5,  pattern: 'Income Tax Department: Refund of Rs. is pending. Submit bank details at',                        pattern_text: 'Income Tax Department: Refund of Rs. is pending. Submit bank details at',                        type: 'sms',  severity: 'high-risk'  },
  { id: 6,  pattern: 'Your parcel is on hold at customs. Pay Rs. 250 handling fee to release',                         pattern_text: 'Your parcel is on hold at customs. Pay Rs. 250 handling fee to release',                         type: 'sms',  severity: 'high-risk'  },
  { id: 7,  pattern: 'OTP for transaction is. Never share this OTP with anyone including bank officials',              pattern_text: 'OTP for transaction is. Never share this OTP with anyone including bank officials',              type: 'sms',  severity: 'suspicious' },
  { id: 8,  pattern: 'Your electricity connection will be disconnected tonight. Call this number immediately',         pattern_text: 'Your electricity connection will be disconnected tonight. Call this number immediately',         type: 'call', severity: 'high-risk'  },
  { id: 9,  pattern: 'CBI officer speaking. A case has been registered against your Aadhaar number',                  pattern_text: 'CBI officer speaking. A case has been registered against your Aadhaar number',                  type: 'call', severity: 'high-risk'  },
  { id: 10, pattern: 'Amazon Prime subscription renewing Rs. 1499. To cancel call',                                   pattern_text: 'Amazon Prime subscription renewing Rs. 1499. To cancel call',                                   type: 'call', severity: 'high-risk'  },
  { id: 11, pattern: 'Your Google Pay account has been hacked. Verify with screen share',                             pattern_text: 'Your Google Pay account has been hacked. Verify with screen share',                             type: 'call', severity: 'high-risk'  },
  { id: 12, pattern: 'Narcotics Control Bureau: Drug shipment linked to your mobile number',                          pattern_text: 'Narcotics Control Bureau: Drug shipment linked to your mobile number',                          type: 'call', severity: 'high-risk'  },
  { id: 13, pattern: 'TRAI is going to block your mobile number. Press 9 to speak with officer',                      pattern_text: 'TRAI is going to block your mobile number. Press 9 to speak with officer',                      type: 'call', severity: 'high-risk'  },
  { id: 14, pattern: 'Microsoft support: Your computer has virus. Call immediately to fix remotely',                  pattern_text: 'Microsoft support: Your computer has virus. Call immediately to fix remotely',                  type: 'call', severity: 'high-risk'  },
  { id: 15, pattern: 'Police FIR registered against your number for cybercrime. Call to resolve',                     pattern_text: 'Police FIR registered against your number for cybercrime. Call to resolve',                     type: 'call', severity: 'high-risk'  },
];

// ─── GET /scam-patterns/active & /scam-patterns/latest ────────────────────────
/**
 * Public read-only endpoint — Flutter app fetches this on startup/refresh.
 * Returns active patterns from DB + top community-reported senders.
 * Falls back to BUNDLED_FALLBACK if DB is unavailable.
 */
router.get(['/active', '/latest'], publicRateLimiter, async (req, res, next) => {
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
      if (!seen.has(key)) {
        seen.add(key);
        merged.push({
          ...p,
          pattern_text: p.pattern_text || p.pattern,
          pattern: p.pattern || p.pattern_text,
        });
      }
    }
    for (const [idx, p] of communityResult.rows.entries()) {
      const key = `${p.type}::${p.pattern}`;
      if (!seen.has(key)) {
        seen.add(key);
        merged.push({
          ...p,
          id: typeof p.id === 'number' ? p.id : (100000 + idx),
          pattern_text: p.pattern_text || p.pattern,
          pattern: p.pattern || p.pattern_text,
        });
      }
    }

    return res.status(200).json({
      success:   true,
      version:   `db-${dbPatterns.rowCount}`,
      patterns:  merged,
      updatedAt: new Date().toISOString(),
      latestBroadcast: getLatestBroadcast(),
    });
  } catch (err) {
    // Graceful fallback — serve bundled list on DB failure
    console.error('[scam-patterns/active] DB error, serving fallback:', err.message);
    return res.status(200).json({
      success:   true,
      version:   'fallback-1.0.0',
      patterns:  BUNDLED_FALLBACK,
      updatedAt: new Date().toISOString(),
      latestBroadcast: getLatestBroadcast(),
      _fallback: true,
    });
  }
});

// ─── In-memory broadcast beacon for dynamic pattern updates ─────────────────
let _latestBroadcast = null;

function setLatestBroadcast(broadcast) {
  _latestBroadcast = {
    ...broadcast,
    timestamp: broadcast.timestamp || new Date().toISOString()
  };
}

function getLatestBroadcast() {
  return _latestBroadcast;
}

// ─── GET /scam-patterns/broadcast-status ────────────────────────────────────
/**
 * Lightweight endpoint polled by mobile endpoints to check for dynamic updates.
 */
router.get('/broadcast-status', publicRateLimiter, (req, res) => {
  return res.status(200).json({
    success: true,
    latestBroadcast: getLatestBroadcast(),
    checkedAt: new Date().toISOString(),
  });
});

// ─── POST /scam-patterns/report ──────────────────────────────────────────────
/**
 * Authenticated — user submits a scam report.
 * Body: { type, sender, classification, body_preview }
 */
router.post('/report', authMiddleware, authenticatedRateLimiter, async (req, res, next) => {
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
module.exports.setLatestBroadcast = setLatestBroadcast;
module.exports.getLatestBroadcast = getLatestBroadcast;
