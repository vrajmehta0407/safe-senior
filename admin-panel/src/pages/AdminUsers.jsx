import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function AdminUsers() {
  const { admins, addAdmin, refreshData, loading } = useAdminData()

  const [newModal, setNewModal] = useState(false)
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [role, setRole] = useState('support')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [statusMsg, setStatusMsg] = useState('')

  const activeAdmins = Array.isArray(admins) ? admins : []

  async function handleCreate(e) {
    e.preventDefault()
    if (!name || !email || !password) return
    if (password.length < 12) {
      alert('Password must be at least 12 characters.')
      return
    }

    setIsSubmitting(true)
    const res = await addAdmin({ name, email, password, role })
    setIsSubmitting(false)

    if (res.success) {
      setNewModal(false)
      setName('')
      setEmail('')
      setPassword('')
      setRole('support')
      setStatusMsg(`Successfully provisioned admin account: ${email}`)
      setTimeout(() => setStatusMsg(''), 5000)
    } else {
      alert(`Failed to create admin: ${res.error}`)
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
              Live PostgreSQL Admins
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">admin_panel_settings</span>
            SecOps Admin Governance & Access
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Real administrator accounts authorized to manage SafeSenior threat patterns, review scam reports, and quarantine accounts.
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
            onClick={() => setNewModal(true)}
            className="h-11 px-4 rounded-xl bg-teal-600 hover:bg-teal-500 text-white text-xs font-bold transition-all flex items-center gap-2 shadow-lg shadow-teal-950/40"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            <span>Provision New Admin</span>
          </button>
        </div>
      </header>

      {statusMsg && (
        <div className="bg-teal-500/15 border border-teal-500/30 text-teal-300 px-4 py-3 rounded-2xl text-xs font-semibold flex items-center gap-2 animate-fadeIn">
          <span className="material-symbols-outlined text-teal-400">check_circle</span>
          <span>{statusMsg}</span>
        </div>
      )}

      {/* ── Admins Table ── */}
      <div className="bg-slate-900/80 rounded-2xl shadow-xl overflow-hidden border border-slate-800/80 backdrop-blur-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-950/60 text-slate-400 text-xs border-b border-slate-800/80 uppercase tracking-wider font-semibold">
                <th className="p-4 pl-6">Admin Name</th>
                <th className="p-4">Email Address</th>
                <th className="p-4">Role & Privilege</th>
                <th className="p-4">Enrolled Date</th>
                <th className="p-4 pr-6 text-right">Access Status</th>
              </tr>
            </thead>
            <tbody className="text-xs text-slate-200 divide-y divide-slate-800/60">
              {activeAdmins.length === 0 ? (
                <tr>
                  <td colSpan="5" className="p-12 text-center text-slate-400">
                    <span className="material-symbols-outlined text-4xl text-slate-600 mb-2">security</span>
                    <p className="text-sm font-semibold text-slate-300">No admins retrieved from database</p>
                  </td>
                </tr>
              ) : (
                activeAdmins.map((adm) => {
                  const initial = (adm.name || 'A').charAt(0).toUpperCase()
                  const isSuper = adm.role === 'superadmin'

                  return (
                    <tr key={adm.id} className="hover:bg-slate-800/40 transition-colors">
                      <td className="p-4 pl-6">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-xl bg-teal-500/15 text-teal-300 border border-teal-500/20 flex items-center justify-center font-bold text-sm shadow-inner shrink-0">
                            {initial}
                          </div>
                          <div>
                            <div className="font-bold text-white text-sm flex items-center gap-2">
                              {adm.name}
                              <span className="text-[10px] text-slate-500 font-mono">#{adm.id}</span>
                            </div>
                            <div className="text-[11px] text-slate-400 font-mono mt-0.5">
                              ID: adm-{adm.id}
                            </div>
                          </div>
                        </div>
                      </td>

                      <td className="p-4 font-mono text-slate-300">
                        {adm.email}
                      </td>

                      <td className="p-4">
                        <span
                          className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${
                            isSuper
                              ? 'bg-purple-500/20 text-purple-300 border-purple-500/30'
                              : 'bg-teal-500/20 text-teal-300 border-teal-500/30'
                          }`}
                        >
                          {adm.role}
                        </span>
                      </td>

                      <td className="p-4 font-mono text-slate-400 text-[11px]">
                        {new Date(adm.created_at).toLocaleDateString()}
                      </td>

                      <td className="p-4 pr-6 text-right">
                        <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                          2FA Active
                        </span>
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* ── Provision Modal ── */}
      {newModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-fadeIn">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 max-w-md w-full shadow-2xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-bold text-white flex items-center gap-2">
                <span className="material-symbols-outlined text-teal-400">person_add</span>
                Provision New Admin
              </h3>
              <button onClick={() => setNewModal(false)} className="text-slate-400 hover:text-white p-1">
                <span className="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <form onSubmit={handleCreate} className="space-y-3.5">
              <div>
                <label className="text-xs font-bold text-slate-300 block mb-1">Full Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Jason Thorne"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white focus:outline-none"
                />
              </div>

              <div>
                <label className="text-xs font-bold text-slate-300 block mb-1">Email Address</label>
                <input
                  type="email"
                  required
                  placeholder="e.g. jason@safesenior.org"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white focus:outline-none"
                />
              </div>

              <div>
                <label className="text-xs font-bold text-slate-300 block mb-1">
                  Password <span className="text-slate-500 font-normal">(min 12 chars)</span>
                </label>
                <input
                  type="password"
                  required
                  placeholder="Minimum 12 characters"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white focus:outline-none"
                />
              </div>

              <div>
                <label className="text-xs font-bold text-slate-300 block mb-1">Role Privilege</label>
                <select
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white focus:outline-none"
                >
                  <option value="support">Support Specialist</option>
                  <option value="superadmin">Superadmin (Full Control)</option>
                </select>
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setNewModal(false)}
                  className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl text-xs font-bold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-4 py-2 bg-teal-600 hover:bg-teal-500 text-white rounded-xl text-xs font-bold shadow-lg"
                >
                  {isSubmitting ? 'Provisioning...' : 'Create Admin'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
