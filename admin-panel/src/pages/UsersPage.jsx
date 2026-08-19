import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

export default function UsersPage() {
  const navigate = useNavigate()
  const { users, suspendUser, deleteUser } = useAdminData()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  const filteredUsers = users.filter(u => {
    const matchSearch = u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                        u.location.toLowerCase().includes(searchTerm.toLowerCase()) ||
                        u.phone.includes(searchTerm)
    const matchStatus = statusFilter === 'all' ||
                        (statusFilter === 'active' && !u.isSuspended) ||
                        (statusFilter === 'suspended' && u.isSuspended)
    return matchSearch && matchStatus
  })

  const handleExportCSV = () => {
    const header = 'ID,Name,Age,Location,Phone,RiskScore,GeofenceStatus,IsSuspended\n'
    const rows = users.map(u => `"${u.id}","${u.name}",${u.age},"${u.location}","${u.phone}",${u.riskScore},"${u.geofenceStatus}",${u.isSuspended || false}`).join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `SafeSenior_Users_${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
  }

  return (
    <div className="space-y-6">
      {/* ── Page Header (Stitch Screen 87) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">User & Guardian Directory</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Manage protected senior endpoints, security posture, and assigned emergency guardians.
          </p>
        </div>
        <div className="flex flex-wrap gap-2.5">
          <button
            onClick={handleExportCSV}
            className="h-[44px] px-4 rounded-xl border border-outline text-on-surface font-label-md text-xs font-bold hover:bg-surface-container-high transition-colors flex items-center gap-1.5"
          >
            <span className="material-symbols-outlined text-[18px]">download</span> Export CSV
          </button>
          <button
            onClick={() => navigate('/batch-import')}
            className="h-[44px] px-4 rounded-xl bg-surface-container-high text-on-surface font-label-md text-xs font-bold hover:bg-surface-container-highest transition-colors flex items-center gap-1.5"
          >
            <span className="material-symbols-outlined text-[18px]">upload_file</span> Batch Import
          </button>
        </div>
      </div>

      {/* ── Search & Filter Bar ── */}
      <div className="bg-surface rounded-2xl p-4 shadow-sm border border-surface-container-high flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-[18px]">
            search
          </span>
          <input
            type="text"
            placeholder="Search by name, location, phone..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-surface-container-low border-none rounded-xl pl-10 pr-4 py-2 text-xs font-body-md text-on-surface placeholder:text-outline focus:ring-2 focus:ring-primary focus:outline-none h-[40px]"
          />
        </div>

        <div className="flex gap-2 w-full md:w-auto">
          {['all', 'active', 'suspended'].map((st) => (
            <button
              key={st}
              onClick={() => setStatusFilter(st)}
              className={`px-4 py-2 rounded-xl text-xs font-label-md font-bold capitalize transition-colors ${
                statusFilter === st
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
              }`}
            >
              {st}
            </button>
          ))}
        </div>
      </div>

      {/* ── Users Table ── */}
      <div className="bg-surface rounded-3xl shadow-sm border border-surface-container-high overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-surface-container-low border-b border-surface-container-high text-xs text-on-surface-variant font-bold">
                <th className="p-4 pl-6">Senior & Device</th>
                <th className="p-4">Location</th>
                <th className="p-4">Guardians</th>
                <th className="p-4">Geofence Status</th>
                <th className="p-4">Risk Meter</th>
                <th className="p-4 pr-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-surface-container-low text-xs font-body-md text-on-surface">
              {filteredUsers.map((u) => (
                <tr key={u.id} className="hover:bg-surface-container-low transition-colors">
                  <td className="p-4 pl-6">
                    <div className="flex items-center gap-3">
                      <img
                        src={u.avatar}
                        alt={u.name}
                        className="w-10 h-10 rounded-full object-cover border border-primary/20"
                      />
                      <div>
                        <div className="font-bold text-sm text-on-surface">{u.name} ({u.age})</div>
                        <div className="text-[11px] text-on-surface-variant">{u.device}</div>
                      </div>
                    </div>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-1 font-semibold">
                      <span className="material-symbols-outlined text-primary text-[14px]">location_on</span>
                      <span>{u.location}</span>
                    </div>
                  </td>
                  <td className="p-4 font-semibold">
                    {u.guardians.map((g, idx) => (
                      <div key={idx} className="text-on-surface">
                        {g.name} <span className="text-outline">({g.relation})</span>
                      </div>
                    ))}
                  </td>
                  <td className="p-4">
                    <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold ${
                      u.isSuspended || u.geofenceStatus.includes('Outside')
                        ? 'bg-error-container text-on-error-container'
                        : 'bg-primary-container/20 text-primary'
                    }`}>
                      <span className="w-1.5 h-1.5 rounded-full bg-current"></span>
                      {u.isSuspended ? 'Suspended' : u.geofenceStatus}
                    </span>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <div className="w-20 bg-surface-container-high h-2 rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full ${
                            u.riskScore > 70 ? 'bg-error' : u.riskScore > 40 ? 'bg-tertiary' : 'bg-primary'
                          }`}
                          style={{ width: `${u.riskScore}%` }}
                        />
                      </div>
                      <span className="font-bold text-xs">{u.riskScore}/100</span>
                    </div>
                  </td>
                  <td className="p-4 pr-6 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => navigate(`/protection-details?id=${u.id}`)}
                        className="px-3 py-1.5 bg-surface-container-high hover:bg-surface-container-highest rounded-xl text-primary font-bold text-xs transition-colors"
                      >
                        Profile
                      </button>
                      <button
                        onClick={() => suspendUser(u.id, !u.isSuspended)}
                        className={`px-3 py-1.5 rounded-xl font-bold text-xs transition-colors ${
                          u.isSuspended
                            ? 'bg-primary text-on-primary hover:bg-primary-container'
                            : 'bg-error-container text-on-error-container hover:bg-error/20'
                        }`}
                      >
                        {u.isSuspended ? 'Reactivate' : 'Suspend'}
                      </button>
                    </div>
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
