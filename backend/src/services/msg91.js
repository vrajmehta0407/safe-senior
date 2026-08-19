/**
 * MSG91 has been removed from Safe Senior.
 *
 * Decision: All OTP delivery now goes through email (emailOtp.js) using
 * Gmail SMTP + nodemailer. This is simpler, avoids a third-party SMS
 * dependency, and works fine given that users register with an email address.
 *
 * If phone-based SMS OTP is required in a future version:
 *  1. Create a real MSG91 account and get auth_key + approved template.
 *  2. Set MSG91_AUTH_KEY, MSG91_TEMPLATE_ID, MSG91_SENDER_ID in .env.
 *  3. Replace this file with actual MSG91 HTTP API calls.
 *  4. Update auth.js to route to sendSmsOtp() vs sendEmailOtp() based on
 *     whether the identifier looks like an email or a phone number.
 *
 * This file is kept as a tombstone so any accidental require() calls
 * fail loudly instead of silently.
 */

async function sendOtp() {
  throw new Error(
    '[msg91] MSG91 has been removed. Use emailOtp.sendEmailOtp() instead.'
  );
}

module.exports = { sendOtp };
