import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { clearToken } from '../api'

export default function Layout({ children, admin, onLogout }) {
  const location = useLocation()
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState('')
  const [showSearchDropdown, setShowSearchDropdown] = useState(false)
  const [showNotifs, setShowNotifs] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)

  const handleLogout = () => {
    if (onLogout) {
      onLogout()
    } else {
      clearToken()
    }
    navigate('/login')
  }

  const navGroups = [
    {
      title: 'Operations Center',
      items: [
        { path: '/dashboard', label: 'Command Center', icon: 'dashboard' },
        { path: '/scam-reports', label: 'Threat Interceptions', icon: 'emergency' },
        { path: '/crisis-handover', label: '1930 Crisis Handover', icon: 'support_agent' },
      ]
    },
    {
      title: 'Senior Protection Network',
      items: [
        { path: '/users', label: 'Senior Citizens', icon: 'elderly' },
        { path: '/guardians', label: 'Guardian Safety Circle', icon: 'family_restroom' },
      ]
    },
    {
      title: 'Threat Intel & Rules',
      items: [
        { path: '/patterns', label: 'Threat Rules Engine', icon: 'rule' },
        { path: '/rules-sandbox', label: 'Rule Testing Sandbox', icon: 'science' },
        { path: '/badges', label: '12 Defense Badges', icon: 'military_tech' },
      ]
    },
    {
      title: 'SecOps Governance',
      items: [
        { path: '/audit-log', label: 'Security Audit Trail', icon: 'shield' },
        { path: '/admins', label: 'SecOps Admin Team', icon: 'admin_panel_settings' },
      ]
    }
  ]

  const isCurrent = (path) => location.pathname === path

  const allNavItems = navGroups.flatMap(g => g.items)
  const searchResults = searchTerm.trim()
    ? allNavItems.filter(item => item.label.toLowerCase().includes(searchTerm.toLowerCase()))
    : []

  const recentNotifs = [
    { id: 1, title: 'Suspicious Login Location', desc: 'Martha Jenkins - Unknown IP in Frankfurt', time: '10m ago', urgent: true },
    { id: 2, title: 'Phishing SMS Blocked', desc: 'Auto-quarantined fake TRAI verification link', time: '35m ago', urgent: false },
    { id: 3, title: 'Geofence Exit Alert', desc: 'Robert Chen departed safe perimeter', time: '1h ago', urgent: true }
  ]

  return (
    <div className="bg-[#0f172a] text-slate-100 font-body-md min-h-screen">
      {/* ── TopAppBar (Glassmorphic Operations Header) ── */}
      <header className="fixed top-0 right-0 left-0 md:left-64 h-16 z-30 flex items-center justify-between px-4 sm:px-6 bg-slate-900/80 backdrop-blur-xl border-b border-slate-800/80 shadow-lg shadow-black/20">
        {/* Mobile menu toggle & Search Bar */}
        <div className="flex items-center gap-3 flex-1 max-w-md relative">
          <button
            onClick={() => setMobileOpen(!mobileOpen)}
            className="md:hidden p-2 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
            aria-label="Toggle navigation"
          >
            <span className="material-symbols-outlined text-2xl">menu</span>
          </button>

          <div className="relative flex-1 focus-within:ring-1 focus-within:ring-emerald-500 rounded-full transition-all">
            <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
              search
            </span>
            <input
              type="text"
              placeholder="Search alerts, rules, users..."
              value={searchTerm}
              onFocus={() => setShowSearchDropdown(true)}
              onBlur={() => setTimeout(() => setShowSearchDropdown(false), 200)}
              onChange={(e) => setSearchTerm(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && searchResults.length > 0) {
                  navigate(searchResults[0].path)
                  setShowSearchDropdown(false)
                  setSearchTerm('')
                }
              }}
              className="w-full bg-slate-950/60 border border-slate-800/90 rounded-full py-2 pl-10 pr-4 text-xs sm:text-sm text-slate-200 placeholder:text-slate-500 focus:outline-none focus:bg-slate-950 h-[38px] transition-colors"
            />
          </div>

          {/* Autocomplete Search Dropdown */}
          {showSearchDropdown && searchResults.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-2 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl overflow-hidden z-50 p-2 text-xs">
              <div className="px-3 py-1.5 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                Matching Pages ({searchResults.length})
              </div>
              <ul className="space-y-1">
                {searchResults.map(res => (
                  <li key={res.path}>
                    <button
                      onMouseDown={() => {
                        navigate(res.path)
                        setSearchTerm('')
                        setShowSearchDropdown(false)
                      }}
                      className="w-full text-left px-3 py-2 rounded-xl hover:bg-slate-800 text-slate-200 flex items-center justify-between font-medium"
                    >
                      <div className="flex items-center gap-2">
                        <span className="material-symbols-outlined text-emerald-400 text-base">{res.icon}</span>
                        <span>{res.label}</span>
                      </div>
                      <span className="text-[10px] text-slate-500 font-mono">{res.path}</span>
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>

        {/* Trailing Actions */}
        <div className="flex items-center gap-2 sm:gap-3 relative">
          {/* Live Operations Indicator */}
          <div className="hidden sm:flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            <span>Shield Active</span>
          </div>

          {/* Notification Button */}
          <div className="relative">
            <button
              aria-label="Alerts"
              onClick={() => setShowNotifs(!showNotifs)}
              className="w-10 h-10 flex items-center justify-center rounded-xl hover:bg-slate-800/80 transition-colors text-slate-300 relative border border-transparent hover:border-slate-700/60"
            >
              <span className="material-symbols-outlined text-[22px]">notifications</span>
              <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-rose-500 rounded-full border-2 border-slate-900"></span>
            </button>

            {/* Notifications Popover */}
            {showNotifs && (
              <div className="absolute right-0 top-full mt-2 w-80 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl z-50 p-4 space-y-3 text-xs">
                <div className="flex items-center justify-between border-b border-slate-800 pb-2">
                  <span className="font-bold text-white text-sm">Critical Notifications</span>
                  <button onClick={() => navigate('/scam-reports')} className="text-[11px] text-emerald-400 font-bold hover:underline">
                    Threat Interceptions &rarr;
                  </button>
                </div>
                <ul className="space-y-2">
                  {recentNotifs.map(n => (
                    <li
                      key={n.id}
                      onClick={() => {
                        setShowNotifs(false)
                        navigate('/scam-reports')
                      }}
                      className="p-2.5 rounded-xl bg-slate-950/60 border border-slate-800/80 hover:border-slate-700 cursor-pointer space-y-1 transition-all"
                    >
                      <div className="flex items-center justify-between">
                        <span className={`font-bold ${n.urgent ? 'text-rose-400' : 'text-slate-200'}`}>{n.title}</span>
                        <span className="text-[10px] text-slate-500">{n.time}</span>
                      </div>
                      <p className="text-[11px] text-slate-400">{n.desc}</p>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>

          <button
            aria-label="Audit History"
            onClick={() => navigate('/audit-log')}
            className="w-10 h-10 flex items-center justify-center rounded-xl hover:bg-slate-800/80 transition-colors text-slate-300 border border-transparent hover:border-slate-700/60"
          >
            <span className="material-symbols-outlined text-[22px]">history</span>
          </button>

          <div className="flex items-center gap-3 pl-3 border-l border-slate-800/90">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-emerald-600 to-teal-500 text-white flex items-center justify-center font-bold text-xs shadow-md shadow-emerald-950/40 border border-emerald-400/30">
              VM
            </div>
            <div className="hidden lg:block text-left">
              <div className="text-xs font-bold text-slate-200 leading-tight">{admin?.name || 'Vraj Mehta'}</div>
              <div className="text-[11px] text-emerald-400 font-medium leading-tight">{admin?.role || 'SecOps Lead'}</div>
            </div>
            <button
              onClick={handleLogout}
              className="p-1.5 text-slate-400 hover:text-rose-400 transition-colors rounded-lg hover:bg-slate-800/80"
              title="Logout"
            >
              <span className="material-symbols-outlined text-[20px]">logout</span>
            </button>
          </div>
        </div>
      </header>

      {/* ── SideNavBar (Dark Glassmorphic Sidebar) ── */}
      <nav
        aria-label="Main Navigation"
        className={`fixed left-0 top-0 h-screen w-64 z-40 flex flex-col bg-slate-900/95 backdrop-blur-2xl border-r border-slate-800/80 shadow-2xl transition-transform duration-300 md:translate-x-0 ${
          mobileOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {/* Brand Header */}
        <div className="p-5 border-b border-slate-800/80">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-500 flex items-center justify-center text-white shadow-lg shadow-emerald-500/20 border border-emerald-400/30">
                <span className="material-symbols-outlined text-2xl icon-fill">shield</span>
              </div>
              <div>
                <h1 className="font-headline-sm text-lg font-bold text-white tracking-tight leading-none">SafeSenior</h1>
                <p className="text-[10px] text-emerald-400 font-semibold uppercase tracking-widest mt-1">Ops Console</p>
              </div>
            </div>
            <button
              onClick={() => setMobileOpen(false)}
              className="md:hidden text-slate-400 hover:text-white"
            >
              <span className="material-symbols-outlined">close</span>
            </button>
          </div>

          <button
            onClick={() => {
              navigate('/patterns?create=true')
              setMobileOpen(false)
            }}
            className="mt-4 w-full bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white rounded-xl py-2.5 px-4 text-xs font-bold flex items-center justify-center gap-2 shadow-lg shadow-emerald-950/40 transition-all active:scale-[0.99]"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            New System Rule
          </button>
        </div>

        {/* Grouped Navigation Links */}
        <div className="flex-1 overflow-y-auto py-4 px-3 space-y-4 custom-scrollbar">
          {navGroups.map((grp, gIdx) => (
            <div key={gIdx}>
              <div className="px-3 pb-1.5 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                {grp.title}
              </div>
              <ul className="space-y-1">
                {grp.items.map((item, idx) => {
                  const active = isCurrent(item.path)
                  return (
                    <li key={idx}>
                      <Link
                        to={item.path}
                        onClick={() => setMobileOpen(false)}
                        className={`flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-all duration-150 active:scale-[0.99] ${
                          active
                            ? 'text-emerald-400 font-bold bg-emerald-500/10 border-l-4 border-emerald-500 pl-2.5 shadow-sm'
                            : 'text-slate-400 hover:bg-slate-800/60 hover:text-slate-200'
                        }`}
                      >
                        <div className="flex items-center gap-3">
                          <span className={`material-symbols-outlined text-[19px] ${active ? 'icon-fill text-emerald-400' : 'text-slate-500'}`}>
                            {item.icon}
                          </span>
                          <span>{item.label}</span>
                        </div>
                        {item.badge && (
                          <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-rose-500/20 text-rose-400 border border-rose-500/30">
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
        <div className="p-3 border-t border-slate-800/80 mt-auto bg-slate-950/60">
          <ul className="space-y-1">
            <li>
              <Link
                to="/security-settings"
                onClick={() => setMobileOpen(false)}
                className="flex items-center gap-3 px-3 py-2 text-slate-400 hover:bg-slate-800/60 hover:text-slate-200 rounded-xl text-xs font-medium transition-colors"
              >
                <span className="material-symbols-outlined text-[19px]">settings</span>
                <span>Security Settings</span>
              </Link>
            </li>
            <li>
              <Link
                to="/maintenance"
                onClick={() => setMobileOpen(false)}
                className="flex items-center gap-3 px-3 py-2 text-slate-400 hover:bg-slate-800/60 hover:text-slate-200 rounded-xl text-xs font-medium transition-colors"
              >
                <span className="material-symbols-outlined text-[19px]">health_and_safety</span>
                <span>Diagnostics & Health</span>
              </Link>
            </li>
          </ul>
        </div>
      </nav>

      {/* Backdrop for Mobile Drawer */}
      {mobileOpen && (
        <div
          onClick={() => setMobileOpen(false)}
          className="fixed inset-0 z-30 bg-black/60 backdrop-blur-sm md:hidden"
        ></div>
      )}

      {/* ── Main Content Container ── */}
      <main className="md:pl-64 pt-20 px-4 sm:px-6 pb-12 md:pt-22 md:px-8 md:pb-16 min-h-screen bg-[#0f172a]">
        <div className="max-w-7xl mx-auto">
          {children}
        </div>
      </main>
    </div>
  )
}
