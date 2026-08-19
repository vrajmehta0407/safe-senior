import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function AuditLog() {
  const { auditLogs } = useAdminData()
  const [search, setSearch] = useState('')
  const [filterSeverity, setFilterSeverity] = useState('ALL')

  const filtered = auditLogs.filter(log => {
    const actor = log.actor || log.admin || 'SecOps'
    const action = log.action || ''
    const target = log.target || log.details || ''
    const matchSearch = actor.toLowerCase().includes(search.toLowerCase()) ||
                        action.toLowerCase().includes(search.toLowerCase()) ||
                        target.toLowerCase().includes(search.toLowerCase())
    const severity = log.severity || (log.action.includes('Delete') ? 'Critical' : 'Info')
    const matchSev = filterSeverity === 'ALL' || severity.toUpperCase() === filterSeverity.toUpperCase()
    return matchSearch && matchSev
  })

  const handleExportCSV = () => {
    const header = 'Timestamp,Actor,Action,Target,IP,Severity\n'
    const rows = filtered.map(r => `"${r.timestamp}","${r.actor || r.admin}","${r.action}","${r.target || r.details}","${r.ip}","${r.severity || 'Info'}"`).join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `SafeSenior_Audit_Logs_${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
  }

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* ── Header (Stitch Screen 90) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">System Audit Logs</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Immutable security event logs, cryptographic access verification, and administrative audit trails.
          </p>
        </div>
        <button
          onClick={handleExportCSV}
          className="h-[44px] px-5 rounded-xl border border-outline text-on-surface font-label-md text-xs font-bold hover:bg-surface-container-high transition-colors flex items-center gap-2"
        >
          <span className="material-symbols-outlined text-[18px]">download</span> Export Encrypted CSV
        </button>
      </div>

      {/* ── Search & Filter Controls ── */}
      <div className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high space-y-4">
        <div className="flex flex-col md:flex-row justify-between items-center gap-3">
          <div className="relative w-full md:w-80">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-[18px]">
              search
            </span>
            <input
              type="text"
              placeholder="Search audit records..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full bg-surface-container-low border-none rounded-xl pl-10 pr-4 py-2 text-xs font-body-md text-on-surface placeholder:text-outline focus:ring-2 focus:ring-primary focus:outline-none h-[40px]"
            />
          </div>

          <div className="flex flex-wrap gap-2 w-full md:w-auto">
            {['ALL', 'Critical', 'High', 'Warning', 'Info'].map(s => (
              <button
                key={s}
                onClick={() => setFilterSeverity(s)}
                className={`px-3.5 py-1.5 rounded-full text-xs font-label-md font-bold transition-colors ${
                  filterSeverity === s
                    ? 'bg-primary text-on-primary shadow-sm'
                    : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
                }`}
              >
                {s}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-surface-container-high text-on-surface-variant font-bold">
                <th className="pb-3 pl-2">Timestamp</th>
                <th className="pb-3">Actor / Entity</th>
                <th className="pb-3">Action</th>
                <th className="pb-3">Target Parameters</th>
                <th className="pb-3">IP / Origin</th>
                <th className="pb-3 pr-2 text-right">Severity</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-surface-container-low text-on-surface">
              {filtered.map(row => {
                const sev = row.severity || (row.action.includes('Delete') ? 'Critical' : 'Info')
                return (
                  <tr key={row.id} className="hover:bg-surface-container-low transition-colors">
                    <td className="py-3 pl-2 text-on-surface-variant font-mono text-[11px] whitespace-nowrap">
                      {row.timestamp}
                    </td>
                    <td className="py-3 font-bold">
                      {row.actor || row.admin}
                    </td>
                    <td className="py-3">
                      <span className="px-2 py-0.5 rounded-md bg-surface-container-high text-on-surface font-bold text-[11px]">
                        {row.action}
                      </span>
                    </td>
                    <td className="py-3 font-mono text-[11px] text-on-surface-variant max-w-xs truncate">
                      {row.target || row.details}
                    </td>
                    <td className="py-3 text-[11px] text-outline font-mono">
                      {row.ip}
                    </td>
                    <td className="py-3 pr-2 text-right">
                      <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                        sev === 'Critical' || sev === 'High'
                          ? 'bg-error-container text-on-error-container'
                          : sev === 'Warning'
                          ? 'bg-tertiary-container/20 text-tertiary'
                          : 'bg-primary-container/20 text-primary'
                      }`}>
                        {sev}
                      </span>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
