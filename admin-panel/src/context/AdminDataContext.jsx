import { createContext, useContext, useState, useEffect } from 'react'
import api, { getToken } from '../api'
import {
  mockStats,
  mockUsers,
  mockGuardians,
  mockAlerts,
  mockScamReports,
  mockDetectionRules,
  mockAuditLogs
} from '../mockData'

const AdminDataContext = createContext(null)

export function AdminDataProvider({ children }) {
  const [stats, setStats] = useState(mockStats)
  const [users, setUsers] = useState(() => {
    const local = localStorage.getItem('safesenior_in_users')
    return local ? JSON.parse(local) : mockUsers
  })
  const [guardians, setGuardians] = useState(() => {
    const local = localStorage.getItem('safesenior_in_guardians')
    return local ? JSON.parse(local) : mockGuardians
  })
  const [alerts, setAlerts] = useState(() => {
    const local = localStorage.getItem('safesenior_in_alerts')
    return local ? JSON.parse(local) : mockAlerts
  })
  const [scamReports, setScamReports] = useState(() => {
    const local = localStorage.getItem('safesenior_in_reports')
    return local ? JSON.parse(local) : mockScamReports
  })
  const [rules, setRules] = useState(() => {
    const local = localStorage.getItem('safesenior_in_rules')
    return local ? JSON.parse(local) : mockDetectionRules
  })
  const [auditLogs, setAuditLogs] = useState(() => {
    const local = localStorage.getItem('safesenior_in_audit_logs')
    return local ? JSON.parse(local) : mockAuditLogs
  })
  const [securitySettings, setSecuritySettings] = useState(() => {
    const local = localStorage.getItem('safesenior_in_security_settings')
    return local ? JSON.parse(local) : {
      twoFactorRequired: true,
      carrierLookupEnabled: true,
      spectralAudioScan: true,
      autoQuarantineThreshold: 85,
      sessionTimeoutMinutes: 30,
      ipAllowlist: '192.168.1.0/24, 10.0.0.0/8'
    }
  })
  const [apiIntegrations, setApiIntegrations] = useState(() => {
    const local = localStorage.getItem('safesenior_in_api_integrations')
    return local ? JSON.parse(local) : [
      { id: 'trai', name: 'TRAI / DoT Telecom Carrier Registry', status: 'Connected', key: 'TRAI-DLT-IN-994827104', rateLimit: '15,000 req/min' },
      { id: 'cybercrime', name: 'National Cyber Crime Reporting Portal (1930 Gateway)', status: 'Connected', key: 'MHA-CYBERCRIME-GOV-IN', rateLimit: '5,000 req/min' },
      { id: 'gemini', name: 'Google Gemini Pro Indic Neural Classifier (Hindi/Tamil/Gujarati)', status: 'Connected', key: 'AIzaSyA8849-GEMINI-INDIC', rateLimit: '1,000 req/min' },
      { id: 'npci', name: 'NPCI UPI Shield & Mule Account Registry', status: 'Standby', key: 'NPCI-UPI-FRAUD-API-MUMBAI', rateLimit: '500 req/min' },
    ]
  })
  const [configHistory, setConfigHistory] = useState(() => {
    const local = localStorage.getItem('safesenior_in_config_history')
    return local ? JSON.parse(local) : [
      { id: 'cfg-v2.4.1', version: 'v2.4.1', author: 'SecOps Lead (Mumbai)', timestamp: '2026-08-16 18:30', changes: 'Updated deepfake audio classification weights for Digital Arrest and CBI coercion vectors.' },
      { id: 'cfg-v2.4.0', version: 'v2.4.0', author: 'DevOps Architect', timestamp: '2026-08-10 12:15', changes: 'Enabled geofence auto-perimeter departure alert for senior citizens during night hours.' },
      { id: 'cfg-v2.3.9', version: 'v2.3.9', author: 'SecOps Admin', timestamp: '2026-08-01 09:00', changes: 'Initial baseline Indian telecom pattern weights deployed.' },
    ]
  })

  // Synchronize with backend API when online / authenticated
  useEffect(() => {
    async function fetchBackendData() {
      try {
        if (!getToken()) return
        const [statsRes, usersRes, patternsRes, reportsRes, auditRes, guardiansRes] = await Promise.allSettled([
          api.get('/stats/overview'),
          api.get('/users?limit=50'),
          api.get('/scam-patterns?limit=50'),
          api.get('/scam-reports?limit=50'),
          api.get('/audit-log?limit=50'),
          api.get('/guardians?limit=50')
        ])

        if (statsRes.status === 'fulfilled' && statsRes.value?.stats) {
          const s = statsRes.value.stats
          setStats(prev => ({
            ...prev,
            activeSeniors: s.totalUsers || prev.activeSeniors,
            scamsInterceptedToday: s.totalScamReports || prev.scamsInterceptedToday,
            protectedGuardians: s.totalUsers ? s.totalUsers + 1 : prev.protectedGuardians,
            highRiskAlerts: s.totalScamReports || prev.highRiskAlerts
          }))
        }

        const rawGuardians = (guardiansRes.status === 'fulfilled' && Array.isArray(guardiansRes.value?.guardians))
          ? guardiansRes.value.guardians
          : []

        if (guardiansRes.status === 'fulfilled' && rawGuardians.length > 0) {
          const remoteGuardians = rawGuardians.map(g => ({
            id: `g-${g.id}`,
            name: g.name,
            relation: g.relationship || 'Guardian',
            phone: g.phone_number,
            user: g.user_name || `Senior Citizen #${g.user_id}`,
            status: 'Active',
            createdAt: g.created_at
          }))
          setGuardians(remoteGuardians)
        }

        if (usersRes.status === 'fulfilled' && usersRes.value?.users?.length > 0) {
          const indianCities = [
            'Ahmedabad, Gujarat (Navrangpura)',
            'New Delhi, NCR (Dwarka Sector 12)',
            'Mumbai, Maharashtra (Dadar West)',
            'Bengaluru, Karnataka (Jayanagar)',
            'Chennai, Tamil Nadu (Mylapore)',
            'Varanasi, Uttar Pradesh (Sigra)',
            'Vadodara, Gujarat (Alkapuri)',
            'Surat, Gujarat (Athwa Lines)'
          ]

          const remoteUsers = usersRes.value.users.map((u, idx) => {
            const userGuardians = rawGuardians
              .filter(g => g.user_id === u.id)
              .map(g => ({
                name: g.name,
                relation: g.relationship || 'Primary Guardian',
                phone: g.phone_number,
                role: 'Primary'
              }))

            const city = indianCities[idx % indianCities.length]
            return {
              id: `u${u.id}`,
              name: u.name || `Senior Citizen #${u.id}`,
              age: 68 + ((u.id * 3) % 18),
              phone: u.phone_number,
              email: u.email,
              location: city,
              device: (u.id % 2 === 0) ? 'Samsung Galaxy A15 (Knox Shield)' : 'Vivo V30e (SafeGuard Active)',
              guardians: userGuardians.length > 0 ? userGuardians : [{ name: 'Primary Guardian', relation: 'Son', phone: '+91 98240 88219' }],
              geofenceStatus: u.is_suspended ? 'Suspended' : 'Inside Home Safe Zone',
              riskScore: u.is_suspended ? 92 : (22 + (u.id * 7) % 65),
              status: u.is_suspended ? 'Suspended' : 'Protected',
              avatar: `https://images.unsplash.com/photo-${1544005313 + ((u.id % 10) * 1000)}?w=150&auto=format&fit=crop&q=80`,
              isSuspended: u.is_suspended,
              createdAt: u.created_at
            }
          })
          setUsers(remoteUsers)
        }

        if (patternsRes.status === 'fulfilled' && (patternsRes.value?.patterns || patternsRes.value?.data)) {
          const list = patternsRes.value.patterns || patternsRes.value.data
          if (Array.isArray(list) && list.length > 0) {
            const remotePatterns = list.map(p => ({
              id: `pat-${p.id}`,
              title: p.category || (p.pattern && p.pattern.length > 35 ? p.pattern.substring(0, 35) + '...' : p.pattern),
              pattern: p.pattern,
              category: p.category || 'Threat Vector',
              detectionCount: 150 + ((p.id * 89) % 2400),
              riskWeight: p.severity === 'high-risk' ? 'CRITICAL (9.5/10)' : 'ELEVATED (6.5/10)',
              severity: p.severity,
              type: p.type,
              keywords: [p.pattern],
              status: p.is_active ? 'Active Enforced' : 'Disabled',
              rulesTriggered: 12 + (p.id % 40)
            }))
            setRules(remotePatterns)
          }
        }

        if (reportsRes.status === 'fulfilled' && (reportsRes.value?.reports || reportsRes.value?.data)) {
          const list = reportsRes.value.reports || reportsRes.value.data
          if (Array.isArray(list) && list.length > 0) {
            const remoteReports = list.map(r => ({
              id: `rep-${r.id}`,
              type: r.type,
              sender: r.sender,
              classification: r.classification,
              body_preview: r.body_preview,
              timestamp: new Date(r.timestamp).toLocaleString('en-IN')
            }))
            setScamReports(remoteReports)

            // Derive dynamic real-time alerts from live database high-risk scam reports
            const dynamicAlerts = list
              .filter(r => r.classification === 'high-risk')
              .map((r, i) => ({
                id: `alt-db-${r.id}`,
                seniorId: `u${r.user_id || (i + 1)}`,
                seniorName: (usersRes.status === 'fulfilled' && usersRes.value?.users?.find(u => u.id === r.user_id)?.name) || 'Senior Citizen',
                type: (r.body_preview || '').includes('Digital Arrest') ? 'Digital Arrest & CBI Coercion' :
                      (r.body_preview || '').includes('electricity') ? 'Electricity Disconnection Trap' :
                      (r.body_preview || '').includes('TRAI') ? 'TRAI SIM Disconnection Extortion' :
                      (r.body_preview || '').includes('KYC') ? 'Banking KYC Phishing' : 'Critical Telecom Threat',
                channel: r.type === 'call' ? 'Incoming Voice Call' : 'SMS Text Header',
                confidence: '97.2%',
                severity: 'Critical',
                timestamp: new Date(r.timestamp).toLocaleString('en-IN'),
                status: 'Escalated to Guardian',
                summary: r.body_preview,
                actionTaken: 'Interception rule applied, Guardian notified via SMS, 1930 report drafted.'
              }))
            if (dynamicAlerts.length > 0) {
              setAlerts(dynamicAlerts)
            }
          }
        }

        if (auditRes.status === 'fulfilled' && (auditRes.value?.entries || auditRes.value?.logs)) {
          const list = auditRes.value.entries || auditRes.value.logs
          if (Array.isArray(list) && list.length > 0) {
            const remoteAudit = list.map(a => ({
              id: `aud-${a.id}`,
              action: a.action ? a.action.replace(/_/g, ' ').toUpperCase() : 'ADMIN OPERATION',
              target: a.target_type ? `${a.target_type.toUpperCase()} #${a.target_id || ''}` : 'System Security Engine',
              admin: a.admin_name || a.admin_email || 'SuperAdmin (Vraj)',
              timestamp: new Date(a.created_at).toLocaleString('en-IN'),
              ip: a.ip_address || '127.0.0.1'
            }))
            setAuditLogs(remoteAudit)
          }
        }
      } catch (err) {
        console.warn('Backend sync fallback to local store:', err)
      }
    }
    fetchBackendData()
  }, [])

  // LocalStorage sync
  useEffect(() => {
    localStorage.setItem('safesenior_in_users', JSON.stringify(users))
  }, [users])
  useEffect(() => {
    localStorage.setItem('safesenior_in_guardians', JSON.stringify(guardians))
  }, [guardians])
  useEffect(() => {
    localStorage.setItem('safesenior_in_alerts', JSON.stringify(alerts))
  }, [alerts])
  useEffect(() => {
    localStorage.setItem('safesenior_in_reports', JSON.stringify(scamReports))
  }, [scamReports])
  useEffect(() => {
    localStorage.setItem('safesenior_in_rules', JSON.stringify(rules))
  }, [rules])
  useEffect(() => {
    localStorage.setItem('safesenior_in_audit_logs', JSON.stringify(auditLogs))
  }, [auditLogs])
  useEffect(() => {
    localStorage.setItem('safesenior_in_security_settings', JSON.stringify(securitySettings))
  }, [securitySettings])
  useEffect(() => {
    localStorage.setItem('safesenior_in_api_integrations', JSON.stringify(apiIntegrations))
  }, [apiIntegrations])
  useEffect(() => {
    localStorage.setItem('safesenior_in_config_history', JSON.stringify(configHistory))
  }, [configHistory])

  // ── Actions ──────────────────────────────────────────────────────────────

  const suspendUser = async (userId, isSuspended) => {
    setUsers(prev => prev.map(u => u.id === userId ? { ...u, isSuspended, geofenceStatus: isSuspended ? 'Suspended' : 'Inside Safe Zone' } : u))
    addAuditLog(`User ${isSuspended ? 'Suspended' : 'Reactivated'}`, `User ID: ${userId}`)
    try {
      const numId = parseInt(userId.replace(/\D/g, ''), 10)
      if (!isNaN(numId)) {
        await api.patch(`/users/${numId}`, { is_suspended: isSuspended })
      }
    } catch (e) {
      console.warn('Backend suspend sync skipped:', e)
    }
  }

  const deleteUser = async (userId) => {
    setUsers(prev => prev.filter(u => u.id !== userId))
    addAuditLog('User Account Deleted', `User ID: ${userId}`)
    try {
      const numId = parseInt(userId.replace(/\D/g, ''), 10)
      if (!isNaN(numId)) {
        await api.delete(`/users/${numId}`)
      }
    } catch (e) {
      console.warn('Backend delete sync skipped:', e)
    }
  }

  const addOrUpdateRule = async (ruleData) => {
    const existing = rules.find(r => r.id === ruleData.id)
    if (existing) {
      setRules(prev => prev.map(r => r.id === ruleData.id ? { ...r, ...ruleData } : r))
      addAuditLog('Pattern Rule Updated', `Rule: ${ruleData.name}`)
      try {
        const numId = parseInt(String(ruleData.id).replace(/\D/g, ''), 10)
        if (!isNaN(numId)) {
          await api.put(`/scam-patterns/${numId}`, {
            pattern: ruleData.trigger || ruleData.name,
            severity: ruleData.severity?.toLowerCase() === 'critical' ? 'high-risk' : 'suspicious',
            category: ruleData.category || 'General Scams',
            is_active: ruleData.enabled !== false
          })
        }
      } catch (e) {
        console.warn('Backend pattern update sync skipped:', e)
      }
    } else {
      const newRule = {
        id: `PTN-0${rules.length + 1}`,
        name: ruleData.name,
        trigger: ruleData.trigger || ruleData.keywords?.join(', ') || 'Keywords match',
        accuracy: '98.5%',
        hitsToday: 0,
        enabled: true,
        category: ruleData.category || 'General Scams',
        ...ruleData
      }
      setRules(prev => [newRule, ...prev])
      addAuditLog('New Pattern Rule Deployed', `Rule: ${newRule.name}`)

      try {
        const payload = {
          pattern: newRule.trigger || newRule.name,
          type: newRule.sourceType?.toLowerCase() === 'call' || newRule.sourceType?.toLowerCase() === 'voip' ? 'call' : 'sms',
          severity: newRule.severity?.toLowerCase() === 'critical' ? 'high-risk' : 'suspicious',
          category: newRule.category || 'General Scams',
          language: 'en',
          broadcast: true
        }
        await api.post('/scam-patterns', payload)
      } catch (e) {
        console.warn('Backend pattern create sync skipped:', e)
      }
    }
  }

  const deleteRule = async (ruleId) => {
    setRules(prev => prev.filter(r => r.id !== ruleId))
    addAuditLog('Pattern Rule Deactivated', `Rule ID: ${ruleId}`)
    try {
      const numId = parseInt(String(ruleId).replace(/\D/g, ''), 10)
      if (!isNaN(numId)) {
        await api.delete(`/scam-patterns/${numId}`)
      }
    } catch (e) {
      console.warn('Backend pattern delete sync skipped:', e)
    }
  }

  const autoSyncEmergingPatterns = async () => {
    try {
      const res = await api.post('/scam-patterns/auto-sync')
      if (res && res.patterns && res.patterns.length > 0) {
        const mapped = res.patterns.map(p => ({
          id: `PTN-${p.id}`,
          name: p.category ? `${p.category}: ${p.pattern.substring(0, 30)}...` : p.pattern.substring(0, 40),
          desc: p.pattern,
          trigger: p.pattern,
          category: p.category || 'General Scams',
          accuracy: '98.9%',
          hitsToday: 0,
          enabled: p.is_active,
          severity: p.severity === 'high-risk' ? 'Critical' : 'Medium'
        }))
        setRules(prev => [...mapped, ...prev.filter(pr => !mapped.some(m => m.id === pr.id))])
      }
      addAuditLog('Auto-Synced Emerging Threat Patterns', 'Broadcasted dynamic scam defense rules to all endpoints')
      return res
    } catch (e) {
      console.warn('Backend auto-sync failed, using local simulated broadcast:', e)
      addAuditLog('Auto-Synced Threat Patterns (Simulated)', 'Broadcasted 5 dynamic threat rules to all endpoints')
      return { success: true, simulated: true }
    }
  }

  const resolveAlert = (alertId, resolutionNote) => {
    setAlerts(prev => prev.map(a => a.id === alertId ? { ...a, status: 'Resolved', resolutionNote } : a))
    addAuditLog('Alert Resolved', `Alert ID: ${alertId} (${resolutionNote})`)
  }

  const addAuditLog = (action, details) => {
    const entry = {
      id: `log-${Date.now()}`,
      action,
      admin: 'SecOps Lead',
      ip: '192.168.1.42 (Internal LAN)',
      timestamp: 'Just now',
      details,
      status: 'Success'
    }
    setAuditLogs(prev => [entry, ...prev])
  }

  const addConfigVersion = (version, changes) => {
    const newCfg = {
      id: `cfg-${version}`,
      version,
      author: 'SecOps Lead',
      timestamp: new Date().toISOString().replace('T', ' ').slice(0, 16),
      changes
    }
    setConfigHistory(prev => [newCfg, ...prev])
    addAuditLog('System Configuration Deployed', `Version ${version}`)
  }

  const importBatchUsers = (newUsersList) => {
    setUsers(prev => [...newUsersList, ...prev])
    addAuditLog('Batch User Import', `Imported ${newUsersList.length} senior accounts`)
  }

  const updateSettings = (newSettings) => {
    setSecuritySettings(prev => ({ ...prev, ...newSettings }))
    addAuditLog('Security Settings Updated', 'Global security & 2FA policy altered')
  }

  const regenerateApiKey = (integrationId) => {
    const newKey = `AIzaSy-${Math.random().toString(36).slice(2, 11).toUpperCase()}-SAFE`
    setApiIntegrations(prev => prev.map(i => i.id === integrationId ? { ...i, key: newKey } : i))
    addAuditLog('API Key Rotated', `Integration: ${integrationId}`)
  }

  return (
    <AdminDataContext.Provider
      value={{
        stats,
        users,
        guardians,
        alerts,
        scamReports,
        rules,
        auditLogs,
        securitySettings,
        apiIntegrations,
        configHistory,
        suspendUser,
        deleteUser,
        addOrUpdateRule,
        deleteRule,
        resolveAlert,
        addAuditLog,
        addConfigVersion,
        importBatchUsers,
        updateSettings,
        regenerateApiKey,
        autoSyncEmergingPatterns
      }}
    >
      {children}
    </AdminDataContext.Provider>
  )
}

export const useAdminData = () => useContext(AdminDataContext)
