import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

export default function UsersPage() {
  const navigate = useNavigate()
  const { users, loading, suspendUser, deleteUser, refreshData } = useAdminData()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [actionInProgress, setActionInProgress] = useState(null)

  const filteredUsers = users.filter((u) => {
    const term = searchTerm.toLowerCase()
    const matchSearch =
      (u.name || '').toLowerCase().includes(term) ||
      (u.phone_number || '').toLowerCase().includes(term) ||
      (u.email || '').toLowerCase().includes(term)

    const matchStatus =
      statusFilter === 'all' ||
      (statusFilter === 'active' && !u.is_suspended) ||
      (statusFilter === 'suspended' && u.is_suspended)

    return matchSearch && matchStatus
  })

  const handleExportCSV = () => {
    const header = 'User ID,Full Name,Phone Number,Email,Status,Registration Date\n'
    const rows = filteredUsers
      .map(
        (u) =>
          `"${u.id}","${(u.name || '').replace(/"/g, '""')}","${u.phone_number || ''}","${u.email || ''}","${
            u.is_suspended ? 'Suspended' : 'Active'
          }","${new Date(u.created_at).toLocaleDateString()}"`
      )
      .join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `SafeSenior_Real_Users_${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
  }

  const handleSuspendToggle = async (user) => {
    setActionInProgress(user.id)
    await suspendUser(user.id, !user.is_suspended)
    setActionInProgress(null)
  }

  const handleDelete = async (user) => {
    if (window.confirm(`Are you sure you want to permanently delete senior account "${user.name}" (#${user.id})? This cascades all linked guardian links.`)) {
      setActionInProgress(user.id)
      await deleteUser(user.id)
      setActionInProgress(null)
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
              Live PostgreSQL Database
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">elderly</span>
            Senior Citizens Directory
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Real registered senior citizens protected by SafeSenior. Manage accounts, inspect linked guardians, and quarantine compromised devices.
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

      {/* ── Search & Filter Controls ── */}
      <div className="bg-slate-900/80 rounded-2xl p-4 shadow-xl border border-slate-800/80 flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
            search
          </span>
          <input
            type="text"
            placeholder="Search by senior name, phone number, email..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-slate-950 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-xs text-white placeholder:text-slate-500 focus:ring-2 focus:ring-teal-500 focus:outline-none"
          />
        </div>

        <div className="flex gap-2 w-full md:w-auto">
          {[
            { id: 'all', label: `All (${users.length})` },
            { id: 'active', label: `Active (${users.filter((u) => !u.is_suspended).length})` },
            { id: 'suspended', label: `Suspended (${users.filter((u) => u.is_suspended).length})` }
          ].map((st) => (
            <button
              key={st.id}
              onClick={() => setStatusFilter(st.id)}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all ${
                statusFilter === st.id
                  ? 'bg-teal-500 text-white shadow-md shadow-teal-500/20'
                  : 'bg-slate-950 text-slate-400 hover:text-white border border-slate-800'
              }`}
            >
              {st.label}
            </button>
          ))}
        </div>
      </div>

      {/* ── Live Users Table ── */}
      <div className="bg-slate-900/80 rounded-2xl shadow-xl overflow-hidden border border-slate-800/80 backdrop-blur-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-950/60 text-slate-400 text-xs border-b border-slate-800/80 uppercase tracking-wider font-semibold">
                <th className="p-4 pl-6">Senior Citizen</th>
                <th className="p-4">Contact Phone</th>
                <th className="p-4">Email Address</th>
                <th className="p-4">Linked Guardians</th>
                <th className="p-4">Protection Status</th>
                <th className="p-4 pr-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="text-xs text-slate-200 divide-y divide-slate-800/60">
              {loading ? (
                <tr>
                  <td colSpan="6" className="p-12 text-center text-slate-400">
                    <div className="flex flex-col items-center justify-center gap-2">
                      <span className="material-symbols-outlined text-4xl text-teal-400 animate-spin">progress_activity</span>
                      <p className="text-sm font-semibold text-slate-200">Loading senior records from database...</p>
                      <p className="text-xs text-slate-500">Connecting to live PostgreSQL cluster...</p>
                    </div>
                  </td>
                </tr>
              ) : filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan="6" className="p-12 text-center text-slate-400">
                    <span className="material-symbols-outlined text-4xl text-slate-600 mb-2">person_off</span>
                    <p className="text-sm font-semibold text-slate-300">No senior citizen records found</p>
                    <p className="text-xs text-slate-500 mt-1">Try adjusting your search criteria.</p>
                  </td>
                </tr>
              ) : (
                filteredUsers.map((u) => {
                  const initials = (u.name || 'S')
                    .split(' ')
                    .map((n) => n[0])
                    .join('')
                    .substring(0, 2)
                    .toUpperCase()

                  return (
                    <tr key={u.id} className="hover:bg-slate-800/40 transition-colors">
                      <td className="p-4 pl-6">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-xl bg-teal-500/15 text-teal-300 border border-teal-500/20 flex items-center justify-center font-bold text-sm shadow-inner shrink-0">
                            {initials}
                          </div>
                          <div>
                            <div className="font-bold text-white text-sm flex items-center gap-2">
                              {u.name || 'Unnamed Senior'}
                              <span className="text-[10px] text-slate-500 font-mono">#{u.id}</span>
                            </div>
                            <div className="text-[11px] text-slate-400 font-mono mt-0.5">
                              Enrolled: {new Date(u.created_at).toLocaleDateString()}
                            </div>
                          </div>
                        </div>
                      </td>

                      <td className="p-4">
                        <span className="font-mono text-teal-300 font-semibold bg-teal-950/40 px-2 py-1 rounded-md border border-teal-500/20">
                          {u.phone_number || 'N/A'}
                        </span>
                      </td>

                      <td className="p-4 font-mono text-slate-300">
                        {u.email || 'N/A'}
                      </td>

                      <td className="p-4">
                        {u.guardians && u.guardians.length > 0 ? (
                          <div className="space-y-1">
                            {u.guardians.map((g, idx) => (
                              <div key={idx} className="flex items-center gap-1.5 text-xs text-slate-300 font-semibold">
                                <span className="w-1.5 h-1.5 rounded-full bg-teal-400"></span>
                                <span>{g.name}</span>
                                <span className="text-slate-500 text-[10px]">({g.relationship || 'Guardian'})</span>
                              </div>
                            ))}
                          </div>
                        ) : (
                          <span className="text-slate-500 italic text-[11px]">No guardian linked</span>
                        )}
                      </td>

                      <td className="p-4">
                        <span
                          className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold border ${
                            u.is_suspended
                              ? 'bg-red-500/20 text-red-300 border-red-500/30'
                              : 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30'
                          }`}
                        >
                          <span
                            className={`w-1.5 h-1.5 rounded-full ${
                              u.is_suspended ? 'bg-red-400 animate-ping' : 'bg-emerald-400'
                            }`}
                          ></span>
                          {u.is_suspended ? 'Suspended / Quarantine' : 'Active Protected'}
                        </span>
                      </td>

                      <td className="p-4 pr-6 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => navigate(`/protection-details?id=${u.id}`)}
                            className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-teal-300 rounded-xl text-xs font-bold transition-all border border-slate-700"
                            title="View senior safety profile"
                          >
                            Profile
                          </button>
                          <button
                            disabled={actionInProgress === u.id}
                            onClick={() => handleSuspendToggle(u)}
                            className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                              u.is_suspended
                                ? 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-md shadow-emerald-950/40'
                                : 'bg-red-600/80 hover:bg-red-600 text-white shadow-md shadow-red-950/40'
                            }`}
                          >
                            {actionInProgress === u.id
                              ? 'Saving...'
                              : u.is_suspended
                              ? 'Reactivate'
                              : 'Suspend'}
                          </button>
                          <button
                            disabled={actionInProgress === u.id}
                            onClick={() => handleDelete(u)}
                            className="p-1.5 text-slate-400 hover:text-red-400 hover:bg-red-500/10 rounded-xl transition-all"
                            title="Delete account"
                          >
                            <span className="material-symbols-outlined text-[18px]">delete</span>
                          </button>
                        </div>
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
