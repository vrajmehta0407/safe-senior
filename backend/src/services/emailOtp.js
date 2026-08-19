'use strict';

/**
 * Email OTP delivery service.
 *
 * DEV MODE  (SMTP_USER not set):
 *   Prints the OTP to the console.
 *
 * PRODUCTION:
 *   Sends via Gmail SMTP (or any SMTP).
 *
 *  Required .env vars for Gmail:
 *   SMTP_HOST=smtp.gmail.com
 *   SMTP_PORT=587
 *   SMTP_USER=yourapp@gmail.com
 *   SMTP_PASS=your_gmail_app_password
 *   EMAIL_FROM="Safe Senior <yourapp@gmail.com>"
 */

const purposeLabels = {
  '2fa':   'Two-Factor Authentication',
  'login': 'Login Verification',
  'reset': 'Password Reset',
};

async function sendEmailOtp(email, otp, purpose) {
  const smtpUser = process.env.SMTP_USER;
  const label    = purposeLabels[purpose] || 'Verification';

  // ─── DEV / MOCK MODE ──────────────────────────────────────────────────────
  if (!smtpUser || smtpUser === 'mock') {
    console.log(`
╔══════════════════════════════════════════╗
║        [DEV] EMAIL OTP SENT              ║
║  To      : ${email.padEnd(29)}║
║  Purpose : ${label.padEnd(29)}║
║  Code    : ${String(otp).padEnd(29)}║
║  (Copy this code into the app)           ║
╚══════════════════════════════════════════╝
`);
    return { dev: true };
  }

  // ─── PRODUCTION SMTP ──────────────────────────────────────────────────────
  let nodemailer;
  try {
    nodemailer = require('nodemailer');
  } catch {
    throw new Error('nodemailer not installed. Run: npm install nodemailer');
  }

  const transporter = nodemailer.createTransport({
    host:   process.env.SMTP_HOST   || 'smtp.gmail.com',
    port:   parseInt(process.env.SMTP_PORT || '587', 10),
    secure: process.env.SMTP_PORT   === '465',
    auth: {
      user: smtpUser,
      pass: process.env.SMTP_PASS,
    },
  });

  await transporter.sendMail({
    from:    process.env.EMAIL_FROM || `"Safe Senior" <${smtpUser}>`,
    to:      email,
    subject: `${otp} is your Safe Senior ${label} code`,
    html: `
      <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px;background:#f5f7fa;border-radius:16px;">
        <div style="background:linear-gradient(135deg,#143B66,#5A94E8);padding:20px;border-radius:12px;text-align:center;margin-bottom:24px;">
          <span style="font-size:32px;">🔐</span>
          <h2 style="color:#fff;margin:8px 0 0;font-size:20px;">Safe Senior</h2>
        </div>
        <h3 style="color:#143B66;margin:0 0 8px;">${label}</h3>
        <p style="color:#555;font-size:14px;margin:0 0 24px;">
          Use the code below to complete your verification. It expires in <strong>8 minutes</strong>.
          Never share this code with anyone.
        </p>
        <div style="background:#fff;border:2px solid #5A94E8;border-radius:12px;text-align:center;padding:24px;margin-bottom:24px;">
          <span style="font-size:48px;font-weight:800;letter-spacing:12px;color:#143B66;">${otp}</span>
        </div>
        <p style="color:#999;font-size:12px;text-align:center;">
          If you did not request this, please ignore this email or contact support.
        </p>
        <hr style="border:none;border-top:1px solid #eee;margin:16px 0;"/>
        <p style="color:#bbb;font-size:11px;text-align:center;">
          Safe Senior – Protecting seniors from digital scams.
        </p>
      </div>
    `,
    text: `Your Safe Senior ${label} code is: ${otp}\n\nThis code expires in 8 minutes.\n\nIf you did not request this, please ignore.`,
  });

  return { sent: true };
}

module.exports = { sendEmailOtp };
