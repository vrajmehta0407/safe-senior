import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

export default function Guardians() {
  const navigate = useNavigate()
  const { guardians, loading, refreshData } = useAdminData()
  const [searchTerm, setSearchTerm] = useState('')

  const activeGuardians = Array.isArray(guardians) ? guardians : []

  const filtered = activeGuardians.filter((g) => {
    const term = searchTerm.toLowerCase()
    return (
      (g.name || '').toLowerCase().includes(term) ||
      (g.phone_number || '').includes(term) ||
      (g.relationship || '').toLowerCase().includes(term) ||
      (g.user_name || '').toLowerCase().includes(term) ||
      (g.user_phone || '').includes(term)
    )
  })

  const handleExportCSV = () => {
    const header = 'Guardian ID,Guardian Name,Guardian Phone,Relationship,Senior Name,Senior Phone,Senior Email,Date Linked\n'
    const rows = filtered
      .map(
        (g) =>
          `"${g.id}","${(g.name || '').replace(/"/g, '""')}","${g.phone_number || ''}","${g.relationship || ''}","${(
            g.user_name || ''
          ).replace(/"/g, '""')}","${g.user_phone || ''}","${g.user_email || ''}","${new Date(
            g.created_at
          ).toLocaleDateString()}"`
      )
      .join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `SafeSenior_Real_Guardians_${new Date().toISOString().slice(0, 10)}.csv`
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
              Live PostgreSQL Database
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">family_restroom</span>
            Guardian Safety Circle Network
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Live database records joined from PostgreSQL. Verified family protectors, emergency SMS responders, and medical caregivers linked to senior citizen profiles.
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={refreshData}
            className="h-11 px-4 rounded-xl border border-slate-700 bg-slate-800/60 hover:bg-slate-700 text-slate-200 text-xs font-bold transition-all flex items-center gap-2"
            title="Refresh database records"
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
            <span>Export CSV</span>
          </button>
        </div>
      </header>

      {/* ── Search Bar & Stats ── */}
      <div className="bg-slate-900/80 rounded-2xl p-4 shadow-xl border border-slate-800/80 flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
            search
          </span>
          <input
            type="text"
            placeholder="Search by guardian name, senior name, relationship..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-slate-950 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-xs text-white placeholder:text-slate-500 focus:ring-2 focus:ring-teal-500 focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2 text-xs">
          <span className="px-3.5 py-1.5 rounded-xl bg-teal-500/15 border border-teal-500/30 text-teal-300 font-bold flex items-center gap-1.5">
            <span className="material-symbols-outlined text-sm">verified</span>
            {activeGuardians.length} Verified Family Protectors in Database
          </span>
        </div>
      </div>

      {/* ── Guardians Table ── */}
      <div className="bg-slate-900/80 rounded-2xl shadow-xl overflow-hidden border border-slate-800/80 backdrop-blur-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-950/60 text-slate-400 text-xs border-b border-slate-800/80 uppercase tracking-wider font-semibold">
                <th className="p-4 pl-6">Guardian Contact</th>
                <th className="p-4">Relationship</th>
                <th className="p-4">Protected Senior Citizen</th>
                <th className="p-4">Senior Contact Phone</th>
                <th className="p-4">Date Linked</th>
                <th className="p-4 pr-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="text-xs text-slate-200 divide-y divide-slate-800/60">
              {loading ? (
                <tr>
                  <td colSpan="6" className="p-12 text-center text-slate-400">
                    <div className="flex flex-col items-center justify-center gap-2">
                      <span className="material-symbols-outlined text-4xl text-teal-400 animate-spin">progress_activity</span>
                      <p className="text-sm font-semibold text-slate-200">Loading guardian network from database...</p>
                      <p className="text-xs text-slate-500">Connecting to live PostgreSQL cluster...</p>
                    </div>
                  </td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan="6" className="p-12 text-center text-slate-400">
                    <span className="material-symbols-outlined text-4xl text-slate-600 mb-2">group_off</span>
                    <p className="text-sm font-semibold text-slate-300">No guardian records match query</p>
                    <p className="text-xs text-slate-500 mt-1">Check search query or verify database synchronization.</p>
                  </td>
                </tr>
              ) : (
                filtered.map((g) => {
                  const initial = (g.name || 'G').charAt(0).toUpperCase()
                  return (
                    <tr key={g.id} className="hover:bg-slate-800/40 transition-colors">
                      <td className="p-4 pl-6">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-xl bg-teal-500/15 text-teal-300 border border-teal-500/20 flex items-center justify-center font-bold text-sm shadow-inner shrink-0">
                            {initial}
                          </div>
                          <div>
                            <div className="font-bold text-white text-sm">{g.name}</div>
                            <div className="font-mono text-teal-400 text-xs mt-0.5">{g.phone_number}</div>
                          </div>
                        </div>
                      </td>

                      <td className="p-4">
                        <span className="px-3 py-1 rounded-full text-[11px] font-bold bg-slate-800 text-teal-300 border border-slate-700">
                          {g.relationship || 'Guardian'}
                        </span>
                      </td>

                      <td className="p-4">
                        <div className="flex items-center gap-2">
                          <span className="material-symbols-outlined text-teal-400 text-[18px]">elderly</span>
                          <div>
                            <div className="font-bold text-white text-xs">{g.user_name || `Senior #${g.user_id}`}</div>
                            <div className="text-[10px] text-slate-400 font-mono">{g.user_email || 'No email registered'}</div>
                          </div>
                        </div>
                      </td>

                      <td className="p-4 font-mono text-slate-300">
                        {g.user_phone || 'N/A'}
                      </td>

                      <td className="p-4 font-mono text-slate-400 text-[11px]">
                        {new Date(g.created_at).toLocaleDateString()}
                      </td>

                      <td className="p-4 pr-6 text-right">
                        <button
                          onClick={() => navigate(`/protection-details?id=${g.user_id}`)}
                          className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-teal-300 rounded-xl text-xs font-bold transition-all border border-slate-700 inline-flex items-center gap-1.5"
                        >
                          <span className="material-symbols-outlined text-[14px]">visibility</span>
                          <span>View Senior</span>
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
    </div>
  )
}
