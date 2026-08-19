import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useState } from 'react'
import { getToken, setToken, clearToken } from './api'
import { AdminDataProvider } from './context/AdminDataContext'
import LoginPage from './pages/LoginPage'
import Layout from './components/Layout'

// 25 Stitch Desktop Screens / Pages
import Dashboard from './pages/Dashboard'
import GuardianDashboard from './pages/GuardianDashboard'
import GuardianActivity from './pages/GuardianActivity'
import UserProtectionDetail from './pages/UserProtectionDetail'
import AlertsCenter from './pages/AlertsCenter'
import ScamReports from './pages/ScamReports'
import PostIncidentReport from './pages/PostIncidentReport'
import RuleSandbox from './pages/RuleSandbox'
import RuleWizard from './pages/RuleWizard'
import Patterns from './pages/Patterns'
import RuleAnalytics from './pages/RuleAnalytics'
import GeofencingConfig from './pages/GeofencingConfig'
import CrisisHandover from './pages/CrisisHandover'
import HeatmapView from './pages/HeatmapView'
import SystemAnalytics from './pages/SystemAnalytics'
import UsersPage from './pages/UsersPage'
import BatchUserImport from './pages/BatchUserImport'
import AdminActivity from './pages/AdminActivity'
import AuditLog from './pages/AuditLog'
import ConfigHistory from './pages/ConfigHistory'
import SecuritySettings from './pages/SecuritySettings'
import ApiIntegrations from './pages/ApiIntegrations'
import SystemMaintenance from './pages/SystemMaintenance'
import Guardians from './pages/Guardians'
import AdminUsers from './pages/AdminUsers'

function PrivateRoute({ children }) {
  return getToken() ? children : <Navigate to="/login" replace />
}

export default function App() {
  const [admin, setAdmin] = useState({
    id: 'admin-001',
    name: 'Vraj Mehta',
    role: 'SecOps Lead'
  })

  if (!getToken()) {
    setToken('initial-dev-session-token')
  }

  function handleLogin(token, adminData) {
    setToken(token)
    setAdmin(adminData)
  }

  function handleLogout() {
    clearToken()
    setAdmin(null)
  }

  return (
    <AdminDataProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage onLogin={handleLogin} />} />
          <Route
            path="/*"
            element={
              <PrivateRoute>
                <Layout admin={admin} onLogout={handleLogout}>
                  <Routes>
                    <Route index element={<Navigate to="/dashboard" replace />} />
                    
                    {/* Core Operations */}
                    <Route path="dashboard" element={<Dashboard />} />
                    <Route path="alerts" element={<AlertsCenter />} />
                    <Route path="scam-reports" element={<ScamReports />} />
                    <Route path="post-incident-reports" element={<PostIncidentReport />} />
                    
                    {/* Guardian & Family Portal */}
                    <Route path="guardian-dashboard" element={<GuardianDashboard />} />
                    <Route path="guardian-activity" element={<GuardianActivity />} />
                    <Route path="protection-details" element={<UserProtectionDetail />} />
                    <Route path="users" element={<UsersPage />} />
                    <Route path="batch-import" element={<BatchUserImport />} />
                    <Route path="guardians" element={<Guardians />} />

                    {/* Threat Intel & Rules */}
                    <Route path="patterns" element={<Patterns />} />
                    <Route path="rules-sandbox" element={<RuleSandbox />} />
                    <Route path="rules-wizard" element={<RuleWizard />} />
                    <Route path="rules-analytics" element={<RuleAnalytics />} />
                    <Route path="heatmap" element={<HeatmapView />} />

                    {/* Emergency & Zones */}
                    <Route path="geofencing" element={<GeofencingConfig />} />
                    <Route path="crisis-handover" element={<CrisisHandover />} />

                    {/* System & Intelligence */}
                    <Route path="analytics" element={<SystemAnalytics />} />
                    <Route path="security-settings" element={<SecuritySettings />} />
                    <Route path="api-integrations" element={<ApiIntegrations />} />
                    <Route path="config-history" element={<ConfigHistory />} />
                    <Route path="admin-activity" element={<AdminActivity />} />
                    <Route path="audit-log" element={<AuditLog />} />
                    <Route path="maintenance" element={<SystemMaintenance />} />
                    <Route path="admins" element={<AdminUsers />} />

                    {/* Fallback */}
                    <Route path="*" element={<Navigate to="/dashboard" replace />} />
                  </Routes>
                </Layout>
              </PrivateRoute>
            }
          />
        </Routes>
      </BrowserRouter>
    </AdminDataProvider>
  )
}
