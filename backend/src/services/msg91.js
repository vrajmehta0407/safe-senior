'use strict';

const axios = require('axios');

/**
 * Sends an OTP via MSG91's Send OTP API.
 *
 * @param {string} phone - Mobile number with country code (e.g. "919876543210")
 * @param {string} otp   - 6-digit OTP string
 * @returns {Promise<object>} MSG91 response data
 * @throws {Error} If the API call fails
 */
async function sendOtp(phone, otp) {
  const authKey    = process.env.MSG91_AUTH_KEY;
  const templateId = process.env.MSG91_TEMPLATE_ID;
  const senderId   = process.env.MSG91_SENDER_ID || 'SAFESNR';

  if (!authKey || !templateId) {
    throw new Error('MSG91 configuration missing: MSG91_AUTH_KEY and MSG91_TEMPLATE_ID are required');
  }

  // Normalise: strip leading + if present, ensure country code prefix
  const mobile = phone.replace(/^\+/, '');

  const response = await axios.post(
    'https://control.msg91.com/api/v5/otp',
    {
      template_id: templateId,
      mobile,
      otp,
      sender:  senderId,
    },
    {
      headers: {
        authkey:       authKey,
        'Content-Type': 'application/json',
        Accept:         'application/json',
      },
      timeout: 10000, // 10 s
    }
  );

  if (response.data && response.data.type === 'error') {
    throw new Error(`MSG91 error: ${response.data.message || 'Unknown error'}`);
  }

  return response.data;
}

module.exports = { sendOtp };
