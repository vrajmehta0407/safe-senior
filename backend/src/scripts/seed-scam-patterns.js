#!/usr/bin/env node
'use strict';

/**
 * One-off script: seed scam_patterns table from the bundled BUNDLED_PATTERNS list.
 * Safe to re-run — uses INSERT ... ON CONFLICT DO NOTHING.
 *
 * Usage:
 *   node src/scripts/seed-scam-patterns.js
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

const BUNDLED_PATTERNS = [
  { pattern: 'Your KYC is expired. Update immediately or your account will be blocked. Call',                  type: 'sms',  severity: 'high-risk',  category: 'kyc_fraud' },
  { pattern: 'Congratulations! You have won a lottery of Rs. 25,00,000. Send OTP to claim',                   type: 'sms',  severity: 'high-risk',  category: 'lottery_fraud' },
  { pattern: 'Dear customer, your SBI account is suspended. Click here to verify',                             type: 'sms',  severity: 'high-risk',  category: 'bank_fraud' },
  { pattern: 'URGENT: Your Aadhaar will be deactivated. Update via this link',                                 type: 'sms',  severity: 'high-risk',  category: 'identity_fraud' },
  { pattern: 'Income Tax Department: Refund of Rs. is pending. Submit bank details at',                        type: 'sms',  severity: 'high-risk',  category: 'govt_impersonation' },
  { pattern: 'Your parcel is on hold at customs. Pay Rs. 250 handling fee to release',                         type: 'sms',  severity: 'high-risk',  category: 'delivery_fraud' },
  { pattern: 'OTP for transaction is. Never share this OTP with anyone including bank officials',              type: 'sms',  severity: 'suspicious', category: 'otp_phishing' },
  { pattern: 'Your electricity connection will be disconnected tonight. Call this number immediately',         type: 'call', severity: 'high-risk',  category: 'utility_fraud' },
  { pattern: 'CBI officer speaking. A case has been registered against your Aadhaar number',                  type: 'call', severity: 'high-risk',  category: 'govt_impersonation' },
  { pattern: 'Amazon Prime subscription renewing Rs. 1499. To cancel call',                                   type: 'call', severity: 'high-risk',  category: 'subscription_fraud' },
  { pattern: 'Your Google Pay account has been hacked. Verify with screen share',                             type: 'call', severity: 'high-risk',  category: 'payment_fraud' },
  { pattern: 'Narcotics Control Bureau: Drug shipment linked to your mobile number',                          type: 'call', severity: 'high-risk',  category: 'govt_impersonation' },
  { pattern: 'You are selected for work from home job. Earn Rs. 5000 daily. Registration fee',                type: 'sms',  severity: 'high-risk',  category: 'job_fraud' },
  { pattern: 'Your loan is approved. Pay processing fee of Rs. 2000 to disburse funds',                       type: 'sms',  severity: 'high-risk',  category: 'loan_fraud' },
  { pattern: 'TRAI is going to block your mobile number. Press 9 to speak with officer',                      type: 'call', severity: 'high-risk',  category: 'govt_impersonation' },
  { pattern: 'Dear user your account will be blocked click the link to update PAN card details',              type: 'sms',  severity: 'high-risk',  category: 'identity_fraud' },
  { pattern: 'Refund initiated for your recent purchase. Share OTP received on your number to process',       type: 'call', severity: 'high-risk',  category: 'otp_phishing' },
  { pattern: 'Free recharge offer! Click link to get Rs. 599 recharge. Valid till tonight only',              type: 'sms',  severity: 'suspicious', category: 'fake_offer' },
  { pattern: 'Your mutual fund investment has grown. Withdraw profit now. Link expires in 24 hours',          type: 'sms',  severity: 'suspicious', category: 'investment_fraud' },
  { pattern: 'Job offer: Rs. 50000 salary. Work from home. Pay Rs. 500 registration fee to join',            type: 'sms',  severity: 'high-risk',  category: 'job_fraud' },
  { pattern: 'Microsoft support: Your computer has virus. Call immediately to fix remotely',                  type: 'call', severity: 'high-risk',  category: 'tech_support_fraud' },
  { pattern: 'Your Jio/Airtel SIM will expire. Update documents via link to avoid disconnection',             type: 'sms',  severity: 'suspicious', category: 'telecom_fraud' },
  { pattern: 'Police FIR registered against your number for cybercrime. Call to resolve',                     type: 'call', severity: 'high-risk',  category: 'govt_impersonation' },
  { pattern: 'Cashback of Rs. 2000 credited to your Paytm. Verify mobile number to withdraw',                type: 'sms',  severity: 'suspicious', category: 'payment_fraud' },
  { pattern: 'Your credit card has been charged Rs. 8999. If not you call our helpline now',                  type: 'sms',  severity: 'suspicious', category: 'bank_fraud' },
];

async function main() {
  console.log('\n╔══════════════════════════════════════════╗');
  console.log('║  Safe Senior — Seed Scam Patterns        ║');
  console.log('╚══════════════════════════════════════════╝\n');

  await pool.query('SELECT 1'); // verify connection
  console.log('✓ Connected to PostgreSQL\n');

  let inserted = 0;
  let skipped  = 0;

  for (const p of BUNDLED_PATTERNS) {
    const result = await pool.query(
      `INSERT INTO scam_patterns (pattern, type, severity, category, source, language)
       VALUES ($1, $2, $3, $4, 'bundled', 'en')
       ON CONFLICT DO NOTHING
       RETURNING id`,
      [p.pattern, p.type, p.severity, p.category || null]
    );
    if (result.rowCount > 0) { inserted++; } else { skipped++; }
  }

  console.log(`✓ Seeded: ${inserted} patterns inserted, ${skipped} already existed.`);
  await pool.end();
}

main().catch((err) => {
  console.error('✗ Fatal error:', err.message);
  process.exit(1);
});
