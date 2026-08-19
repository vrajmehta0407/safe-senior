'use strict';

const express = require('express');
const pool    = require('../db/pool');
const { adminAuthMiddleware: adminAuth, requireSuperAdmin } = require('../middleware/adminAuth');

const router = express.Router();

// ─── Shared audit helper ──────────────────────────────────────────────────────

async function auditLog({ adminId, action, targetType = null, targetId = null, metadata = null, ip }) {
  try {
    await pool.query(
      `INSERT INTO admin_audit_log (admin_id, action, target_type, target_id, metadata, ip_address)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [adminId, action, targetType, targetId, metadata ? JSON.stringify(metadata) : null, ip]
    );
  } catch (err) {
    console.error('[auditLog] Failed to write audit entry:', err.message);
  }
}

// ─── All routes require admin auth ───────────────────────────────────────────

router.use(adminAuth);


// ─── GET /stats/overview ──────────────────────────────────────────────────────

router.get('/stats/overview', async (req, res, next) => {
  try {
    const [users, scamReports, activeUsers, recentSignups, activePatterns, trustedSenders] = await Promise.all([
      pool.query('SELECT COUNT(*) FROM users'),
      pool.query('SELECT COUNT(*) FROM scam_reports'),
      pool.query('SELECT COUNT(*) FROM users WHERE is_suspended = false'),
      pool.query(`
        SELECT DATE(created_at) AS day, COUNT(*) AS signups
        FROM users
        WHERE created_at > NOW() - INTERVAL '30 days'
        GROUP BY day ORDER BY day DESC
      `),
      pool.query('SELECT COUNT(*) FROM scam_patterns WHERE is_active = true'),
      pool.query('SELECT COUNT(*) FROM trusted_senders').catch(() => ({ rows: [{ count: 0 }] })),
    ]);

    return res.status(200).json({
      success: true,
      stats: {
        totalUsers:           parseInt(users.rows[0].count, 10),
        totalScamReports:     parseInt(scamReports.rows[0].count, 10),
        activeUsers:          parseInt(activeUsers.rows[0].count, 10),
        signupsLast30Days:    recentSignups.rows,
        totalActivePatterns:  parseInt(activePatterns.rows[0].count, 10),
        totalTrustedSenders:  parseInt(trustedSenders.rows[0].count, 10),
      },
    });
  } catch (err) {
    next(err);
  }
});

// ─── GET /users ───────────────────────────────────────────────────────────────

router.get('/users', async (req, res, next) => {
  try {
    const limit  = Math.min(parseInt(req.query.limit  || '20', 10), 100);
    const offset = parseInt(req.query.offset || '0', 10);
    const search = req.query.search ? `%${req.query.search}%` : null;

    let query  = `SELECT id, name, email, phone_number, is_suspended, created_at FROM users`;
    let params = [];

    if (search) {
      query  += ` WHERE name ILIKE $1 OR email ILIKE $1 OR phone_number ILIKE $1`;
      params.push(search);
    }

    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);
    const countQ = search
      ? await pool.query(`SELECT COUNT(*) FROM users WHERE name ILIKE $1 OR email ILIKE $1 OR phone_number ILIKE $1`, [search])
      : await pool.query(`SELECT COUNT(*) FROM users`);

    return res.status(200).json({
      success: true,
      total:   parseInt(countQ.rows[0].count, 10),
      limit, offset,
      users:   result.rows,
    });
  } catch (err) {
    next(err);
  }
});

// ─── GET /users/:id ───────────────────────────────────────────────────────────

router.get('/users/:id', async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id, 10);
    if (isNaN(userId)) return res.status(400).json({ success: false, message: 'Invalid user ID.' });

    const [userResult, guardiansResult, scamResult] = await Promise.all([
      pool.query(
        `SELECT id, name, email, phone_number, is_suspended, created_at, guardian_id
         FROM users WHERE id = $1 LIMIT 1`,
        [userId]
      ),
      pool.query('SELECT * FROM guardians WHERE user_id = $1', [userId]),
      pool.query(
        `SELECT id, type, sender, classification, body_preview, timestamp
         FROM scam_reports WHERE user_id = $1 ORDER BY timestamp DESC LIMIT 50`,
        [userId]
      ),
    ]);

    if (userResult.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    return res.status(200).json({
      success: true,
      user:        userResult.rows[0],
      guardians:   guardiansResult.rows,
      scamReports: scamResult.rows,
    });
  } catch (err) {
    next(err);
  }
});

// ─── PATCH /users/:id ─────────────────────────────────────────────────────────
// Suspend or reactivate a user. Never allows password changes.

router.patch('/users/:id', async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id, 10);
    if (isNaN(userId)) return res.status(400).json({ success: false, message: 'Invalid user ID.' });

    const { is_suspended } = req.body;
    if (typeof is_suspended !== 'boolean') {
      return res.status(400).json({ success: false, message: 'is_suspended (boolean) is required.' });
    }

    const result = await pool.query(
      'UPDATE users SET is_suspended = $1 WHERE id = $2 RETURNING id, name, email, is_suspended',
      [is_suspended, userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    await auditLog({
      adminId:    req.admin.adminId,
      action:     is_suspended ? 'user_suspended' : 'user_reactivated',
      targetType: 'user',
      targetId:   userId,
      metadata:   { email: result.rows[0].email },
      ip:         req.ip,
    });

    return res.status(200).json({ success: true, user: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// ─── DELETE /users/:id ────────────────────────────────────────────────────────
// GDPR-style account deletion. Cascades per FK constraints in schema.

router.delete('/users/:id', async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id, 10);
    if (isNaN(userId)) return res.status(400).json({ success: false, message: 'Invalid user ID.' });

    // Snapshot user info before deletion for audit
    const snapshot = await pool.query('SELECT name, email FROM users WHERE id = $1', [userId]);
    if (snapshot.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    await pool.query('DELETE FROM users WHERE id = $1', [userId]);

    await auditLog({
      adminId:    req.admin.adminId,
      action:     'user_deleted',
      targetType: 'user',
      targetId:   userId,
      metadata:   snapshot.rows[0],
      ip:         req.ip,
    });

    return res.status(200).json({ success: true, message: 'User account deleted.' });
  } catch (err) {
    next(err);
  }
});

// ─── GET /scam-reports ────────────────────────────────────────────────────────

router.get('/scam-reports', async (req, res, next) => {
  try {
    const limit          = Math.min(parseInt(req.query.limit  || '50', 10), 200);
    const offset         = parseInt(req.query.offset || '0', 10);
    const classification = req.query.classification;
    const type           = req.query.type;

    let where  = [];
    let params = [];

    if (classification) { params.push(classification); where.push(`classification = $${params.length}`); }
    if (type)           { params.push(type);            where.push(`type = $${params.length}`); }

    const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';
    params.push(limit, offset);

    const result = await pool.query(
      `SELECT id, user_id, type, sender, classification, body_preview, timestamp
       FROM scam_reports ${whereClause}
       ORDER BY timestamp DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );

    const countParams = params.slice(0, -2);
    const countResult = await pool.query(
      `SELECT COUNT(*) FROM scam_reports ${whereClause}`,
      countParams
    );

    return res.status(200).json({
      success: true,
      total:   parseInt(countResult.rows[0].count, 10),
      limit, offset,
      reports: result.rows,
    });
  } catch (err) {
    next(err);
  }
});

// ─── GET /audit-log ───────────────────────────────────────────────────────────

router.get('/audit-log', async (req, res, next) => {
  try {
    const limit  = Math.min(parseInt(req.query.limit  || '50', 10), 200);
    const offset = parseInt(req.query.offset || '0', 10);

    const result = await pool.query(
      `SELECT l.id, l.action, l.target_type, l.target_id, l.metadata,
              l.ip_address, l.created_at,
              a.name AS admin_name, a.email AS admin_email
       FROM admin_audit_log l
       LEFT JOIN admins a ON a.id = l.admin_id
       ORDER BY l.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    const countResult = await pool.query('SELECT COUNT(*) FROM admin_audit_log');

    return res.status(200).json({
      success: true,
      total:   parseInt(countResult.rows[0].count, 10),
      limit, offset,
      entries: result.rows,
    });
  } catch (err) {
    next(err);
  }
});

// ─── POST /admins — create another admin (superadmin only) ───────────────────

router.post('/admins', requireSuperAdmin, async (req, res, next) => {
  try {
    const bcrypt = require('bcryptjs');
    const { name, email, password, role } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'name, email, and password are required.' });
    }
    if (password.length < 12) {
      return res.status(400).json({ success: false, message: 'Admin password must be at least 12 characters.' });
    }
    if (role && !['superadmin', 'support'].includes(role)) {
      return res.status(400).json({ success: false, message: 'role must be superadmin or support.' });
    }

    const existing = await pool.query('SELECT id FROM admins WHERE email = $1', [email.toLowerCase()]);
    if (existing.rowCount > 0) {
      return res.status(409).json({ success: false, message: 'Admin with this email already exists.' });
    }

    const password_hash = await bcrypt.hash(password, 12);
    const result = await pool.query(
      `INSERT INTO admins (name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, role, created_at`,
      [name.trim(), email.toLowerCase().trim(), password_hash, role || 'support']
    );

    await auditLog({
      adminId:    req.admin.adminId,
      action:     'admin_created',
      targetType: 'admin',
      targetId:   result.rows[0].id,
      metadata:   { email: result.rows[0].email, role: result.rows[0].role },
      ip:         req.ip,
    });

    return res.status(201).json({ success: true, admin: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// ─── GET /guardians ───────────────────────────────────────────────────────────

router.get('/guardians', async (req, res, next) => {
  try {
    const limit  = Math.min(parseInt(req.query.limit  || '50', 10), 200);
    const offset = parseInt(req.query.offset || '0', 10);
    const search = req.query.search ? `%${req.query.search}%` : null;

    let params = [];
    let where  = '';
    if (search) {
      params.push(search);
      where = `WHERE g.name ILIKE $1 OR g.phone_number ILIKE $1`;
    }

    params.push(limit, offset);
    const result = await pool.query(
      `SELECT g.id, g.name, g.phone_number, g.relationship, g.created_at,
              u.name AS user_name, u.email AS user_email, u.phone_number AS user_phone
       FROM guardians g
       JOIN users u ON u.id = g.user_id
       ${where}
       ORDER BY g.created_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );

    const countParams = search ? [search] : [];
    const countResult = await pool.query(
      `SELECT COUNT(*) FROM guardians g ${where}`,
      countParams
    );

    return res.status(200).json({
      success: true,
      total:   parseInt(countResult.rows[0].count, 10),
      limit, offset,
      guardians: result.rows,
    });
  } catch (err) {
    next(err);
  }
});

// ─── SCAM PATTERNS CRUD ───────────────────────────────────────────────────────

// GET /scam-patterns — paginated list for admin panel
router.get('/scam-patterns', async (req, res, next) => {
  try {
    const limit    = Math.min(parseInt(req.query.limit  || '50', 10), 200);
    const offset   = parseInt(req.query.offset || '0', 10);
    const severity = req.query.severity;
    const type     = req.query.type;
    const active   = req.query.active; // 'true' | 'false' | undefined

    let where  = [];
    let params = [];

    if (severity) { params.push(severity); where.push(`severity = $${params.length}`); }
    if (type)     { params.push(type);     where.push(`type = $${params.length}`); }
    if (active !== undefined) {
      params.push(active === 'true');
      where.push(`is_active = $${params.length}`);
    }

    const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';
    params.push(limit, offset);

    const result = await pool.query(
      `SELECT id, pattern, type, severity, category, language, is_active, source, created_at, updated_at
       FROM scam_patterns ${whereClause}
       ORDER BY severity DESC, created_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );

    const countParams2 = params.slice(0, -2);
    const countResult  = await pool.query(`SELECT COUNT(*) FROM scam_patterns ${whereClause}`, countParams2);

    return res.status(200).json({
      success: true,
      total:   parseInt(countResult.rows[0].count, 10),
      limit, offset,
      patterns: result.rows,
    });
  } catch (err) {
    next(err);
  }
});

// POST /scam-patterns — create a new pattern (admin-authored)
router.post('/scam-patterns', async (req, res, next) => {
  try {
    const { pattern, type, severity, category, language } = req.body;

    if (!pattern || !type || !severity) {
      return res.status(400).json({ success: false, message: 'pattern, type, and severity are required.' });
    }
    if (!['sms', 'call', 'both'].includes(type)) {
      return res.status(400).json({ success: false, message: "type must be 'sms', 'call', or 'both'." });
    }
    if (!['suspicious', 'high-risk'].includes(severity)) {
      return res.status(400).json({ success: false, message: "severity must be 'suspicious' or 'high-risk'." });
    }

    const result = await pool.query(
      `INSERT INTO scam_patterns (pattern, type, severity, category, language, source, created_by)
       VALUES ($1, $2, $3, $4, $5, 'admin', $6)
       RETURNING *`,
      [pattern.trim(), type, severity, category || null, language || 'en', req.admin.adminId]
    );

    await auditLog({
      adminId:    req.admin.adminId,
      action:     'scam_pattern_created',
      targetType: 'scam_pattern',
      targetId:   result.rows[0].id,
      metadata:   { pattern: pattern.trim().substring(0, 60), severity },
      ip:         req.ip,
    });

    return res.status(201).json({ success: true, pattern: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// PUT /scam-patterns/:id — update a pattern
router.put('/scam-patterns/:id', async (req, res, next) => {
  try {
    const patternId = parseInt(req.params.id, 10);
    if (isNaN(patternId)) return res.status(400).json({ success: false, message: 'Invalid pattern ID.' });

    const { pattern, type, severity, category, language, is_active } = req.body;

    const updates  = [];
    const params   = [];

    if (pattern   !== undefined) { params.push(pattern.trim());   updates.push(`pattern = $${params.length}`); }
    if (type      !== undefined) { params.push(type);             updates.push(`type = $${params.length}`); }
    if (severity  !== undefined) { params.push(severity);         updates.push(`severity = $${params.length}`); }
    if (category  !== undefined) { params.push(category);         updates.push(`category = $${params.length}`); }
    if (language  !== undefined) { params.push(language);         updates.push(`language = $${params.length}`); }
    if (is_active !== undefined) { params.push(is_active);        updates.push(`is_active = $${params.length}`); }

    if (updates.length === 0) {
      return res.status(400).json({ success: false, message: 'No fields to update.' });
    }

    params.push(new Date()); updates.push(`updated_at = $${params.length}`);
    params.push(patternId);

    const result = await pool.query(
      `UPDATE scam_patterns SET ${updates.join(', ')} WHERE id = $${params.length} RETURNING *`,
      params
    );

    if (result.rowCount === 0) return res.status(404).json({ success: false, message: 'Pattern not found.' });

    await auditLog({
      adminId:    req.admin.adminId,
      action:     'scam_pattern_updated',
      targetType: 'scam_pattern',
      targetId:   patternId,
      metadata:   req.body,
      ip:         req.ip,
    });

    return res.status(200).json({ success: true, pattern: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// DELETE /scam-patterns/:id — soft delete (set is_active = false) or hard delete
router.delete('/scam-patterns/:id', async (req, res, next) => {
  try {
    const patternId = parseInt(req.params.id, 10);
    if (isNaN(patternId)) return res.status(400).json({ success: false, message: 'Invalid pattern ID.' });

    // Soft delete by default; hard delete with ?hard=true (superadmin only)
    const hard = req.query.hard === 'true' && req.admin.role === 'superadmin';

    if (hard) {
      await pool.query('DELETE FROM scam_patterns WHERE id = $1', [patternId]);
    } else {
      await pool.query('UPDATE scam_patterns SET is_active = false, updated_at = NOW() WHERE id = $1', [patternId]);
    }

    await auditLog({
      adminId:    req.admin.adminId,
      action:     hard ? 'scam_pattern_hard_deleted' : 'scam_pattern_deactivated',
      targetType: 'scam_pattern',
      targetId:   patternId,
      ip:         req.ip,
    });

    return res.status(200).json({ success: true, message: hard ? 'Pattern permanently deleted.' : 'Pattern deactivated.' });
  } catch (err) {
    next(err);
  }
});

// ─── GET /export/users.csv ────────────────────────────────────────────────────
router.get('/export/users.csv', async (req, res, next) => {
  try {
    const rows = await pool.query(
      `SELECT id, name, email, phone_number, is_suspended, created_at FROM users ORDER BY created_at DESC`
    );
    const header = 'id,name,email,phone_number,is_suspended,created_at';
    const csv = [header, ...rows.rows.map(r =>
      `${r.id},"${(r.name||'').replace(/"/g,'""')}","${(r.email||'').replace(/"/g,'""')}","${(r.phone_number||'').replace(/"/g,'""')}",${r.is_suspended},${r.created_at}`
    )].join('\n');
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="users.csv"');
    return res.send(csv);
  } catch (err) { next(err); }
});

// ─── GET /export/reports.csv ──────────────────────────────────────────────────
router.get('/export/reports.csv', async (req, res, next) => {
  try {
    const rows = await pool.query(
      `SELECT id, user_id, type, sender, classification, body_preview, timestamp FROM scam_reports ORDER BY timestamp DESC`
    );
    const header = 'id,user_id,type,sender,classification,body_preview,timestamp';
    const csv = [header, ...rows.rows.map(r =>
      `${r.id},${r.user_id},"${(r.type||'').replace(/"/g,'""')}","${(r.sender||'').replace(/"/g,'""')}","${(r.classification||'').replace(/"/g,'""')}","${(r.body_preview||'').replace(/"/g,'""')}",${r.timestamp}`
    )].join('\n');
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="reports.csv"');
    return res.send(csv);
  } catch (err) { next(err); }
});

// ─── POST /broadcast ──────────────────────────────────────────────────────────

const { sendBroadcast, isFcmReady } = require('../services/fcm');

// POST /broadcast — send a push notification to users.
// FCM delivery is enabled when FCM_SERVICE_ACCOUNT_PATH or FCM_SERVICE_ACCOUNT_JSON
// is set in .env. Without those, it logs + audits but skips actual push delivery.
router.post('/broadcast', requireSuperAdmin, async (req, res, next) => {
  try {
    const { title, body, target } = req.body; // target: 'all' | 'active' | 'suspended'
    if (!title || !body) {
      return res.status(400).json({ success: false, message: 'title and body are required.' });
    }
    if (title.length > 120) {
      return res.status(400).json({ success: false, message: 'title must be 120 characters or fewer.' });
    }
    if (body.length > 500) {
      return res.status(400).json({ success: false, message: 'body must be 500 characters or fewer.' });
    }

    // Count target users for the audit record
    const countQ = (target === 'active')
      ? 'SELECT COUNT(*) FROM users WHERE is_suspended = false'
      : target === 'suspended'
      ? 'SELECT COUNT(*) FROM users WHERE is_suspended = true'
      : 'SELECT COUNT(*) FROM users';
    const countResult = await pool.query(countQ);
    const userCount = parseInt(countResult.rows[0].count, 10);

    // Attempt real FCM delivery (no-op if credentials not configured)
    const fcmResult = await sendBroadcast({
      title,
      body,
      data: { target: target || 'all' },
    });

    await auditLog({
      adminId:  req.admin.adminId,
      action:   'broadcast_notification',
      metadata: {
        title,
        body:      body.substring(0, 100),
        target:    target || 'all',
        userCount,
        fcm_sent:  fcmResult.sent,
        fcm_id:    fcmResult.messageId || null,
        fcm_error: fcmResult.error    || null,
      },
      ip: req.ip,
    });

    return res.status(200).json({
      success:   true,
      userCount,
      fcm_sent:  fcmResult.sent,
      fcm_ready: isFcmReady(),
      message:   fcmResult.sent
        ? `Broadcast delivered via FCM to topic 'all-users' (${userCount} targeted users).`
        : `Broadcast logged for ${userCount} users. FCM not configured — set FCM_SERVICE_ACCOUNT_PATH or FCM_SERVICE_ACCOUNT_JSON to enable push delivery.`,
    });
  } catch (err) { next(err); }
});

module.exports = router;
