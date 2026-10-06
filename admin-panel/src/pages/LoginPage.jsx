import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ShieldCheck, UserCheck, Key, Lock, Shield } from 'lucide-react'
import api from '../api'

export default function LoginPage({ onLogin }) {
  const navigate = useNavigate()
  const [email, setEmail] = useState('admin@safesenior.org')
  const [password, setPassword] = useState('Admin@SafeSenior2026!')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  // 2FA state
  const [requires2FA, setRequires2FA] = useState(false)
  const [preAuthToken, setPreAuthToken] = useState('')
  const [totpCode, setTotpCode] = useState('')

  async function handleSubmit(e) {
    if (e) e.preventDefault()
    setError('')
    setLoading(true)
    try {
      if (requires2FA) {
        const data = await api.post('/auth/login/2fa', { preAuthToken, totpCode })
        if (data.success) {
          onLogin(data.token, data.admin)
          navigate('/dashboard')
          return
        } else {
          setError(data.message || 'Invalid 2FA code.')
        }
      } else {
        const data = await api.post('/auth/login', { email, password })
        if (data.success) {
          if (data.requires2FA) {
            setRequires2FA(true)
            setPreAuthToken(data.preAuthToken)
            return
          } else {
            onLogin(data.token, data.admin)
            navigate('/dashboard')
            return
          }
        } else {
          setError(data.message || 'Authentication failed.')
        }
      }
    } catch (err) {
      setError(err?.message || err?.response?.data?.message || 'Invalid administrator email or password.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen w-screen bg-[#0f172a] text-slate-100 flex items-center justify-center p-6 relative overflow-hidden font-body-md">
      {/* Ambient background glow elements */}
      <div className="absolute top-1/4 left-1/3 w-96 h-96 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none animate-pulse"></div>
      <div className="absolute bottom-1/4 right-1/3 w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>

      <div className="w-full max-w-md bg-slate-900/80 backdrop-blur-2xl rounded-3xl p-8 sm:p-10 border border-slate-800/80 shadow-2xl shadow-emerald-950/30 text-center relative z-10">
        {/* Top Logo Mark */}
        <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-emerald-600 to-teal-400 mx-auto mb-6 flex items-center justify-center shadow-lg shadow-emerald-500/20 text-white border border-emerald-400/30">
          <Shield size={32} />
        </div>

        <h1 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white mb-2 tracking-tight">
          SafeSenior Ops
        </h1>
        <p className="text-sm text-slate-400 mb-8 font-medium">
          Senior Safety Intelligence & Crisis Control Center
        </p>

        {error && (
          <div className="bg-rose-500/10 text-rose-400 p-3.5 rounded-xl text-xs font-bold mb-6 border border-rose-500/20 text-left flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-rose-500 animate-ping"></span>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="text-left space-y-5">
          {!requires2FA ? (
            <>
              <div>
                <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider">
                  Security ID / Email
                </label>
                <div className="relative">
                  <UserCheck size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    placeholder="admin@safesenior.org"
                    className="w-full bg-slate-950/60 border border-slate-800 rounded-xl py-3 pl-11 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 transition-all"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider">
                  Access Key / Passphrase
                </label>
                <div className="relative">
                  <Key size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••••••"
                    className="w-full bg-slate-950/60 border border-slate-800 rounded-xl py-3 pl-11 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 transition-all"
                  />
                </div>
              </div>
            </>
          ) : (
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider">
                2FA Verification Code
              </label>
              <div className="relative">
                <Lock size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                <input
                  type="text"
                  required
                  maxLength={6}
                  value={totpCode}
                  onChange={e => setTotpCode(e.target.value)}
                  placeholder="000 000"
                  className="w-full bg-slate-950/60 border border-slate-800 rounded-xl py-3 pl-11 pr-4 text-center tracking-[0.3em] font-mono text-lg text-emerald-400 placeholder-slate-600 focus:outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 transition-all"
                />
              </div>
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-bold text-sm py-3.5 px-6 rounded-xl shadow-lg shadow-emerald-900/40 transition-all duration-200 active:scale-[0.99] disabled:opacity-50 flex items-center justify-center gap-2"
          >
            {loading ? 'Authenticating...' : 'Sign In to Operations Console'}
          </button>
        </form>

        <div className="mt-8 pt-6 border-t border-slate-800/80 text-[11px] font-semibold text-slate-400 uppercase tracking-widest flex items-center justify-center gap-2">
          <ShieldCheck size={14} className="text-emerald-400" />
        </div>
      </div>
    </div>
  )
}
