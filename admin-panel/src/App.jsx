import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useState } from 'react'
import { getToken, setToken, clearToken } from './api'
import { AdminDataProvider } from './context/AdminDataContext'
import LoginPage from './pages/LoginPage'
import Layout from './components/Layout'

// Real & Essential Working Admin Screens
import Dashboard from './pages/Dashboard'
import ScamReports from './pages/ScamReports'
import CrisisHandover from './pages/CrisisHandover'
import UsersPage from './pages/UsersPage'
import UserProtectionDetail from './pages/UserProtectionDetail'
import Guardians from './pages/Guardians'
import Patterns from './pages/Patterns'
import RuleSandbox from './pages/RuleSandbox'
import BadgesPage from './pages/BadgesPage'
import AuditLog from './pages/AuditLog'
import AdminUsers from './pages/AdminUsers'
import SecuritySettings from './pages/SecuritySettings'
import SystemMaintenance from './pages/SystemMaintenance'

function PrivateRoute({ children }) {
  return getToken() ? children : <Navigate to="/login" replace />
}

export default function App() {
  const [admin, setAdmin] = useState(() => {
    try {
      const stored = sessionStorage.getItem('safesenior_admin_user')
      return stored ? JSON.parse(stored) : null
    } catch {
      return null
    }
  })

  function handleLogin(token, adminData) {
    const user = adminData || {
      id: 'admin-001',
      name: 'Vraj Mehta',
      role: 'Superadmin'
    }
    setToken(token)
    try {
      sessionStorage.setItem('safesenior_admin_user', JSON.stringify(user))
    } catch {}
    setAdmin(user)
  }

  function handleLogout() {
    clearToken()
    try {
      sessionStorage.removeItem('safesenior_admin_user')
    } catch {}
    setAdmin(null)
  }

  return (
    <AdminDataProvider>
      <BrowserRouter>
        <Routes>
          <Route
            path="/login"
            element={getToken() ? <Navigate to="/dashboard" replace /> : <LoginPage onLogin={handleLogin} />}
          />
          <Route
            path="/*"
            element={
              <PrivateRoute>
                <Layout admin={admin} onLogout={handleLogout}>
                  <Routes>
                    <Route index element={<Navigate to="/dashboard" replace />} />

                    {/* Operations Center */}
                    <Route path="dashboard" element={<Dashboard />} />
                    <Route path="scam-reports" element={<ScamReports />} />
                    <Route path="crisis-handover" element={<CrisisHandover />} />

                    {/* Senior Citizens & Guardians */}
                    <Route path="users" element={<UsersPage />} />
                    <Route path="protection-details" element={<UserProtectionDetail />} />
                    <Route path="guardians" element={<Guardians />} />

                    {/* Threat Intel & Rule Testing */}
                    <Route path="patterns" element={<Patterns />} />
                    <Route path="rules-sandbox" element={<RuleSandbox />} />
                    <Route path="badges" element={<BadgesPage />} />

                    {/* SecOps & Governance */}
                    <Route path="audit-log" element={<AuditLog />} />
                    <Route path="admins" element={<AdminUsers />} />
                    <Route path="security-settings" element={<SecuritySettings />} />
                    <Route path="maintenance" element={<SystemMaintenance />} />

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
