require('dotenv').config();
const axios = require('axios');
const pool = require('./src/db/pool');
const bcrypt = require('bcryptjs');

async function testAuthAndPattern() {
  const BASE_URL = 'http://127.0.0.1:3000';
  const ADMIN_PREFIX = process.env.ADMIN_ROUTE_PREFIX || '/api/ops-4e9f2c1a';

  // 1. Check or set password for user id 3 to '040705'
  const userCheck = await pool.query('SELECT password_hash FROM users WHERE id = 3');
  const matches = await bcrypt.compare('040705', userCheck.rows[0].password_hash);
  console.log('User id 3 password matches 040705?', matches);
  if (!matches) {
    const hash = await bcrypt.hash('040705', 10);
    await pool.query('UPDATE users SET password_hash = $1 WHERE id = 3', [hash]);
    console.log('Updated user 3 password to 040705');
  }

  // 2. Also ensure login works with phone numbers '8866565480', '+918866565480', '88866565480'
  try {
    const userLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      phone_or_email: '+918866565480',
      password: '040705'
    });
    console.log('User login with +918866565480: SUCCESS, token acquired:', !!userLogin.data.token);
  } catch (e) {
    console.error('User login error:', e.response?.data || e.message);
  }

  try {
    const userLoginRaw = await axios.post(`${BASE_URL}/api/auth/login`, {
      phone_or_email: '8866565480',
      password: '040705'
    });
    console.log('User login with 8866565480: SUCCESS:', !!userLoginRaw.data.token);
  } catch (e) {
    console.error('User login with 8866565480 error:', e.response?.data || e.message);
  }

  // 3. Set a known admin password for admin id 1
  const adminHash = await bcrypt.hash('AdminPassword123!', 12);
  await pool.query('UPDATE admins SET password_hash = $1 WHERE id = 1', [adminHash]);
  console.log('Set admin id 1 password to AdminPassword123!');

  // 4. Log in as admin
  const adminLogin = await axios.post(`${BASE_URL}${ADMIN_PREFIX}/auth/login`, {
    email: 'admin@safesenior.local',
    password: 'AdminPassword123!'
  });
  console.log('Admin login: SUCCESS, token acquired:', !!adminLogin.data.token);
  const adminToken = adminLogin.data.token;

  // 5. Add new spam patterns via admin endpoint
  const newPattern1 = {
    pattern: 'Urgent Electricity Bill Notice: Power will be disconnected tonight at 9:30 PM due to unpaid balance. Contact Electricity Executive at 9876543210 immediately.',
    type: 'sms',
    severity: 'high-risk',
    category: 'Electricity Bill Scam',
    language: 'en',
    broadcast: true
  };

  const newPattern2 = {
    pattern: 'TRAI Alert: Your mobile SIM will be terminated within 2 hours by court order. Press 9 to connect with cyber police verification department.',
    type: 'call',
    severity: 'high-risk',
    category: 'Digital Arrest / TRAI Scam',
    language: 'en',
    broadcast: true
  };

  const res1 = await axios.post(`${BASE_URL}${ADMIN_PREFIX}/scam-patterns`, newPattern1, {
    headers: { Authorization: `Bearer ${adminToken}` }
  });
  console.log('Added pattern 1:', res1.data.success, res1.data.pattern.id, res1.data.broadcast);

  const res2 = await axios.post(`${BASE_URL}${ADMIN_PREFIX}/scam-patterns`, newPattern2, {
    headers: { Authorization: `Bearer ${adminToken}` }
  });
  console.log('Added pattern 2:', res2.data.success, res2.data.pattern.id, res2.data.broadcast);

  // 6. Verify GET /api/scam-patterns/active
  const activeRes = await axios.get(`${BASE_URL}/api/scam-patterns/active`);
  console.log('Active patterns count:', activeRes.data.patterns.length);
  console.log('Latest Broadcast beacon:', JSON.stringify(activeRes.data.latestBroadcast, null, 2));

  // 7. Verify GET /api/scam-patterns/broadcast-status
  const beaconRes = await axios.get(`${BASE_URL}/api/scam-patterns/broadcast-status`);
  console.log('Broadcast status endpoint:', JSON.stringify(beaconRes.data, null, 2));

  process.exit(0);
}

testAuthAndPattern().catch(err => {
  console.error('Error:', err.response?.data || err);
  process.exit(1);
});
