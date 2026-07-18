'use strict';

const express        = require('express');
const pool           = require('../db/pool');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// ─── Bundled scam patterns ────────────────────────────────────────────────────
// 25 real-world Indian scam patterns commonly seen in SMS/call fraud.

const BUNDLED_PATTERNS = [
  { pattern: 'Your KYC is expired. Update immediately or your account will be blocked. Call',                   type: 'sms',  severity: 'high-risk' },
  { pattern: 'Congratulations! You have won a lottery of Rs. 25,00,000. Send OTP to claim',                    type: 'sms',  severity: 'high-risk' },
  { pattern: 'Dear customer, your SBI account is suspended. Click here to verify',                              type: 'sms',  severity: 'high-risk' },
  { pattern: 'URGENT: Your Aadhaar will be deactivated. Update via this link',                                  type: 'sms',  severity: 'high-risk' },
  { pattern: 'Income Tax Department: Refund of Rs. is pending. Submit bank details at',                         type: 'sms',  severity: 'high-risk' },
  { pattern: 'Your parcel is on hold at customs. Pay Rs. 250 handling fee to release',                          type: 'sms',  severity: 'high-risk' },
  { pattern: 'OTP for transaction is. Never share this OTP with anyone including bank officials',               type: 'sms',  severity: 'suspicious' },
  { pattern: 'Your electricity connection will be disconnected tonight. Call this number immediately',           type: 'call', severity: 'high-risk' },
  { pattern: 'CBI officer speaking. A case has been registered against your Aadhaar number',                   type: 'call', severity: 'high-risk' },
  { pattern: 'Amazon Prime subscription renewing Rs. 1499. To cancel call',                                    type: 'call', severity: 'high-risk' },
  { pattern: 'Your Google Pay account has been hacked. Verify with screen share',                              type: 'call', severity: 'high-risk' },
  { pattern: 'Narcotics Control Bureau: Drug shipment linked to your mobile number',                           type: 'call', severity: 'high-risk' },
  { pattern: 'You are selected for work from home job. Earn Rs. 5000 daily. Registration fee',                 type: 'sms',  severity: 'high-risk' },
  { pattern: 'Your loan is approved. Pay processing fee of Rs. 2000 to disburse funds',                        type: 'sms',  severity: 'high-risk' },
  { pattern: 'TRAI is going to block your mobile number. Press 9 to speak with officer',                       type: 'call', severity: 'high-risk' },
  { pattern: 'Dear user your account will be blocked click the link to update PAN card details',               type: 'sms',  severity: 'high-risk' },
  { pattern: 'Refund initiated for your recent purchase. Share OTP received on your number to process',        type: 'call', severity: 'high-risk' },
  { pattern: 'Free recharge offer! Click link to get Rs. 599 recharge. Valid till tonight only',               type: 'sms',  severity: 'suspicious' },
  { pattern: 'Your mutual fund investment has grown. Withdraw profit now. Link expires in 24 hours',           type: 'sms',  severity: 'suspicious' },
  { pattern: 'Job offer: Rs. 50000 salary. Work from home. Pay Rs. 500 registration fee to join',             type: 'sms',  severity: 'high-risk' },
  { pattern: 'Microsoft support: Your computer has virus. Call immediately to fix remotely',                   type: 'call', severity: 'high-risk' },
  { pattern: 'Your Jio/Airtel SIM will expire. Update documents via link to avoid disconnection',              type: 'sms',  severity: 'suspicious' },
  { pattern: 'Police FIR registered against your number for cybercrime. Call to resolve',                      type: 'call', severity: 'high-risk' },
  { pattern: 'Cashback of Rs. 2000 credited to your Paytm. Verify mobile number to withdraw',                 type: 'sms',  severity: 'suspicious' },
  { pattern: 'Your credit card has been charged Rs. 8999. If not you call our helpline now',                   type: 'sms',  severity: 'suspicious' },
];

// ─── GET /scam-patterns/latest ───────────────────────────────────────────────
/**
 * Returns the combined scam pattern list:
 * bundled static patterns + unique senders from recent scam_reports.
 * Public endpoint — no auth required.
 */
router.get('/latest', async (req, res, next) => {
  try {
    // Fetch distinct reported patterns from the last 90 days
    const dbResult = await pool.query(
      `SELECT DISTINCT sender, type, classification
       FROM scam_reports
       WHERE timestamp > NOW() - INTERVAL '90 days'
         AND classification IN ('suspicious', 'high-risk')
       ORDER BY classification DESC
       LIMIT 200`
    );

    // Convert DB rows into the pattern shape
    const dbPatterns = dbResult.rows.map((row) => ({
      pattern:  row.sender,
      type:     row.type,
      severity: row.classification,
    }));

    // Merge: bundled first, then community-reported (dedup by pattern string)
    const seen    = new Set();
    const merged  = [];

    for (const p of [...BUNDLED_PATTERNS, ...dbPatterns]) {
      const key = `${p.type}::${p.pattern}`;
      if (!seen.has(key)) {
        seen.add(key);
        merged.push(p);
      }
    }

    return res.status(200).json({
      success:   true,
      version:   '1.0.0',
      patterns:  merged,
      updatedAt: new Date().toISOString(),
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /scam-patterns/report ──────────────────────────────────────────────
/**
 * Submit a user-reported scam message/call.
 * Requires authentication.
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
