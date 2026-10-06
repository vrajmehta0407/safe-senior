import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function AuditLog() {
  const { auditLogs, loading, refreshData } = useAdminData()
  const [search, setSearch] = useState('')
  const [filterAction, setFilterAction] = useState('ALL')

  const activeLogs = Array.isArray(auditLogs) ? auditLogs : []

  const filtered = activeLogs.filter((log) => {
    const actor = log.admin_name || log.admin_email || log.actor || 'SecOps Admin'
    const action = log.action || ''
    const target = (log.target_type ? `${log.target_type} #${log.target_id || ''}` : '') +
                   (log.metadata ? ` ${JSON.stringify(log.metadata)}` : '')
    const term = search.toLowerCase()

    const matchSearch =
      actor.toLowerCase().includes(term) ||
      action.toLowerCase().includes(term) ||
      target.toLowerCase().includes(term)

    const matchAction = filterAction === 'ALL' || action.toLowerCase().includes(filterAction.toLowerCase())

    return matchSearch && matchAction
  })

  const handleExportCSV = () => {
    const header = 'ID,Timestamp,Admin Actor,Action,Target/Metadata,IP Address\n'
    const rows = filtered
      .map(
        (r) =>
          `"${r.id}","${new Date(r.created_at || r.timestamp || Date.now()).toLocaleString()}","${(
            r.admin_name || r.admin_email || 'Admin'
          ).replace(/"/g, '""')}","${r.action}","${(
            (r.target_type ? `${r.target_type} #${r.target_id || ''} ` : '') +
            (r.metadata ? JSON.stringify(r.metadata) : '')
          ).replace(/"/g, '""')}","${r.ip_address || r.ip || '127.0.0.1'}"`
      )
      .join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `SafeSenior_Real_Audit_Logs_${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* ── Page Header ── */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-teal-400 animate-pulse"></span>
            <span className="text-xs font-mono font-bold text-teal-400 uppercase tracking-widest">
              Live PostgreSQL Immutable Ledger
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">shield</span>
            SecOps Security Audit Trail
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Cryptographic ledger tracking every administrator login, zero-day threat rule deployment, user quarantine action, and emergency dispatch.
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={refreshData}
            className="h-11 px-4 rounded-xl border border-slate-700 bg-slate-800/60 hover:bg-slate-700 text-slate-200 text-xs font-bold transition-all flex items-center gap-2"
          >
            <span className={`material-symbols-outlined text-[18px] ${loading ? 'animate-spin text-teal-400' : ''}`}>
              refresh
            </span>
            <span>Refresh</span>
          </button>
          <button
            onClick={handleExportCSV}
            className="h-11 px-4 rounded-xl border border-teal-500/30 bg-teal-500/10 hover:bg-teal-500/20 text-teal-300 text-xs font-bold transition-all flex items-center gap-2"
          >
            <span className="material-symbols-outlined text-[18px]">download</span>
            <span>Export Encrypted CSV</span>
          </button>
        </div>
      </header>

      {/* ── Search & Filter Controls ── */}
      <div className="bg-slate-900/80 rounded-2xl p-4 shadow-xl border border-slate-800/80 flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
            search
          </span>
          <input
            type="text"
            placeholder="Search audit records, actions, IPs, actors..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-slate-950 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-xs text-white placeholder:text-slate-500 focus:ring-2 focus:ring-teal-500 focus:outline-none"
          />
        </div>

        <div className="flex flex-wrap gap-2 w-full md:w-auto">
          {['ALL', 'PATTERN', 'USER', 'ADMIN', 'LOGIN', 'BROADCAST'].map((act) => (
            <button
              key={act}
              onClick={() => setFilterAction(act)}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                filterAction === act
                  ? 'bg-teal-500 text-white shadow-md shadow-teal-500/20'
                  : 'bg-slate-950 text-slate-400 hover:text-white border border-slate-800'
              }`}
            >
              {act}
            </button>
          ))}
        </div>
      </div>

      {/* ── Audit Logs Table ── */}
      <div className="bg-slate-900/80 rounded-2xl shadow-xl overflow-hidden border border-slate-800/80 backdrop-blur-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-950/60 text-slate-400 text-xs border-b border-slate-800/80 uppercase tracking-wider font-semibold">
                <th className="p-4 pl-6">Timestamp</th>
                <th className="p-4">Administrator / Actor</th>
                <th className="p-4">Action</th>
                <th className="p-4">Target Parameters & Payload</th>
                <th className="p-4 pr-6 text-right">IP Address</th>
              </tr>
            </thead>
            <tbody className="text-xs text-slate-200 divide-y divide-slate-800/60">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan="5" className="p-12 text-center text-slate-400">
                    <span className="material-symbols-outlined text-4xl text-slate-600 mb-2">history</span>
                    <p className="text-sm font-semibold text-slate-300">No audit logs matching query</p>
                  </td>
                </tr>
              ) : (
                filtered.map((row) => {
                  const dateStr = new Date(row.created_at || row.timestamp || Date.now()).toLocaleString()
                  const isCritical =
                    row.action.toLowerCase().includes('delete') ||
                    row.action.toLowerCase().includes('suspend')

                  return (
                    <tr key={row.id} className="hover:bg-slate-800/40 transition-colors">
                      <td className="p-4 pl-6 font-mono text-[11px] text-slate-400 whitespace-nowrap">
                        {dateStr}
                      </td>

                      <td className="p-4">
                        <div className="font-bold text-white text-xs">
                          {row.admin_name || row.actor || 'SecOps Lead'}
                        </div>
                        {row.admin_email && (
                          <div className="text-[10px] text-slate-500 font-mono">{row.admin_email}</div>
                        )}
                      </td>

                      <td className="p-4">
                        <span
                          className={`px-2.5 py-1 rounded-md text-[10px] font-bold uppercase tracking-wider border ${
                            isCritical
                              ? 'bg-red-500/20 text-red-300 border-red-500/30'
                              : 'bg-teal-500/20 text-teal-300 border-teal-500/30'
                          }`}
                        >
                          {row.action}
                        </span>
                      </td>

                      <td className="p-4 font-mono text-[11px] text-slate-300 max-w-md">
                        {row.target_type && (
                          <span className="text-teal-400 font-semibold mr-1.5">
                            [{row.target_type} #{row.target_id || ''}]
                          </span>
                        )}
                        <span className="text-slate-400">
                          {row.metadata ? JSON.stringify(row.metadata) : row.target || row.details || 'System operation'}
                        </span>
                      </td>

                      <td className="p-4 pr-6 text-right font-mono text-slate-500 text-[11px]">
                        {row.ip_address || row.ip || '127.0.0.1'}
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
