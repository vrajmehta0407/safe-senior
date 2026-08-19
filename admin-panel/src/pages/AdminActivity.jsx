import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function AdminActivity() {
  const { auditLogs } = useAdminData()
  const [search, setSearch] = useState('')

  const filtered = auditLogs.filter(log => {
    const actor = log.actor || log.admin || 'SecOps'
    const action = log.action || ''
    const target = log.target || log.details || ''
    return (
      actor.toLowerCase().includes(search.toLowerCase()) ||
      action.toLowerCase().includes(search.toLowerCase()) ||
      target.toLowerCase().includes(search.toLowerCase())
    )
  })

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* ── Header (Stitch Screen 89) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">Admin Activity Log</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Real-time chronological feed of administrative actions, policy edits, and operator sessions.
          </p>
        </div>
      </div>

      {/* ── Search Bar & Feed ── */}
      <div className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high space-y-4">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-[18px]">
            search
          </span>
          <input
            type="text"
            placeholder="Filter by admin, action, or target..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full bg-surface-container-low border-none rounded-xl pl-10 pr-4 py-2 text-xs font-body-md text-on-surface placeholder:text-outline focus:ring-2 focus:ring-primary focus:outline-none h-[40px]"
          />
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-surface-container-high text-on-surface-variant font-bold">
                <th className="pb-3 pl-2">Timestamp</th>
                <th className="pb-3">Operator / Admin</th>
                <th className="pb-3">Action Category</th>
                <th className="pb-3">Target / Parameters</th>
                <th className="pb-3 pr-2 text-right">Origin IP</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-surface-container-low text-on-surface">
              {filtered.map((row) => (
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
                  <td className="py-3 font-mono text-[11px] text-on-surface-variant max-w-md truncate">
                    {row.target || row.details}
                  </td>
                  <td className="py-3 pr-2 text-right text-[11px] text-outline font-mono">
                    {row.ip}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
