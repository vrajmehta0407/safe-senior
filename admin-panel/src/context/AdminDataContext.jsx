import { createContext, useContext, useState, useEffect } from 'react'
import api, { getToken } from '../api'
import {
  mockStats,
  mockUsers,
  mockGuardians,
  mockAlerts,
  mockScamReports,
  mockDetectionRules,
  mockAuditLogs,
  mockHeatmapRegions
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
          setStats(prev => ({
            ...prev,
            activeSeniors: statsRes.value.stats.totalUsers || prev.activeSeniors,
            scamsInterceptedToday: statsRes.value.stats.totalScamReports || prev.scamsInterceptedToday,
          }))
        }
        if (usersRes.status === 'fulfilled' && usersRes.value?.users?.length > 0) {
          // Merge with mock user visual fields (avatar, geofence, etc.)
          setUsers(prev => {
            const remote = usersRes.value.users.map((u, i) => ({
              id: `u${u.id}`,
              name: u.name || `Senior #${u.id}`,
              age: 70 + (u.id % 20),
              phone: u.phone_number || '(555) 019-2834',
              email: u.email || '',
              location: 'Portland, OR',
              device: 'Samsung Galaxy A15 (Knox Secured)',
              guardians: [{ name: 'Family Guardian', relation: 'Relative', phone: '(555) 991-0022' }],
              geofenceStatus: u.is_suspended ? 'Suspended' : 'Inside Safe Zone',
              riskScore: u.is_suspended ? 90 : 35 + (u.id % 40),
              avatar: `https://images.unsplash.com/photo-${1544005313 + (u.id * 1000)}?w=150&auto=format&fit=crop&q=80`,
              isSuspended: u.is_suspended
            }))
            return [...remote, ...prev.filter(p => !remote.some(r => r.id === p.id))]
          })
        }
      } catch (err) {
        console.warn('Backend sync fallback to local/mock store:', err)
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
    }
  }

  const deleteRule = (ruleId) => {
    setRules(prev => prev.filter(r => r.id !== ruleId))
    addAuditLog('Pattern Rule Deactivated', `Rule ID: ${ruleId}`)
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
        regenerateApiKey
      }}
    >
      {children}
    </AdminDataContext.Provider>
  )
}

export const useAdminData = () => useContext(AdminDataContext)
