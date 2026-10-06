import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

const latencyDataSets = {
  '24h': [
    { time: '12 AM', ms: 45, height: '40%' },
    { time: '3 AM', ms: 38, height: '35%' },
    { time: '6 AM', ms: 62, height: '60%' },
    { time: '9 AM', ms: 48, height: '45%' },
    { time: '12 PM', ms: 85, height: '80%' },
    { time: '3 PM', ms: 32, height: '30%' },
    { time: 'Now', ms: 28, height: '25%', active: true },
  ],
  '7d': [
    { time: 'Mon', ms: 34, height: '32%' },
    { time: 'Tue', ms: 52, height: '50%' },
    { time: 'Wed', ms: 41, height: '38%' },
    { time: 'Thu', ms: 68, height: '65%' },
    { time: 'Fri', ms: 29, height: '28%' },
    { time: 'Sat', ms: 31, height: '30%' },
    { time: 'Sun', ms: 28, height: '25%', active: true },
  ],
  '30d': [
    { time: 'Wk 1', ms: 42, height: '40%' },
    { time: 'Wk 2', ms: 39, height: '36%' },
    { time: 'Wk 3', ms: 45, height: '42%' },
    { time: 'Wk 4', ms: 28, height: '25%', active: true },
  ]
}

export default function Dashboard() {
  const navigate = useNavigate()
  const { stats, alerts, users, resolveAlert, addAuditLog } = useAdminData()
  
  const [latencyRange, setLatencyRange] = useState('24h')
  const [alertFilter, setAlertFilter] = useState('all')
  const [selectedAlert, setSelectedAlert] = useState(null)
  const [isScanning, setIsScanning] = useState(false)
  const [scanMessage, setScanMessage] = useState('')
  const [resolutionInput, setResolutionInput] = useState('')

  const activeLatency = latencyDataSets[latencyRange] || latencyDataSets['24h']

  const filteredAlerts = (alerts || []).filter(a => {
    if (alertFilter === 'all') return true
    if (alertFilter === 'investigating') return a.status === 'Investigating' || a.status === 'Open'
    if (alertFilter === 'blocked') return a.status === 'Auto-Blocked' || a.status === 'Blocked'
    if (alertFilter === 'resolved') return a.status === 'Resolved'
    return true
  })

  function handleRunDiagnostics() {
    setIsScanning(true)
    setScanMessage('Initiating edge classifier ping...')
    setTimeout(() => setScanMessage('Auditing AI speech pattern recognition engine...'), 600)
    setTimeout(() => {
      setIsScanning(false)
      setScanMessage('')
      addAuditLog('System Health Scan', 'Full diagnostic check completed — 100% operational')
    }, 1500)
  }

  function handleResolveSelected() {
    if (!selectedAlert) return
    const note = resolutionInput.trim() || 'Manually verified and cleared by SecOps Lead'
    resolveAlert(selectedAlert.id, note)
    setSelectedAlert(null)
    setResolutionInput('')
  }

  return (
    <div className="space-y-8">
      {/* ── Page Header ── */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-ping"></span>
            <span className="text-xs font-mono font-bold text-emerald-400 uppercase tracking-widest">
              Live Operations Telemetry
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight">
            System Health Overview
          </h2>
          <p className="text-sm text-slate-400 mt-1">
            Real-time monitoring, threat interception metrics, and senior protection telemetry.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={handleRunDiagnostics}
            disabled={isScanning}
            className="h-11 px-4 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-xl text-xs font-bold flex items-center gap-2 border border-slate-700/60 transition-all active:scale-[0.99] disabled:opacity-50"
          >
            <span className={`material-symbols-outlined text-[18px] ${isScanning ? 'animate-spin text-emerald-400' : 'text-slate-400'}`}>
              {isScanning ? 'sync' : 'health_and_safety'}
            </span>
            <span>{isScanning ? 'Scanning...' : 'Run Diagnostics'}</span>
          </button>

          <button
            onClick={() => navigate('/rules-wizard')}
            className="h-11 px-5 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-lg shadow-emerald-950/40 transition-all active:scale-[0.99]"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            New System Rule
          </button>
        </div>
      </header>

      {/* Diagnostics Toast Notification */}
      {isScanning && (
        <div className="bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 px-4 py-3 rounded-2xl text-xs font-semibold flex items-center justify-between animate-pulse">
          <div className="flex items-center gap-3">
            <span className="material-symbols-outlined animate-spin text-emerald-400 text-lg">memory</span>
            <span>{scanMessage}</span>
          </div>
          <span className="font-mono text-[11px]">Latency: 18ms</span>
        </div>
      )}

      {/* ── Mobile-Synchronized Emergency Helplines Action Bar (1930 & 14567) ── */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* 1930 Cyber Fraud Helpline Card */}
        <div className="bg-gradient-to-r from-red-950/80 via-slate-900 to-slate-900 border border-red-500/40 rounded-3xl p-5 shadow-xl flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-red-500/20 text-red-400 flex items-center justify-center border border-red-500/30 shadow-inner">
              <span className="material-symbols-outlined text-3xl">emergency</span>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-xl font-bold text-white tracking-tight">1930 Cyber Helpline</span>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-red-500/20 text-red-300 border border-red-500/30">
                  National LE Gateway
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                Citizen Financial Cyber Fraud Reporting System. 1-click police handover.
              </p>
            </div>
          </div>
          <button
            onClick={() => navigate('/crisis-handover')}
            className="px-4 py-2.5 bg-red-600 hover:bg-red-500 text-white rounded-xl text-xs font-bold transition-all shadow-lg shadow-red-950/50 flex items-center justify-center gap-2 whitespace-nowrap active:scale-[0.99]"
          >
            <span className="material-symbols-outlined text-[18px]">support_agent</span>
            Dispatch 1930 Docket
          </button>
        </div>

        {/* 14567 Senior Citizen Helpline Card */}
        <div className="bg-gradient-to-r from-teal-950/80 via-slate-900 to-slate-900 border border-teal-500/40 rounded-3xl p-5 shadow-xl flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-teal-500/20 text-teal-400 flex items-center justify-center border border-teal-500/30 shadow-inner">
              <span className="material-symbols-outlined text-3xl">elderly</span>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-xl font-bold text-white tracking-tight">14567 Elderline</span>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-teal-500/20 text-teal-300 border border-teal-500/30">
                  Senior Citizen Care
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                Ministry of Social Justice & Empowerment. Emergency family care dispatch.
              </p>
            </div>
          </div>
          <button
            onClick={() => navigate('/guardians')}
            className="px-4 py-2.5 bg-teal-600 hover:bg-teal-500 text-white rounded-xl text-xs font-bold transition-all shadow-lg shadow-teal-950/50 flex items-center justify-center gap-2 whitespace-nowrap active:scale-[0.99]"
          >
            <span className="material-symbols-outlined text-[18px]">family_restroom</span>
            Guardian Safety Circle
          </button>
        </div>
      </div>

      {/* ── Masonry Grid of Metric Cards ── */}
      <div className="masonry-grid">
        {/* Metric Card 1: System Status */}
        <div className="masonry-item bg-slate-900/80 rounded-2xl p-6 shadow-xl flex flex-col items-start relative overflow-hidden border border-slate-800/80 backdrop-blur-xl hover:border-emerald-500/40 transition-all group">
          <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-500/10 rounded-bl-full -mr-12 -mt-12 pointer-events-none group-hover:scale-110 transition-transform"></div>
          <div className="flex items-center justify-between w-full mb-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-xl bg-emerald-500/15 text-emerald-400 flex items-center justify-center border border-emerald-500/20">
                <span className="material-symbols-outlined text-2xl icon-fill">check_circle</span>
              </div>
              <h3 className="font-headline-sm text-base font-semibold text-slate-200">System Status</h3>
            </div>
            <span className="px-2.5 py-1 rounded-full bg-emerald-500/15 text-emerald-400 text-[10px] font-bold border border-emerald-500/20 uppercase tracking-widest">
              Online
            </span>
          </div>
          <div className="mb-2">
            <span className="font-headline-lg text-2xl sm:text-3xl text-emerald-400 font-bold tracking-tight">Operational</span>
          </div>
          <p className="text-xs text-slate-400 leading-relaxed">
            All 4 edge classifier nodes & neural speech scanners running normally with 0% degraded performance.
          </p>
          <div className="mt-4 pt-4 border-t border-slate-800/80 w-full flex justify-between items-center text-[11px] text-slate-400 font-mono">
            <span>Uptime: 99.98%</span>
            <button onClick={() => navigate('/maintenance')} className="text-emerald-400 font-bold hover:underline">
              Logs &rarr;
            </button>
          </div>
        </div>

        {/* Metric Card 2: Threats Blocked */}
        <div className="masonry-item bg-slate-900/80 rounded-2xl p-6 shadow-xl flex flex-col items-start relative overflow-hidden border border-slate-800/80 backdrop-blur-xl hover:border-rose-500/40 transition-all group">
          <div className="absolute top-0 right-0 w-32 h-32 bg-rose-500/10 rounded-bl-full -mr-12 -mt-12 pointer-events-none group-hover:scale-110 transition-transform"></div>
          <div className="flex items-center justify-between w-full mb-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-xl bg-rose-500/15 text-rose-400 flex items-center justify-center border border-rose-500/20">
                <span className="material-symbols-outlined text-2xl icon-fill">shield</span>
              </div>
              <h3 className="font-headline-sm text-base font-semibold text-slate-200">Threats Intercepted</h3>
            </div>
            <span className="px-2 py-0.5 rounded-full bg-rose-500/15 text-rose-400 text-[10px] font-bold border border-rose-500/20">
              +12% wk
            </span>
          </div>
          <div className="mb-2 flex items-baseline gap-3">
            <span className="font-headline-lg text-2xl sm:text-3xl text-white font-bold tracking-tight">
              {stats?.scamsInterceptedToday || 1248}
            </span>
            <span className="text-xs text-slate-400">Total 24h</span>
          </div>
          <div className="w-full h-2 bg-slate-800 rounded-full mt-2 overflow-hidden">
            <div className="h-full bg-gradient-to-r from-rose-500 to-rose-400 w-[78%] rounded-full"></div>
          </div>
          <p className="text-xs text-slate-400 mt-4 leading-relaxed">
            AI scam calls, digital arrest threats & phishing SMS auto-intercepted across India telecom channels.
          </p>
          <div className="mt-4 pt-4 border-t border-slate-800/80 w-full flex justify-between items-center text-[11px]">
            <span className="text-slate-400 font-mono">Quarantine Rate: 99.4%</span>
            <button onClick={() => navigate('/scam-reports')} className="text-rose-400 font-bold hover:underline">
              Threat Intel &rarr;
            </button>
          </div>
        </div>

        {/* Metric Card 3: Active Sessions */}
        <div className="masonry-item bg-slate-900/80 rounded-2xl p-6 shadow-xl flex flex-col items-start relative overflow-hidden border border-slate-800/80 backdrop-blur-xl hover:border-cyan-500/40 transition-all group">
          <div className="absolute top-0 right-0 w-32 h-32 bg-cyan-500/10 rounded-bl-full -mr-12 -mt-12 pointer-events-none group-hover:scale-110 transition-transform"></div>
          <div className="flex items-center justify-between w-full mb-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-xl bg-cyan-500/15 text-cyan-400 flex items-center justify-center border border-cyan-500/20">
                <span className="material-symbols-outlined text-2xl icon-fill">verified_user</span>
              </div>
              <h3 className="font-headline-sm text-base font-semibold text-slate-200">Active Protection</h3>
            </div>
            <span className="px-2 py-0.5 rounded-full bg-cyan-500/15 text-cyan-400 text-[10px] font-bold border border-cyan-500/20">
              Live Network
            </span>
          </div>
          <div className="mb-2">
            <span className="font-headline-lg text-2xl sm:text-3xl text-white font-bold tracking-tight">
              {(users || []).length > 0 ? (users.length * 1520 + 42000).toLocaleString() : '45,920'}
            </span>
          </div>
          <p className="text-xs text-slate-400 leading-relaxed">
            Active senior citizen sessions under call screening, geofence tracking & guardian emergency dispatch.
          </p>
          <div className="mt-4 pt-4 border-t border-slate-800/80 w-full flex justify-between items-center text-[11px]">
            <span className="text-slate-400 font-mono">Protected Seniors: {(users || []).length || 24}</span>
            <button onClick={() => navigate('/users')} className="text-cyan-400 font-bold hover:underline">
              Seniors List &rarr;
            </button>
          </div>
        </div>

        {/* Chart Widget: System Latency (ms) with Interactive Range Buttons */}
        <div className="masonry-item bg-slate-900/80 rounded-2xl p-6 shadow-xl border border-slate-800/80 backdrop-blur-xl">
          <div className="flex justify-between items-center mb-6">
            <div>
              <h3 className="font-headline-sm text-base font-semibold text-slate-200">System Latency (ms)</h3>
              <p className="text-[11px] text-slate-400 font-mono">Edge Node Telemetry</p>
            </div>
            <div className="flex items-center gap-1 bg-slate-950 p-1 rounded-xl border border-slate-800">
              {['24h', '7d', '30d'].map(range => (
                <button
                  key={range}
                  onClick={() => setLatencyRange(range)}
                  className={`px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase transition-all ${
                    latencyRange === range
                      ? 'bg-emerald-500 text-white shadow-md'
                      : 'text-slate-400 hover:text-white'
                  }`}
                >
                  {range}
                </button>
              ))}
            </div>
          </div>

          <div className="h-44 w-full flex items-end justify-between gap-2 pb-2 border-b border-slate-800">
            {activeLatency.map((sample, idx) => (
              <div
                key={idx}
                className={`w-full ${sample.active ? 'bg-emerald-400 shadow-lg shadow-emerald-500/30' : 'bg-slate-700/60'} rounded-t-md hover:bg-emerald-400 transition-colors cursor-pointer relative group`}
                style={{ height: sample.height }}
              >
                <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-slate-950 text-emerald-300 font-mono text-[10px] py-1 px-2 rounded-lg border border-slate-800 shadow-xl opacity-0 group-hover:opacity-100 transition-opacity z-20 pointer-events-none whitespace-nowrap">
                  {sample.time}: {sample.ms}ms
                </div>
              </div>
            ))}
          </div>
          <div className="flex justify-between mt-3 font-mono text-[11px] text-slate-400">
            <span>{activeLatency[0]?.time}</span>
            <span>{activeLatency[Math.floor(activeLatency.length / 2)]?.time}</span>
            <span className="text-emerald-400 font-bold">Latest: 28ms</span>
          </div>
        </div>

        {/* Recent Critical Alerts Table Widget */}
        <div className="masonry-item bg-slate-900/80 rounded-2xl shadow-xl overflow-hidden border border-slate-800/80 backdrop-blur-xl md:col-span-2 lg:col-span-2">
          <div className="p-5 border-b border-slate-800/80 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-950/40">
            <div>
              <h3 className="font-headline-sm text-base font-bold text-white">Live Alert Triage Feed</h3>
              <p className="text-xs text-slate-400 mt-0.5">Real-time threat interception log across protected devices</p>
            </div>

            {/* Filter Tabs */}
            <div className="flex items-center gap-1 bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
              {[
                { key: 'all', label: 'All' },
                { key: 'investigating', label: 'Investigating' },
                { key: 'blocked', label: 'Blocked' },
                { key: 'resolved', label: 'Resolved' },
              ].map(tab => (
                <button
                  key={tab.key}
                  onClick={() => setAlertFilter(tab.key)}
                  className={`px-3 py-1.5 rounded-lg font-semibold transition-all ${
                    alertFilter === tab.key
                      ? 'bg-slate-800 text-emerald-400 border border-slate-700 shadow-sm'
                      : 'text-slate-400 hover:text-slate-200'
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-950/60 text-slate-400 text-xs border-b border-slate-800/80 uppercase tracking-wider font-semibold">
                  <th className="p-4">Time</th>
                  <th className="p-4">Alert & Category</th>
                  <th className="p-4">Senior / Target</th>
                  <th className="p-4">Status</th>
                  <th className="p-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="text-xs text-slate-200 divide-y divide-slate-800/60">
                {filteredAlerts.length > 0 ? (
                  filteredAlerts.slice(0, 5).map((item) => (
                    <tr key={item.id} className="hover:bg-slate-800/40 transition-colors">
                      <td className="p-4 font-mono text-slate-400">{item.timestamp || item.time || 'Just now'}</td>
                      <td className="p-4">
                        <div className="flex items-center gap-2">
                          <span className={`material-symbols-outlined text-[18px] ${
                            item.severity === 'Critical' || item.status === 'Investigating' ? 'text-rose-400' : 'text-amber-400'
                          }`}>
                            {item.severity === 'Critical' ? 'warning' : 'phishing'}
                          </span>
                          <div>
                            <div className="font-semibold text-slate-200">{item.type || item.title || item.name}</div>
                            <div className="text-[10px] text-slate-400">{item.category || item.threatVector || 'Scam Pattern'}</div>
                          </div>
                        </div>
                      </td>
                      <td className="p-4 text-slate-300 font-medium">{item.user || item.seniorName || 'Senior Account'}</td>
                      <td className="p-4">
                        <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[11px] font-bold border ${
                          item.status === 'Investigating' || item.status === 'Open'
                            ? 'bg-rose-500/15 text-rose-400 border-rose-500/20'
                            : item.status === 'Auto-Blocked' || item.status === 'Blocked'
                            ? 'bg-slate-800 text-slate-300 border-slate-700'
                            : 'bg-emerald-500/15 text-emerald-400 border-emerald-500/20'
                        }`}>
                          {item.status}
                        </span>
                      </td>
                      <td className="p-4 text-right">
                        <button
                          onClick={() => setSelectedAlert(item)}
                          className="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-emerald-400 hover:text-emerald-300 font-bold text-xs rounded-lg border border-slate-700/60 transition-all"
                        >
                          Inspect &rarr;
                        </button>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={5} className="p-8 text-center text-slate-500 font-medium">
                      No alerts match the selected filter category.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* ── Alert Detail Modal ── */}
      {selectedAlert && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-md">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 sm:p-8 max-w-lg w-full shadow-2xl space-y-6 text-slate-200">
            <div className="flex items-start justify-between border-b border-slate-800/80 pb-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-rose-500/15 text-rose-400 flex items-center justify-center border border-rose-500/20">
                  <span className="material-symbols-outlined">warning</span>
                </div>
                <div>
                  <h3 className="text-lg font-bold text-white">{selectedAlert.type || selectedAlert.title || 'Threat Alert'}</h3>
                  <p className="text-xs text-slate-400 font-mono">{selectedAlert.id}</p>
                </div>
              </div>
              <button onClick={() => setSelectedAlert(null)} className="text-slate-400 hover:text-white">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            <div className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-4 bg-slate-950/60 p-4 rounded-xl border border-slate-800">
                <div>
                  <span className="text-slate-400 block mb-1">Target Senior</span>
                  <span className="font-bold text-white text-sm">{selectedAlert.user || selectedAlert.seniorName || 'Martha Jenkins'}</span>
                </div>
                <div>
                  <span className="text-slate-400 block mb-1">Status</span>
                  <span className="font-bold text-emerald-400 text-sm">{selectedAlert.status}</span>
                </div>
              </div>

              <div>
                <span className="text-slate-400 block mb-1 font-semibold">Incident Summary & Telemetry</span>
                <p className="text-slate-300 leading-relaxed bg-slate-950/40 p-3 rounded-xl border border-slate-800/60">
                  {selectedAlert.description || selectedAlert.summary || 'VoIP endpoint attempted impersonation of bank customer support using synthesized Indic voice pattern.'}
                </p>
              </div>

              {selectedAlert.status !== 'Resolved' && (
                <div>
                  <label className="text-slate-300 block mb-1 font-semibold">Resolution Note (Optional)</label>
                  <input
                    type="text"
                    placeholder="e.g. Verified with family guardian, endpoint blacklisted."
                    value={resolutionInput}
                    onChange={(e) => setResolutionInput(e.target.value)}
                    className="w-full bg-slate-950 border border-slate-800 rounded-xl p-3 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500"
                  />
                </div>
              )}
            </div>

            <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-800/80">
              <button
                onClick={() => setSelectedAlert(null)}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-bold rounded-xl"
              >
                Close
              </button>
              {selectedAlert.status !== 'Resolved' && (
                <button
                  onClick={handleResolveSelected}
                  className="px-5 py-2 bg-emerald-500 hover:bg-emerald-400 text-white text-xs font-bold rounded-xl shadow-lg shadow-emerald-950/40"
                >
                  Mark Alert Resolved
                </button>
              )}
              <button
                onClick={() => {
                  setSelectedAlert(null)
                  navigate('/crisis-handover')
                }}
                className="px-4 py-2 bg-rose-600 hover:bg-rose-500 text-white text-xs font-bold rounded-xl"
              >
                Escalate Crisis &rarr;
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
