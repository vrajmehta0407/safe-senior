require('dotenv').config();
const { sendSmsOtp } = require('./src/services/androidSmsGateway');

const phone = '+919879616132';
const otp = '725184';

console.log(`[test] User: ${process.env.SMS_GW_USERNAME}`);
console.log(`[test] Sending OTP ${otp} to ${phone} ...`);

sendSmsOtp(phone, otp, 'login')
  .then(async (r) => {
    console.log('✅ Queued — id:', r.id, '| deviceId:', r.deviceId);
    console.log('\nWaiting 10 seconds for delivery...');
    await new Promise(res => setTimeout(res, 10000));

    const auth = 'Basic ' + Buffer.from(`${process.env.SMS_GW_USERNAME}:${process.env.SMS_GW_PASSWORD}`).toString('base64');
    const s = await fetch(`${process.env.SMS_GW_URL}/message/${r.id}`, {
      headers: { 'Authorization': auth }
    }).then(x => x.json());

    console.log('\n📊 Final Delivery Report:');
    s.recipients?.forEach(rec => {
      const icon = rec.state === 'Delivered' ? '✅' : rec.state === 'Sent' ? '📤' : '❌';
      console.log(`${icon} ${rec.phoneNumber} → ${rec.state} ${rec.error ? '| ERROR: ' + rec.error : ''}`);
    });
    console.log('Timeline:', JSON.stringify(s.states, null, 2));
  })
  .catch(e => console.error('❌ FAILED:', e.message));
