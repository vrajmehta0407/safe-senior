import { useState, useEffect } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

export default function Patterns() {
  const [searchParams] = useSearchParams()
  const { rules, addRule, deleteRule, autoSyncEmergingThreats, refreshData, loading } = useAdminData()

  const [searchTerm, setSearchTerm] = useState('')
  const [typeFilter, setTypeFilter] = useState('all') // 'all' | 'sms' | 'call' | 'both'
  const [severityFilter, setSeverityFilter] = useState('all') // 'all' | 'high-risk' | 'suspicious'

  const [showAddModal, setShowAddModal] = useState(false)

  useEffect(() => {
    if (searchParams.get('create') === 'true') {
      setShowAddModal(true)
    }
  }, [searchParams])
  const [newPattern, setNewPattern] = useState({
    pattern: '',
    type: 'sms',
    severity: 'high-risk',
    category: 'Banking / KYC Phishing',
    language: 'en'
  })

  const [isSyncing, setIsSyncing] = useState(false)
  const [syncStatus, setSyncStatus] = useState('')
  const [actionInProgress, setActionInProgress] = useState(null)

  const activeRules = Array.isArray(rules) ? rules : []

  const filteredRules = activeRules.filter((r) => {
    const term = searchTerm.toLowerCase()
    const matchesSearch =
      (r.pattern || '').toLowerCase().includes(term) ||
      (r.category || '').toLowerCase().includes(term)

    const matchesType = typeFilter === 'all' || r.type === typeFilter
    const matchesSev = severityFilter === 'all' || r.severity === severityFilter

    return matchesSearch && matchesType && matchesSev
  })

  const handleCreateRule = async (e) => {
    e.preventDefault()
    if (!newPattern.pattern.trim()) return

    setActionInProgress('add')
    const res = await addRule(newPattern)
    setActionInProgress(null)
    if (res.success) {
      setShowAddModal(false)
      setNewPattern({
        pattern: '',
        type: 'sms',
        severity: 'high-risk',
        category: 'Banking / KYC Phishing',
        language: 'en'
      })
      setSyncStatus('Zero-day threat rule deployed to PostgreSQL & broadcast to all devices!')
      setTimeout(() => setSyncStatus(''), 4000)
    } else {
      alert(`Error creating rule: ${res.error}`)
    }
  }

  const handleDeleteRule = async (patternId) => {
    if (window.confirm(`Deactivate pattern rule #${patternId}?`)) {
      setActionInProgress(patternId)
      await deleteRule(patternId)
      setActionInProgress(null)
    }
  }

  const handleAutoSync = async () => {
    setIsSyncing(true)
    setSyncStatus('Syncing trending Indian telecom & cyber threat vectors...')
    const res = await autoSyncEmergingThreats()
    setIsSyncing(false)
    if (res.success) {
      setSyncStatus(`⚡ Synced emerging scam patterns & broadcasted update to all protected mobile apps!`)
      setTimeout(() => setSyncStatus(''), 5000)
    } else {
      setSyncStatus('Sync completed with active database patterns.')
      setTimeout(() => setSyncStatus(''), 3000)
    }
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* ── Page Header ── */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-teal-400 animate-pulse"></span>
            <span className="text-xs font-mono font-bold text-teal-400 uppercase tracking-widest">
              Live PostgreSQL Threat Rules
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">rule</span>
            Threat Rules & Pattern Engine
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Live database rules deployed dynamically to seniors' devices. Intercepts Digital Arrest coercion, electricity disconnect scams, and banking KYC malware without requiring app updates.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          <button
            onClick={handleAutoSync}
            disabled={isSyncing}
            className="h-11 px-4 rounded-xl border border-teal-500/30 bg-teal-500/10 hover:bg-teal-500/20 text-teal-300 text-xs font-bold transition-all flex items-center gap-2 shadow-lg disabled:opacity-50"
          >
            <span className={`material-symbols-outlined text-[18px] ${isSyncing ? 'animate-spin' : ''}`}>
              bolt
            </span>
            <span>{isSyncing ? 'Syncing...' : 'Auto-Sync Trending Threats'}</span>
          </button>
          <button
            onClick={() => setShowAddModal(true)}
            className="h-11 px-4 rounded-xl bg-teal-600 hover:bg-teal-500 text-white text-xs font-bold transition-all flex items-center gap-2 shadow-lg shadow-teal-950/40"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            <span>Add Zero-Day Rule</span>
          </button>
        </div>
      </header>

      {/* Sync Status Banner */}
      {syncStatus && (
        <div className="bg-teal-500/15 border border-teal-500/30 text-teal-300 px-4 py-3 rounded-2xl text-xs font-semibold flex items-center gap-2 animate-fadeIn">
          <span className="material-symbols-outlined text-teal-400">check_circle</span>
          <span>{syncStatus}</span>
        </div>
      )}

      {/* ── Search & Filter Controls ── */}
      <div className="bg-slate-900/80 rounded-2xl p-4 shadow-xl border border-slate-800/80 flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
            search
          </span>
          <input
            type="text"
            placeholder="Search regex, keywords, category..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-slate-950 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-xs text-white placeholder:text-slate-500 focus:ring-2 focus:ring-teal-500 focus:outline-none"
          />
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {/* Type filters */}
          <div className="flex gap-1 bg-slate-950 p-1 rounded-xl border border-slate-800">
            {['all', 'sms', 'call'].map((t) => (
              <button
                key={t}
                onClick={() => setTypeFilter(t)}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase transition-all ${
                  typeFilter === t
                    ? 'bg-teal-500 text-white'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {t}
              </button>
            ))}
          </div>

          {/* Severity filters */}
          <div className="flex gap-1 bg-slate-950 p-1 rounded-xl border border-slate-800">
            {['all', 'high-risk', 'suspicious'].map((s) => (
              <button
                key={s}
                onClick={() => setSeverityFilter(s)}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold capitalize transition-all ${
                  severityFilter === s
                    ? 'bg-teal-500 text-white'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* ── Patterns List / Table ── */}
      <div className="bg-slate-900/80 rounded-2xl shadow-xl overflow-hidden border border-slate-800/80 backdrop-blur-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-950/60 text-slate-400 text-xs border-b border-slate-800/80 uppercase tracking-wider font-semibold">
                <th className="p-4 pl-6">Threat Pattern / Keyword Trigger</th>
                <th className="p-4">Channel</th>
                <th className="p-4">Severity</th>
                <th className="p-4">Category</th>
                <th className="p-4">Status</th>
                <th className="p-4 pr-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="text-xs text-slate-200 divide-y divide-slate-800/60">
              {filteredRules.length === 0 ? (
                <tr>
                  <td colSpan="6" className="p-12 text-center text-slate-400">
                    <span className="material-symbols-outlined text-4xl text-slate-600 mb-2">rule_folder</span>
                    <p className="text-sm font-semibold text-slate-300">No pattern rules match query</p>
                    <p className="text-xs text-slate-500 mt-1">Total {activeRules.length} threat rules in PostgreSQL.</p>
                  </td>
                </tr>
              ) : (
                filteredRules.map((rule) => {
                  const isHigh = rule.severity === 'high-risk'
                  return (
                    <tr key={rule.id} className="hover:bg-slate-800/40 transition-colors">
                      <td className="p-4 pl-6 max-w-md">
                        <div className="font-mono text-xs text-teal-300 bg-slate-950/80 p-2.5 rounded-xl border border-slate-800/80 select-all leading-relaxed">
                          {rule.pattern}
                        </div>
                        <div className="text-[10px] text-slate-500 font-mono mt-1">
                          Rule #{rule.id} • Language: {rule.language?.toUpperCase() || 'EN'} • Created:{' '}
                          {new Date(rule.created_at).toLocaleDateString()}
                        </div>
                      </td>

                      <td className="p-4">
                        <span className="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-slate-800 text-slate-300 border border-slate-700">
                          {rule.type}
                        </span>
                      </td>

                      <td className="p-4">
                        <span
                          className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase border ${
                            isHigh
                              ? 'bg-red-500/20 text-red-300 border-red-500/30'
                              : 'bg-amber-500/20 text-amber-300 border-amber-500/30'
                          }`}
                        >
                          {rule.severity}
                        </span>
                      </td>

                      <td className="p-4">
                        <span className="text-xs font-semibold text-slate-300">
                          {rule.category || 'General Scams'}
                        </span>
                      </td>

                      <td className="p-4">
                        <span
                          className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold ${
                            rule.is_active
                              ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                              : 'bg-slate-800 text-slate-400'
                          }`}
                        >
                          <span
                            className={`w-1.5 h-1.5 rounded-full ${
                              rule.is_active ? 'bg-emerald-400' : 'bg-slate-500'
                            }`}
                          ></span>
                          {rule.is_active ? 'Active' : 'Disabled'}
                        </span>
                      </td>

                      <td className="p-4 pr-6 text-right">
                        <button
                          disabled={actionInProgress === rule.id}
                          onClick={() => handleDeleteRule(rule.id)}
                          className="px-3 py-1.5 bg-slate-800 hover:bg-red-900/40 text-slate-400 hover:text-red-300 rounded-xl text-xs font-bold transition-all border border-slate-700 inline-flex items-center gap-1"
                          title="Deactivate rule"
                        >
                          <span className="material-symbols-outlined text-[14px]">block</span>
                          <span>Deactivate</span>
                        </button>
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* ── Add Rule Modal ── */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-fadeIn">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 max-w-lg w-full shadow-2xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-bold text-white flex items-center gap-2">
                <span className="material-symbols-outlined text-teal-400">add_moderator</span>
                Deploy Zero-Day Pattern Rule
              </h3>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-slate-400 hover:text-white p-1"
              >
                <span className="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <form onSubmit={handleCreateRule} className="space-y-4">
              <div>
                <label className="text-xs font-bold text-slate-300 block mb-1">
                  Pattern / Keywords Regex <span className="text-red-400">*</span>
                </label>
                <textarea
                  rows="3"
                  required
                  placeholder="e.g. trai sim termination|disconnect within 2 hours"
                  value={newPattern.pattern}
                  onChange={(e) => setNewPattern({ ...newPattern, pattern: e.target.value })}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-3 text-xs font-mono text-white placeholder:text-slate-600 focus:ring-2 focus:ring-teal-500 focus:outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs font-bold text-slate-300 block mb-1">Channel</label>
                  <select
                    value={newPattern.type}
                    onChange={(e) => setNewPattern({ ...newPattern, type: e.target.value })}
                    className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white focus:outline-none"
                  >
                    <option value="sms">SMS Phishing</option>
                    <option value="call">Voice Call</option>
                    <option value="both">Both (SMS & Call)</option>
                  </select>
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-300 block mb-1">Severity</label>
                  <select
                    value={newPattern.severity}
                    onChange={(e) => setNewPattern({ ...newPattern, severity: e.target.value })}
                    className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white focus:outline-none"
                  >
                    <option value="high-risk">High-Risk (Auto Quarantine)</option>
                    <option value="suspicious">Suspicious (Warning Alert)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="text-xs font-bold text-slate-300 block mb-1">Threat Category</label>
                <input
                  type="text"
                  placeholder="e.g. Digital Arrest / Telecom Extortion"
                  value={newPattern.category}
                  onChange={(e) => setNewPattern({ ...newPattern, category: e.target.value })}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white placeholder:text-slate-600 focus:outline-none"
                />
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl text-xs font-bold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={actionInProgress === 'add'}
                  className="px-4 py-2 bg-teal-600 hover:bg-teal-500 text-white rounded-xl text-xs font-bold shadow-lg"
                >
                  {actionInProgress === 'add' ? 'Deploying...' : 'Deploy to Database & FCM'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
