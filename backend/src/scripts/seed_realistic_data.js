'use strict';

/**
 * Seed realistic production-grade database records for SafeSenior
 * Creates authentic Indian senior citizens, linked guardians,
 * threat patterns, scam reports, and superadmin account.
 */

const bcrypt = require('bcryptjs');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/safesenior',
});

async function runSeed() {
  const client = await pool.connect();
  try {
    console.log('--- Starting SafeSenior Real Database Seeding ---');

    await client.query('BEGIN');

    // 1. Ensure SuperAdmin Accounts
    const defaultPassword = 'Admin@SafeSenior2026!';
    const passwordHash = await bcrypt.hash(defaultPassword, 12);

    const adminsToSeed = [
      { name: 'Security Lead (Vraj)', email: 'admin@safesenior.org', role: 'superadmin' },
      { name: 'Ops Admin', email: 'admin@safesenior.app', role: 'superadmin' },
      { name: 'Vraj Mehta', email: 'vrajmehta0407@gmail.com', role: 'superadmin' },
    ];

    for (const adm of adminsToSeed) {
      await client.query(
        `INSERT INTO admins (name, email, password_hash, role, is_active, totp_enabled)
         VALUES ($1, $2, $3, $4, true, false)
         ON CONFLICT (email) DO UPDATE
         SET password_hash = EXCLUDED.password_hash, is_active = true, role = EXCLUDED.role`,
        [adm.name, adm.email, passwordHash, adm.role]
      );
      console.log(`[Admin] Ensured admin account: ${adm.email}`);
    }

    // 2. Realistic Indian Senior Citizen Users
    const userPassHash = await bcrypt.hash('Senior@Safe2026!', 10);
    const seniors = [
      { name: 'Shanti Patel', phone: '+919825014820', email: 'shanti.patel38@gmail.com', suspended: false },
      { name: 'Ramesh Sharma', phone: '+919811059281', email: 'ramesh.sharma1944@outlook.com', suspended: false },
      { name: 'Anandi Deshmukh', phone: '+919820144829', email: 'anandi.deshmukh@yahoo.in', suspended: false },
      { name: 'Harish Verma', phone: '+919845012890', email: 'harish.verma@rediffmail.com', suspended: false },
      { name: 'K. Narayanaswamy', phone: '+919840177310', email: 'k.narayana1947@gmail.com', suspended: false },
      { name: 'Savitri Devi', phone: '+919450022819', email: 'savitri.devi.up@gmail.com', suspended: false },
      { name: 'Dr. Kirit Parikh', phone: '+919824255104', email: 'kirit.parikh.pharma@gmail.com', suspended: false },
      { name: 'Manjula Ben Joshi', phone: '+919879100482', email: 'manjula.joshi1952@gmail.com', suspended: false },
    ];

    const userIdMap = {};

    for (const s of seniors) {
      const res = await client.query(
        `INSERT INTO users (name, phone_number, email, password_hash, is_suspended, created_at)
         VALUES ($1, $2, $3, $4, $5, NOW() - (INTERVAL '1 day' * (RANDOM() * 30)))
         ON CONFLICT (phone_number) DO UPDATE
         SET name = EXCLUDED.name, email = EXCLUDED.email, is_suspended = EXCLUDED.is_suspended
         RETURNING id, name, phone_number`,
        [s.name, s.phone, s.email, userPassHash, s.suspended]
      );
      userIdMap[s.phone] = res.rows[0].id;
      console.log(`[User] Senior registered: ${s.name} (ID: ${res.rows[0].id})`);
    }

    // 3. Link Real Guardians
    const guardianData = [
      { userPhone: '+919825014820', name: 'Amit Patel', phone: '+919824088219', rel: 'Son' },
      { userPhone: '+919811059281', name: 'Neha Sharma', phone: '+919810012399', rel: 'Daughter' },
      { userPhone: '+919820144829', name: 'Rohan Deshmukh', phone: '+919820077889', rel: 'Son' },
      { userPhone: '+919845012890', name: 'Vikram Verma', phone: '+919845588211', rel: 'Son' },
      { userPhone: '+919840177310', name: 'Sundar Narayanan', phone: '+919840099112', rel: 'Son' },
      { userPhone: '+919450022819', name: 'Alok Kumar Srivastava', phone: '+919415088201', rel: 'Son' },
      { userPhone: '+919824255104', name: 'Darshan Parikh', phone: '+919824199200', rel: 'Son' },
      { userPhone: '+919879100482', name: 'Bhavin Joshi', phone: '+919879555219', rel: 'Son' },
    ];

    for (const g of guardianData) {
      const uId = userIdMap[g.userPhone];
      if (uId) {
        const gRes = await client.query(
          `INSERT INTO guardians (user_id, name, phone_number, relationship)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (user_id) DO UPDATE
           SET name = EXCLUDED.name, phone_number = EXCLUDED.phone_number, relationship = EXCLUDED.relationship
           RETURNING id`,
          [uId, g.name, g.phone, g.rel]
        );
        const gId = gRes.rows[0].id;
        await client.query('UPDATE users SET guardian_id = $1 WHERE id = $2', [gId, uId]);
        
        // Also insert into user_guardians
        await client.query(
          `INSERT INTO user_guardians (user_id, guardian_id, is_primary)
           VALUES ($1, $2, true)
           ON CONFLICT (user_id, guardian_id) DO UPDATE SET is_primary = true`,
          [uId, gId]
        );
        console.log(`[Guardian] Linked ${g.name} (${g.rel}) to User ID ${uId}`);
      }
    }

    // 4. Authentic Indian Scam Reports
    const scamReports = [
      {
        userPhone: '+919845012890',
        type: 'call',
        sender: '+919845001928',
        classification: 'high-risk',
        body_preview: '🚨 Digital Arrest Extortion: Caller claimed to be DCP Cyber Cell Mumbai. Stated Aadhaar was found in FedEx narcotics parcel to Taiwan. Demanded ₹3,50,000 RTGS verification deposit.',
      },
      {
        userPhone: '+919811059281',
        type: 'sms',
        sender: '+919876543210',
        classification: 'high-risk',
        body_preview: 'Dear consumer, your electricity power supply will be disconnected tonight at 9:30 PM by BSES/MSEDCL due to previous bill unpaid. Call electricity officer at 9876543210 or install quick-pay.apk.',
      },
      {
        userPhone: '+919820144829',
        type: 'sms',
        sender: '+919821099482',
        classification: 'high-risk',
        body_preview: 'Dear SBI User, your YONO account has been suspended today due to KYC expired. Click immediately to update PAN card: https://sbi-pan-kyc-verify.co.in to prevent permanent block.',
      },
      {
        userPhone: '+919825014820',
        type: 'call',
        sender: '+919824900192',
        classification: 'high-risk',
        body_preview: 'TRAI Urgent Disconnection Alert: Your mobile SIM number +919825014820 will be terminated within 2 hours by Telecom Regulatory Authority due to illegal advertisements. Press 9 to speak with police.',
      },
      {
        userPhone: '+919840177310',
        type: 'sms',
        sender: 'CP-PMKISAN',
        classification: 'suspicious',
        body_preview: 'PM Kisan 18th Kist Installment: ₹2,000 pending in DBT account. Please verify Aadhaar OTP on http://pm-kisan-portal-yojana.link to claim subsidy payment.',
      },
      {
        userPhone: '+919450022819',
        type: 'sms',
        sender: 'VK-EPFIND',
        classification: 'high-risk',
        body_preview: 'Your EPFO Pension credit has been paused. Submit UAN passbook details and bank account on epfo-pension-kyc.top to release arrears of ₹38,400.',
      },
      {
        userPhone: '+919824255104',
        type: 'call',
        sender: '+919712033991',
        classification: 'high-risk',
        body_preview: 'Fake Customs Police Video Call: Posing as New Delhi Customs officer claiming seized courier containing MDMA drugs under doctor’s passport details. Urged video interrogation.',
      },
      {
        userPhone: '+919879100482',
        type: 'sms',
        sender: '+919898011223',
        classification: 'suspicious',
        body_preview: 'You have won ₹25,00,000 in KBC Jio Lucky Draw 2026. Send lottery manager processing fee of ₹12,500 on Google Pay number 9898011223 to collect cheque.',
      }
    ];

    for (const r of scamReports) {
      const uId = userIdMap[r.userPhone] || null;
      await client.query(
        `INSERT INTO scam_reports (user_id, type, sender, classification, body_preview, timestamp)
         VALUES ($1, $2, $3, $4, $5, NOW() - (INTERVAL '1 hour' * (RANDOM() * 72)))`,
        [uId, r.type, r.sender, r.classification, r.body_preview]
      );
      console.log(`[Scam Report] Intercepted ${r.type.toUpperCase()} from ${r.sender}`);
    }

    // 5. Authentic Administrative Audit Logs
    const superAdminRes = await client.query("SELECT id FROM admins WHERE email = 'admin@safesenior.org' LIMIT 1");
    const adminId = superAdminRes.rows[0].id;

    const auditEvents = [
      { action: 'login_success', targetType: 'admin_session', targetId: adminId, meta: { ip: '127.0.0.1', userAgent: 'Chrome/124.0 (Windows)' } },
      { action: 'pattern_deployed', targetType: 'scam_pattern', targetId: 1, meta: { category: 'Digital Arrest', rule: 'CBI / Mumbai Customs Impersonation Pattern' } },
      { action: 'user_geofence_verified', targetType: 'user', targetId: userIdMap['+919825014820'], meta: { zone: 'Navrangpura Home Safe Zone', status: 'Inside' } },
      { action: 'scam_quarantined', targetType: 'scam_report', targetId: 2, meta: { sender: '+919876543210', threat: 'Electricity Disconnection APK Trap' } },
      { action: 'guardian_escalation_sms_dispatched', targetType: 'guardian', targetId: 1, meta: { recipient: '+919824088219', alert: 'High risk call flagged' } },
      { action: 'carrier_filter_synced', targetType: 'telecom_dlt', targetId: null, meta: { provider: 'TRAI / DoT Gateway', syncedHeaders: 120 } },
    ];

    for (const a of auditEvents) {
      await client.query(
        `INSERT INTO admin_audit_log (admin_id, action, target_type, target_id, metadata, ip_address, created_at)
         VALUES ($1, $2, $3, $4, $5, '127.0.0.1', NOW() - (INTERVAL '1 hour' * (RANDOM() * 48)))`,
        [adminId, a.action, a.targetType, a.targetId, JSON.stringify(a.meta)]
      );
    }
    console.log('[Audit Log] Inserted administrative audit trails.');

    await client.query('COMMIT');
    console.log('✅ Real database seeding completed successfully!');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Seeding failed:', err);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

runSeed().catch(console.error);
