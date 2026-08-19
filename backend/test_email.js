const nodemailer = require('nodemailer');

async function main() {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'vrajmehta0407@gmail.com',
      pass: 'rcjjobumdutrbdmh'
    }
  });

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  console.log(`[test] Authenticating as vrajmehta0407@gmail.com ...`);
  console.log(`[test] Sending live Email OTP ${otp} to vrajmehta934@gmail.com ...`);

  try {
    const info = await transporter.sendMail({
      from: '"SafeSenior" <vrajmehta0407@gmail.com>',
      to: 'vrajmehta934@gmail.com',
      subject: `${otp} is your SafeSenior Verification Code`,
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px;background:#FBF9F9;border-radius:16px;border:1px solid #E3E2E2;">
          <div style="background:#006565;padding:20px;border-radius:12px;text-align:center;margin-bottom:24px;">
            <h2 style="color:#ffffff;margin:0;font-size:22px;">SafeSenior Verification</h2>
          </div>
          <h3 style="color:#1B1C1C;margin:0 0 8px;">Login Verification</h3>
          <p style="color:#3E4949;font-size:15px;margin:0 0 24px;">
            Hello Vraj, use the secure 6-digit code below to complete your verification in SafeSenior. It is valid for <strong>10 minutes</strong>.
            Never share this OTP with anyone.
          </p>
          <div style="background:#ffffff;border:2px solid #008080;border-radius:12px;text-align:center;padding:20px;margin-bottom:24px;">
            <span style="font-size:42px;font-weight:800;letter-spacing:8px;color:#006565;">${otp}</span>
          </div>
          <p style="color:#6E7979;font-size:12px;text-align:center;">
            SafeSenior – Digital Shield & Scam Neutralization Platform
          </p>
        </div>
      `
    });
    console.log('✅ EMAIL DELIVERED SUCCESSFULLY TO vrajmehta934@gmail.com!');
    console.log('Message ID:', info.messageId);
    console.log('Response:', info.response);
  } catch (err) {
    console.error('❌ Error sending mail:', err);
  }
}

main();
