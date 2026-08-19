'use strict';

/**
 * Android SMS Gateway — Service
 * https://github.com/capcom6/android-sms-gateway
 *
 * Sends OTP codes (and any other messages) via the Android SMS Gateway app.
 *
 * Two operating modes, controlled by env vars:
 *
 *   LOCAL mode  (SMS_GW_MODE=local)
 *     SMS_GW_URL      = http://<android-device-ip>:8080   (LAN endpoint)
 *     SMS_GW_USERNAME = username shown in the app
 *     SMS_GW_PASSWORD = password shown in the app
 *
 *   CLOUD mode  (SMS_GW_MODE=cloud  or not set → default)
 *     SMS_GW_URL      = https://api.sms-gate.app/3rdparty/v1  (default)
 *     SMS_GW_USERNAME = your sms-gate.app account login
 *     SMS_GW_PASSWORD = your sms-gate.app account password
 *
 * Set SMS_GW_MODE=mock to skip real delivery in dev (OTP prints to console).
 */

const fetch = (() => {
  // node-fetch or global fetch (Node 18+)
  try { return global.fetch; } catch (_) {}
  try { return require('node-fetch'); } catch (_) {}
  throw new Error('[smsGw] No fetch implementation found. Run: npm install node-fetch');
})();

// ── Config ────────────────────────────────────────────────────────────────────

const MODE = (process.env.SMS_GW_MODE || 'cloud').toLowerCase();

// Normalise base URL — strip trailing slash
const BASE_URL = (
  process.env.SMS_GW_URL ||
  (MODE === 'local'
    ? 'http://192.168.1.100:8080'          // placeholder — must be overridden
    : 'https://api.sms-gate.app/3rdparty/v1')
).replace(/\/$/, '');

const USERNAME  = process.env.SMS_GW_USERNAME  || '';
const PASSWORD  = process.env.SMS_GW_PASSWORD  || '';
const DEVICE_ID = process.env.SMS_GW_DEVICE_ID || '';

// ── Endpoint paths ────────────────────────────────────────────────────────────

/**
 * Returns the full URL for "send message".
 *   cloud : BASE_URL already includes /3rdparty/v1 → append /message
 *   local : BASE_URL is http://device:8080         → append /api/v1/message
 */
function sendMessageUrl() {
  if (MODE === 'local') {
    return `${BASE_URL}/api/v1/message`;
  }
  // cloud mode: api.sms-gate.app/3rdparty/v1/messages
  return `${BASE_URL}/messages`;
}

// ── Basic Auth header ─────────────────────────────────────────────────────────

function basicAuthHeader() {
  const creds = Buffer.from(`${USERNAME}:${PASSWORD}`).toString('base64');
  return `Basic ${creds}`;
}

// ── Phone number normalizer ───────────────────────────────────────────────────

/**
 * Normalise a phone number to E.164 format.
 * Rules (India-first, +91 default country code):
 *   "9879616132"   → "+919879616132"
 *   "09879616132"  → "+919879616132"  (leading 0 stripped)
 *   "+919879616132" → "+919879616132" (already E.164, untouched)
 *   "919879616132" → "+919879616132" (missing leading +)
 *   Spaces, dashes, parentheses are stripped first.
 */
function normalisePhone(raw) {
  // Strip all non-digit characters except leading +
  const stripped = String(raw || '').replace(/[\s\-().]/g, '');
  if (stripped.startsWith('+')) return stripped;        // already E.164
  if (stripped.startsWith('91') && stripped.length === 12) return '+' + stripped;
  if (stripped.startsWith('0')  && stripped.length === 11) return '+91' + stripped.slice(1);
  if (stripped.length === 10) return '+91' + stripped;  // bare 10-digit Indian number
  // Unknown format — prefix + and hope for the best
  return '+' + stripped;
}

// ── Core send function ────────────────────────────────────────────────────────

/**
 * Send an SMS via the Android SMS Gateway.
 *
 * @param {string|string[]} phoneNumbers  E.164 or local format, e.g. "+919876543210"
 * @param {string}          message       The SMS body
 * @returns {Promise<{ id: string, state: string }>}
 */
async function sendSms(phoneNumbers, message) {
  if (MODE === 'mock') {
    const numbers = Array.isArray(phoneNumbers) ? phoneNumbers : [phoneNumbers];
    console.log(`[smsGw:mock] → ${numbers.join(', ')} | "${message}"`);
    return { id: 'mock-' + Date.now(), state: 'Pending' };
  }

  if (!USERNAME || !PASSWORD) {
    throw new Error('[smsGw] SMS_GW_USERNAME and SMS_GW_PASSWORD must be set.');
  }

  const numbers = (Array.isArray(phoneNumbers) ? phoneNumbers : [phoneNumbers]).map(normalisePhone);
  const url     = sendMessageUrl();

  const body = {
    message,
    phoneNumbers: numbers,
    // Route through the specific registered device (required by sms-gate.app cloud API)
    ...(DEVICE_ID ? { deviceId: DEVICE_ID } : {}),
  };

  console.log(`[smsGw:${MODE}] POST ${url} → ${numbers.join(', ')}`);

  const response = await fetch(url, {
    method:  'POST',
    headers: {
      'Content-Type':  'application/json',
      'Authorization': basicAuthHeader(),
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorText = await response.text().catch(() => '');
    throw new Error(
      `[smsGw] API error ${response.status}: ${errorText || response.statusText}`
    );
  }

  const data = await response.json();
  console.log(`[smsGw] Message queued — id=${data.id} state=${data.state}`);
  return data;
}

// ── OTP helper ────────────────────────────────────────────────────────────────

const OTP_SUBJECTS = {
  login:        'Login OTP',
  '2fa':        'Two-Factor Authentication',
  reset:        'Password Reset',
  verification: 'Verification',
};

/**
 * Send a 6-digit OTP via SMS.
 *
 * @param {string} phoneNumber  Recipient phone number
 * @param {string} otp          The 6-digit code
 * @param {string} purpose      'login' | '2fa' | 'reset'
 */
async function sendSmsOtp(phoneNumber, otp, purpose = 'login') {
  const label   = OTP_SUBJECTS[purpose] || 'Verification';
  // Short, clear message — avoids carrier spam filters
  const message = `Safe Senior ${label}: ${otp} (valid 10 min). Do not share.`;
  return sendSms(phoneNumber, message);
}

// ── Exports ───────────────────────────────────────────────────────────────────

module.exports = { sendSms, sendSmsOtp, normalisePhone };
