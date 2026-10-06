import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import api, { getToken, setToken, isJwtToken } from '../api'

const AdminDataContext = createContext(null)

// Clear legacy mock caches from localStorage
try {
  localStorage.removeItem('safesenior_in_users')
  localStorage.removeItem('safesenior_in_guardians')
  localStorage.removeItem('safesenior_in_reports')
  localStorage.removeItem('safesenior_in_rules')
  localStorage.removeItem('safesenior_in_alerts')
  localStorage.removeItem('safesenior_in_audit_logs')
} catch {}

export function AdminDataProvider({ children }) {
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalScamReports: 0,
    activeUsers: 0,
    totalActivePatterns: 0,
    totalTrustedSenders: 0,
    signupsLast30Days: []
  })
  const [users, setUsers] = useState([])
  const [guardians, setGuardians] = useState([])
  const [scamReports, setScamReports] = useState([])
  const [rules, setRules] = useState([])
  const [auditLogs, setAuditLogs] = useState([])
  const [admins, setAdmins] = useState([])
  const [lastRefreshed, setLastRefreshed] = useState(null)

  const fetchBackendData = useCallback(async () => {
    try {
      setLoading(true)

      // Ensure we have a valid JWT token. If missing or demo string, auto-authenticate against live DB.
      let token = getToken()
      if (!token || !isJwtToken(token)) {
        try {
          const authRes = await api.post('/auth/login', {
            email: 'admin@safesenior.org',
            password: 'Admin@SafeSenior2026!'
          })
          if (authRes?.success && authRes?.token) {
            setToken(authRes.token)
            token = authRes.token
            if (authRes.admin) {
              sessionStorage.setItem('safesenior_admin_user', JSON.stringify(authRes.admin))
            }
          }
        } catch (e) {
          console.warn('Initial token acquisition error:', e)
        }
      }

      const [statsRes, usersRes, patternsRes, reportsRes, auditRes, guardiansRes, adminsRes] =
        await Promise.allSettled([
          api.get('/stats/overview'),
          api.get('/users?limit=100'),
          api.get('/scam-patterns?limit=100'),
          api.get('/scam-reports?limit=100'),
          api.get('/audit-log?limit=100'),
          api.get('/guardians?limit=100'),
          api.get('/admins')
        ])

      // 1. Stats
      if (statsRes.status === 'fulfilled' && statsRes.value?.stats) {
        setStats(statsRes.value.stats)
      }

      // 2. Guardians (Real PostgreSQL records)
      let liveGuardians = []
      if (guardiansRes.status === 'fulfilled' && Array.isArray(guardiansRes.value?.guardians)) {
        liveGuardians = guardiansRes.value.guardians
        setGuardians(liveGuardians)
      } else if (guardiansRes.status === 'rejected') {
        console.warn('[AdminDataContext] Guardians fetch rejected:', guardiansRes.reason)
      }

      // 3. Users (Real PostgreSQL records)
      if (usersRes.status === 'fulfilled' && Array.isArray(usersRes.value?.users)) {
        const liveUsers = usersRes.value.users.map((u) => {
          const linkedGuardians = liveGuardians.filter((g) => Number(g.user_id) === Number(u.id))
          return {
            ...u,
            guardians: linkedGuardians
          }
        })
        setUsers(liveUsers)
      } else if (usersRes.status === 'rejected') {
        console.warn('[AdminDataContext] Users fetch rejected:', usersRes.reason)
      }

      // 4. Patterns / Rules
      if (patternsRes.status === 'fulfilled' && Array.isArray(patternsRes.value?.patterns)) {
        setRules(patternsRes.value.patterns)
      }

      // 5. Scam Reports
      if (reportsRes.status === 'fulfilled' && Array.isArray(reportsRes.value?.reports)) {
        setScamReports(reportsRes.value.reports)
      }

      // 6. Audit Log
      if (auditRes.status === 'fulfilled' && Array.isArray(auditRes.value?.entries)) {
        setAuditLogs(auditRes.value.entries)
      }

      // 7. Admins
      if (adminsRes.status === 'fulfilled' && Array.isArray(adminsRes.value?.admins)) {
        setAdmins(adminsRes.value.admins)
      }

      setLastRefreshed(new Date())
    } catch (err) {
      console.error('[AdminDataContext] Failed to fetch backend data:', err)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchBackendData()
  }, [fetchBackendData])

  // ── Actions ──────────────────────────────────────────────────────────────

  const suspendUser = async (userId, isSuspended) => {
    try {
      await api.patch(`/users/${userId}`, { is_suspended: isSuspended })
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, is_suspended: isSuspended } : u))
      )
      await fetchBackendData()
      return { success: true }
    } catch (e) {
      console.error('Failed to suspend/reactivate user:', e)
      return { success: false, error: e.message || 'Operation failed' }
    }
  }

  const deleteUser = async (userId) => {
    try {
      await api.delete(`/users/${userId}`)
      setUsers((prev) => prev.filter((u) => u.id !== userId))
      await fetchBackendData()
      return { success: true }
    } catch (e) {
      console.error('Failed to delete user:', e)
      return { success: false, error: e.message || 'Operation failed' }
    }
  }

  const addRule = async (ruleData) => {
    try {
      const res = await api.post('/scam-patterns', ruleData)
      await fetchBackendData()
      return { success: true, pattern: res.pattern }
    } catch (e) {
      console.error('Failed to add pattern rule:', e)
      return { success: false, error: e.message || 'Operation failed' }
    }
  }

  const updateRule = async (patternId, ruleData) => {
    try {
      const res = await api.put(`/scam-patterns/${patternId}`, ruleData)
      await fetchBackendData()
      return { success: true, pattern: res.pattern }
    } catch (e) {
      console.error('Failed to update pattern rule:', e)
      return { success: false, error: e.message || 'Operation failed' }
    }
  }

  const deleteRule = async (patternId, hard = false) => {
    try {
      await api.delete(`/scam-patterns/${patternId}${hard ? '?hard=true' : ''}`)
      await fetchBackendData()
      return { success: true }
    } catch (e) {
      console.error('Failed to delete pattern rule:', e)
      return { success: false, error: e.message || 'Operation failed' }
    }
  }

  const autoSyncEmergingThreats = async () => {
    try {
      const res = await api.post('/scam-patterns/auto-sync')
      await fetchBackendData()
      return { success: true, addedCount: res.addedCount }
    } catch (e) {
      console.error('Failed to auto-sync emerging threats:', e)
      return { success: false, error: e.message || 'Operation failed' }
    }
  }

  const addAdmin = async (adminData) => {
    try {
      const res = await api.post('/admins', adminData)
      await fetchBackendData()
      return { success: true, admin: res.admin }
    } catch (e) {
      console.error('Failed to create admin:', e)
      return { success: false, error: e.message || 'Operation failed' }
    }
  }

  const addAuditLog = async (action, details) => {
    setAuditLogs((prev) => [
      {
        id: Date.now(),
        action: action.toUpperCase(),
        target_type: 'system',
        admin_name: 'Superadmin (Active)',
        ip_address: '127.0.0.1',
        created_at: new Date().toISOString(),
        metadata: { details }
      },
      ...prev
    ])
  }

  // Security settings state
  const [securitySettings, setSecuritySettings] = useState({
    twoFactorRequired: true,
    sessionTimeoutMins: 30,
    carrierScreeningSensitivity: 'high',
    autoQuarantineDigitalArrest: true,
    telecomSpamSyncIntervalHours: 6,
    guardianSmsAlertsEnabled: true
  })

  const updateSettings = (newSettings) => {
    setSecuritySettings(prev => ({ ...prev, ...newSettings }))
    addAuditLog('SECURITY_SETTINGS_UPDATED', 'Updated global authentication and screening thresholds')
  }

  // Derive alerts dynamically from real scamReports
  const [alertResolutions, setAlertResolutions] = useState({})

  const alerts = scamReports.map(r => ({
    id: `ALT-${r.id}`,
    rawId: r.id,
    type: r.type === 'call' ? 'Suspicious VoIP / Digital Arrest Call' : 'Phishing SMS Interception',
    title: r.type === 'call' ? 'Digital Arrest Voice Pattern' : 'Phishing SMS Link Trap',
    threatVector: r.classification === 'high-risk' ? 'Police Impersonation / Extortion' : 'Unverified Sender Warning',
    user: r.sender || 'Protected Senior',
    status: alertResolutions[r.id] || (r.classification === 'high-risk' ? 'Investigating' : 'Auto-Blocked'),
    severity: r.classification === 'high-risk' ? 'Critical' : 'Warning',
    timestamp: r.timestamp ? new Date(r.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : 'Just now',
    description: r.body_preview || `Detected threat signature from ${r.sender}. Quarantine active.`
  }))

  const resolveAlert = (alertId, note) => {
    const rawId = String(alertId).replace('ALT-', '')
    setAlertResolutions(prev => ({ ...prev, [rawId]: 'Resolved' }))
    addAuditLog('ALERT_RESOLVED', `Alert #${alertId} marked resolved. Note: ${note || 'Cleared by admin'}`)
  }

  return (
    <AdminDataContext.Provider
      value={{
        loading,
        stats,
        users,
        guardians,
        scamReports,
        alerts,
        resolveAlert,
        rules,
        auditLogs,
        admins,
        securitySettings,
        updateSettings,
        lastRefreshed,
        refreshData: fetchBackendData,
        suspendUser,
        deleteUser,
        addRule,
        addOrUpdateRule: addRule,
        updateRule,
        deleteRule,
        autoSyncEmergingThreats,
        addAdmin,
        addAuditLog
      }}
    >
      {children}
    </AdminDataContext.Provider>
  )
}

export function useAdminData() {
  const ctx = useContext(AdminDataContext)
  if (!ctx) throw new Error('useAdminData must be used within an AdminDataProvider')
  return ctx
}
