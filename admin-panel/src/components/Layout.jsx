import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'

export default function Layout({ children }) {
  const location = useLocation()
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState('')

  const handleLogout = () => {
    localStorage.removeItem('adminToken')
    localStorage.removeItem('adminRole')
    navigate('/login')
  }

  const navGroups = [
    {
      title: 'Core Operations',
      items: [
        { path: '/dashboard', label: 'System Health', icon: 'dashboard' },
        { path: '/alerts', label: 'Alerts Center', icon: 'emergency', badge: '12' },
        { path: '/heatmap', label: 'Scam Heatmap', icon: 'map' },
        { path: '/crisis-handover', label: 'Crisis & LE Handover', icon: 'support_agent' },
      ]
    },
    {
      title: 'Scam Intelligence',
      items: [
        { path: '/patterns', label: 'Pattern Management', icon: 'rule' },
        { path: '/rules-wizard', label: 'New Rule Wizard', icon: 'add_circle' },
        { path: '/rules-sandbox', label: 'Rule Sandbox', icon: 'science' },
        { path: '/rules-analytics', label: 'Rule Analytics', icon: 'analytics' },
        { path: '/scam-reports', label: 'Incident Escalations', icon: 'report_problem' },
        { path: '/post-incident-reports', label: 'Post-Incident Dossier', icon: 'assignment' },
      ]
    },
    {
      title: 'User & Guardian Network',
      items: [
        { path: '/users', label: 'User Management', icon: 'group' },
        { path: '/protection-details', label: 'Protection Details', icon: 'shield_person' },
        { path: '/guardian-dashboard', label: 'Guardian Portal', icon: 'family_restroom' },
        { path: '/guardian-activity', label: 'Guardian Activity', icon: 'history_toggle_off' },
        { path: '/geofencing', label: 'Geofence Safe Zones', icon: 'pin_drop' },
        { path: '/batch-import', label: 'Batch User Import', icon: 'upload_file' },
      ]
    },
    {
      title: 'System & Governance',
      items: [
        { path: '/analytics', label: 'Analytics Reports', icon: 'bar_chart' },
        { path: '/security-settings', label: 'Security & Auth (2FA)', icon: 'security' },
        { path: '/api-integrations', label: 'API Integrations', icon: 'api' },
        { path: '/config-history', label: 'Config Version History', icon: 'update' },
        { path: '/admin-activity', label: 'Admin Activity Log', icon: 'receipt_long' },
        { path: '/audit-log', label: 'System Audit Logs', icon: 'shield' },
        { path: '/maintenance', label: 'System Maintenance', icon: 'build' },
      ]
    }
  ]

  const isCurrent = (path) => location.pathname === path

  return (
    <div className="bg-background text-on-background font-body-md min-h-screen">
      {/* ── TopAppBar (Stitch Exact Layout) ── */}
      <header className="fixed top-0 right-0 left-0 md:left-64 h-16 z-30 flex items-center justify-between px-6 bg-surface border-b border-surface-container-low shadow-sm">
        {/* Search Bar */}
        <div className="flex-1 max-w-md">
          <div className="relative focus-within:ring-2 focus-within:ring-primary rounded-full transition-shadow">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline">
              search
            </span>
            <input
              type="text"
              placeholder="Search alerts, rules, users..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full bg-surface-container-low border-none rounded-full py-2 pl-10 pr-4 font-body-md text-on-surface placeholder:text-outline focus:outline-none focus:ring-0 h-[40px]"
            />
          </div>
        </div>

        {/* Trailing Actions */}
        <div className="flex items-center gap-2">
          <button
            aria-label="Alerts"
            onClick={() => navigate('/alerts')}
            className="w-[44px] h-[44px] flex items-center justify-center rounded-full hover:bg-surface-container-high transition-colors text-on-surface-variant relative"
          >
            <span className="material-symbols-outlined">notifications</span>
            <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-error rounded-full border-2 border-surface"></span>
          </button>
          <button
            aria-label="Audit History"
            onClick={() => navigate('/audit-log')}
            className="w-[44px] h-[44px] flex items-center justify-center rounded-full hover:bg-surface-container-high transition-colors text-on-surface-variant"
          >
            <span className="material-symbols-outlined">history</span>
          </button>
          <div className="flex items-center gap-3 pl-2 border-l border-surface-container-high">
            <div className="w-9 h-9 rounded-full overflow-hidden bg-primary-container text-on-primary-container flex items-center justify-center font-bold text-sm">
              SO
            </div>
            <div className="hidden lg:block text-left">
              <div className="font-label-md text-on-surface text-xs font-bold leading-tight">SecOps Admin</div>
              <div className="text-[11px] text-on-surface-variant leading-tight">Tier 3 Response</div>
            </div>
            <button
              onClick={handleLogout}
              className="p-1.5 text-on-surface-variant hover:text-error transition-colors rounded-lg hover:bg-surface-container-low"
              title="Logout"
            >
              <span className="material-symbols-outlined text-[20px]">logout</span>
            </button>
          </div>
        </div>
      </header>

      {/* ── SideNavBar (Stitch Exact Layout) ── */}
      <nav aria-label="Main Navigation" className="fixed left-0 top-0 h-screen w-64 z-40 flex flex-col bg-surface border-r border-surface-container-low shadow-sm">
        {/* Brand Header */}
        <div className="p-6 border-b border-surface-container-low">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-primary flex items-center justify-center text-on-primary shadow-sm">
              <span className="material-symbols-outlined text-2xl icon-fill">shield</span>
            </div>
            <div>
              <h1 className="font-headline-sm text-[19px] font-bold text-primary leading-none">SafeSenior</h1>
              <p className="font-label-md text-[11px] text-on-surface-variant uppercase tracking-wider mt-1">Admin Operations</p>
            </div>
          </div>

          <button
            onClick={() => navigate('/rules-wizard')}
            className="mt-5 w-full bg-primary text-on-primary rounded-xl py-2.5 px-4 font-label-md text-sm flex items-center justify-center gap-2 hover:bg-primary-container transition-colors shadow-sm active:scale-[0.99]"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            New System Rule
          </button>
        </div>

        {/* Grouped Navigation Links */}
        <div className="flex-1 overflow-y-auto py-4 px-3 space-y-4">
          {navGroups.map((grp, gIdx) => (
            <div key={gIdx}>
              <div className="px-3 pb-1 text-[11px] font-bold text-outline uppercase tracking-wider">
                {grp.title}
              </div>
              <ul className="space-y-0.5">
                {grp.items.map((item, idx) => {
                  const active = isCurrent(item.path)
                  return (
                    <li key={idx}>
                      <Link
                        to={item.path}
                        className={`flex items-center justify-between px-3 py-2 rounded-lg font-label-md text-sm transition-all duration-150 active:scale-[0.99] ${
                          active
                            ? 'text-primary font-bold bg-primary-container/15 border-l-4 border-primary pl-2.5'
                            : 'text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface'
                        }`}
                      >
                        <div className="flex items-center gap-3">
                          <span className={`material-symbols-outlined text-[20px] ${active ? 'icon-fill text-primary' : 'text-outline'}`}>
                            {item.icon}
                          </span>
                          <span>{item.label}</span>
                        </div>
                        {item.badge && (
                          <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-error-container text-on-error-container">
                            {item.badge}
                          </span>
                        )}
                      </Link>
                    </li>
                  )
                })}
              </ul>
            </div>
          ))}
        </div>

        {/* Footer Profile & Settings */}
        <div className="p-4 border-t border-surface-container-low mt-auto bg-surface-bright">
          <ul className="space-y-1">
            <li>
              <Link
                to="/security-settings"
                className="flex items-center gap-3 px-3 py-2 text-on-surface-variant hover:bg-surface-container-high rounded-lg text-sm transition-colors"
              >
                <span className="material-symbols-outlined text-[20px]">settings</span>
                <span>Settings</span>
              </Link>
            </li>
            <li>
              <Link
                to="/maintenance"
                className="flex items-center gap-3 px-3 py-2 text-on-surface-variant hover:bg-surface-container-high rounded-lg text-sm transition-colors"
              >
                <span className="material-symbols-outlined text-[20px]">help</span>
                <span>Diagnostics & Health</span>
              </Link>
            </li>
          </ul>
        </div>
      </nav>

      {/* ── Main Content Container ── */}
      <main className="md:pl-64 pt-24 px-6 pb-12 md:pt-24 md:px-8 md:pb-16 min-h-screen bg-background">
        <div className="max-w-7xl mx-auto">
          {children}
        </div>
      </main>
    </div>
  )
}
