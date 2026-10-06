import { useState, useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import api from '../api'

export default function UserProtectionDetail() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const userId = searchParams.get('id')

  const [loading, setLoading] = useState(true)
  const [userData, setUserData] = useState(null)
  const [guardians, setGuardians] = useState([])
  const [scamReports, setScamReports] = useState([])
  const [errorMessage, setErrorMessage] = useState('')
  const [actionLoading, setActionLoading] = useState(false)

  useEffect(() => {
    async function loadUser() {
      if (!userId) {
        setErrorMessage('No user ID specified.')
        setLoading(false)
        return
      }

      setLoading(true)
      try {
        const res = await api.get(`/users/${userId}`)
        if (res && res.success) {
          setUserData(res.user)
          setGuardians(res.guardians || [])
          setScamReports(res.scamReports || [])
        } else {
          setErrorMessage(res?.message || 'User not found in database.')
        }
      } catch (err) {
        setErrorMessage(err.message || 'Failed to load user profile.')
      } finally {
        setLoading(false)
      }
    }

    loadUser()
  }, [userId])

  const handleToggleSuspend = async () => {
    if (!userData) return
    setActionLoading(true)
    try {
      const targetState = !userData.is_suspended
      await api.patch(`/users/${userData.id}`, { is_suspended: targetState })
      setUserData(prev => ({ ...prev, is_suspended: targetState }))
    } catch (e) {
      alert(`Failed to update status: ${e.message}`)
    } finally {
      setActionLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center p-24 text-slate-400 space-y-3">
        <span className="material-symbols-outlined text-4xl animate-spin text-teal-400">sync</span>
        <p className="text-sm font-semibold text-slate-300">Loading senior citizen profile from database...</p>
      </div>
    )
  }

  if (errorMessage || !userData) {
    return (
      <div className="bg-slate-900/80 p-12 rounded-3xl border border-slate-800 text-center space-y-4">
        <span className="material-symbols-outlined text-red-400 text-5xl">error</span>
        <h3 className="text-xl font-bold text-white">Profile Unavailable</h3>
        <p className="text-sm text-slate-400">{errorMessage || 'Senior record does not exist.'}</p>
        <button
          onClick={() => navigate('/users')}
          className="px-4 py-2 bg-slate-800 text-white rounded-xl text-xs font-bold hover:bg-slate-700"
        >
          Back to Users Directory
        </button>
      </div>
    )
  }

  const initials = (userData.name || 'S')
    .split(' ')
    .map(n => n[0])
    .join('')
    .substring(0, 2)
    .toUpperCase()

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* ── Back Navigation & Action Bar ── */}
      <div className="flex items-center justify-between">
        <button
          onClick={() => navigate('/users')}
          className="flex items-center gap-2 text-xs font-bold text-slate-400 hover:text-white transition-colors"
        >
          <span className="material-symbols-outlined text-base">arrow_back</span>
          <span>Back to Senior Citizens Directory</span>
        </button>

        <div className="flex items-center gap-3">
          <button
            disabled={actionLoading}
            onClick={handleToggleSuspend}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition-all shadow-md ${
              userData.is_suspended
                ? 'bg-emerald-600 hover:bg-emerald-500 text-white'
                : 'bg-red-600 hover:bg-red-500 text-white'
            }`}
          >
            {actionLoading ? 'Processing...' : userData.is_suspended ? 'Reactivate Account' : 'Quarantine / Suspend'}
          </button>
        </div>
      </div>

      {/* ── Profile Summary Card ── */}
      <div className="bg-slate-900/80 rounded-3xl p-6 border border-slate-800/80 shadow-xl backdrop-blur-xl">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-2xl bg-teal-500/15 text-teal-300 border border-teal-500/20 flex items-center justify-center font-bold text-xl shadow-inner shrink-0">
              {initials}
            </div>
            <div>
              <div className="flex items-center gap-3">
                <h1 className="text-2xl font-bold text-white">{userData.name}</h1>
                <span
                  className={`px-3 py-1 rounded-full text-[11px] font-bold border uppercase tracking-wider ${
                    userData.is_suspended
                      ? 'bg-red-500/20 text-red-300 border-red-500/30'
                      : 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30'
                  }`}
                >
                  {userData.is_suspended ? 'Suspended' : 'Active Protected'}
                </span>
              </div>
              <p className="text-xs font-mono text-slate-400 mt-1">
                Database ID: #{userData.id} • Registered:{' '}
                {new Date(userData.created_at).toLocaleDateString()}
              </p>
            </div>
          </div>

          <div className="flex flex-wrap gap-3">
            <div className="px-4 py-2.5 bg-slate-950/80 rounded-2xl border border-slate-800">
              <div className="text-[10px] text-slate-500 uppercase font-bold">Contact Phone</div>
              <div className="font-mono text-sm text-teal-300 font-bold mt-0.5">{userData.phone_number || 'N/A'}</div>
            </div>
            <div className="px-4 py-2.5 bg-slate-950/80 rounded-2xl border border-slate-800">
              <div className="text-[10px] text-slate-500 uppercase font-bold">Registered Email</div>
              <div className="font-mono text-sm text-slate-200 font-bold mt-0.5">{userData.email || 'N/A'}</div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Two Column Grid: Linked Guardians & Intercepted Threats ── */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: Linked Guardians (5 cols) */}
        <div className="lg:col-span-5 space-y-4">
          <div className="bg-slate-900/80 rounded-3xl p-6 border border-slate-800/80 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="font-bold text-white text-base flex items-center gap-2">
                <span className="material-symbols-outlined text-teal-400">family_restroom</span>
                Linked Family Guardians ({guardians.length})
              </h3>
            </div>

            {guardians.length === 0 ? (
              <div className="p-6 bg-slate-950/60 rounded-2xl border border-slate-800 text-center text-slate-500 text-xs">
                No guardians currently linked to this senior in PostgreSQL.
              </div>
            ) : (
              <div className="space-y-3">
                {guardians.map((g) => (
                  <div
                    key={g.id}
                    className="p-4 bg-slate-950/70 rounded-2xl border border-slate-800/80 flex items-center justify-between"
                  >
                    <div>
                      <div className="font-bold text-white text-sm">{g.name}</div>
                      <div className="text-xs text-teal-400 font-mono mt-0.5">{g.phone_number}</div>
                    </div>
                    <span className="px-2.5 py-1 rounded-full text-[10px] font-bold bg-slate-800 text-teal-300 border border-slate-700">
                      {g.relationship || 'Guardian'}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Intercepted Threats History (7 cols) */}
        <div className="lg:col-span-7 space-y-4">
          <div className="bg-slate-900/80 rounded-3xl p-6 border border-slate-800/80 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="font-bold text-white text-base flex items-center gap-2">
                <span className="material-symbols-outlined text-red-400">emergency</span>
                Intercepted Threat History ({scamReports.length})
              </h3>
            </div>

            {scamReports.length === 0 ? (
              <div className="p-8 bg-slate-950/60 rounded-2xl border border-slate-800 text-center text-slate-400 text-xs">
                <span className="material-symbols-outlined text-3xl text-emerald-400 mb-1">verified_user</span>
                <p className="font-semibold text-slate-300">Clean Defense Record</p>
                <p className="text-[11px] text-slate-500 mt-0.5">No scam calls or phishing messages recorded for this user.</p>
              </div>
            ) : (
              <div className="space-y-3">
                {scamReports.map((report) => (
                  <div
                    key={report.id}
                    className="p-4 bg-slate-950/70 rounded-2xl border border-slate-800/80 space-y-2"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-mono font-bold text-white text-xs">{report.sender}</span>
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold uppercase bg-red-500/20 text-red-300 border border-red-500/30">
                          {report.classification}
                        </span>
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold uppercase bg-slate-800 text-slate-300">
                          {report.type}
                        </span>
                      </div>
                      <span className="text-[11px] font-mono text-slate-500">
                        {new Date(report.timestamp).toLocaleDateString()}
                      </span>
                    </div>

                    <p className="text-xs text-slate-300 font-mono bg-slate-900/80 p-2.5 rounded-xl border border-slate-800 leading-relaxed">
                      {report.body_preview}
                    </p>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
