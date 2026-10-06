import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function SecuritySettings() {
  const { securitySettings, updateSettings } = useAdminData()
  const [form, setForm] = useState(securitySettings || {
    twoFactorRequired: true,
    carrierLookupEnabled: true,
    spectralAudioScan: true,
    alertThreshold: 0.85,
    autoQuarantineDigitalArrest: true,
    guardianSmsAlertsEnabled: true
  })
  const [savedMessage, setSavedMessage] = useState('')

  const handleSave = (e) => {
    e.preventDefault()
    if (updateSettings) updateSettings(form)
    setSavedMessage('Global security policies, 2FA enforcement, and carrier screening thresholds updated.')
    setTimeout(() => setSavedMessage(''), 4000)
  }

  return (
    <div className="space-y-6 max-w-4xl mx-auto animate-fadeIn">
      {/* ── Page Header ── */}
      <header className="bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div className="flex items-center gap-2 mb-1">
          <span className="w-2.5 h-2.5 rounded-full bg-teal-400 animate-pulse"></span>
          <span className="text-xs font-mono font-bold text-teal-400 uppercase tracking-widest">
            Enterprise SecOps Governance
          </span>
        </div>
        <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
          <span className="material-symbols-outlined text-teal-400 text-3xl">settings_suggest</span>
          Global Security & Screening Policies
        </h2>
        <p className="text-sm text-slate-400 mt-1">
          Configure multi-factor authentication requirements, Indian telecom carrier screening thresholds, and automated threat quarantine behavior.
        </p>
      </header>

      {savedMessage && (
        <div className="bg-teal-500/10 border border-teal-500/30 text-teal-300 p-4 rounded-2xl flex items-center gap-3 shadow-lg text-xs font-bold animate-fadeIn">
          <span className="material-symbols-outlined text-[20px] text-teal-400">check_circle</span>
          <span>{savedMessage}</span>
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-6">
        {/* Policy Controls */}
        <div className="bg-slate-900/80 rounded-3xl p-6 md:p-8 shadow-xl border border-slate-800/80 backdrop-blur-xl space-y-5">
          <h3 className="text-sm font-bold text-white flex items-center gap-2 border-b border-slate-800 pb-3">
            <span className="material-symbols-outlined text-teal-400 text-[20px]">verified_user</span>
            Authentication & Access Policies
          </h3>

          <div className="space-y-4 text-xs">
            {/* 2FA Toggle */}
            <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80 flex items-center justify-between">
              <div>
                <h4 className="font-bold text-sm text-white">Enforce Mandatory 2FA for All Admins</h4>
                <p className="text-slate-400 mt-0.5">Requires hardware TOTP / Authenticator app before unlocking console.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, twoFactorRequired: !form.twoFactorRequired })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.twoFactorRequired ? 'bg-teal-500' : 'bg-slate-800'
                }`}
              >
                <div
                  className={`bg-white w-4 h-4 rounded-full shadow transform transition-transform ${
                    form.twoFactorRequired ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>

            {/* Carrier Screening */}
            <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80 flex items-center justify-between">
              <div>
                <h4 className="font-bold text-sm text-white">Carrier-Level Spoofing & VoIP Screening</h4>
                <p className="text-slate-400 mt-0.5">Real-time STIR/SHAKEN reputation lookup on all incoming calls.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, carrierLookupEnabled: !form.carrierLookupEnabled })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.carrierLookupEnabled ? 'bg-teal-500' : 'bg-slate-800'
                }`}
              >
                <div
                  className={`bg-white w-4 h-4 rounded-full shadow transform transition-transform ${
                    form.carrierLookupEnabled ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>

            {/* Spectral Audio Scan */}
            <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80 flex items-center justify-between">
              <div>
                <h4 className="font-bold text-sm text-white">Spectral Deepfake Voice Frequency Analysis</h4>
                <p className="text-slate-400 mt-0.5">Detects synthetic vocal synthesis artifacts on live call screening.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, spectralAudioScan: !form.spectralAudioScan })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.spectralAudioScan ? 'bg-teal-500' : 'bg-slate-800'
                }`}
              >
                <div
                  className={`bg-white w-4 h-4 rounded-full shadow transform transition-transform ${
                    form.spectralAudioScan ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>

            {/* Auto-Quarantine Digital Arrest */}
            <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80 flex items-center justify-between">
              <div>
                <h4 className="font-bold text-sm text-white">Auto-Quarantine Digital Arrest & Police Coercion</h4>
                <p className="text-slate-400 mt-0.5">Immediately cuts suspect video calls and drafts a 1930 Cybercrime dossier.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, autoQuarantineDigitalArrest: !form.autoQuarantineDigitalArrest })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.autoQuarantineDigitalArrest ? 'bg-teal-500' : 'bg-slate-800'
                }`}
              >
                <div
                  className={`bg-white w-4 h-4 rounded-full shadow transform transition-transform ${
                    form.autoQuarantineDigitalArrest ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>

            {/* Guardian SMS Alerts */}
            <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80 flex items-center justify-between">
              <div>
                <h4 className="font-bold text-sm text-white">Automatic Guardian Emergency SMS Dispatch</h4>
                <p className="text-slate-400 mt-0.5">Sends automated SMS to verified family circle whenever high-risk threats trigger.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, guardianSmsAlertsEnabled: !form.guardianSmsAlertsEnabled })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.guardianSmsAlertsEnabled ? 'bg-teal-500' : 'bg-slate-800'
                }`}
              >
                <div
                  className={`bg-white w-4 h-4 rounded-full shadow transform transition-transform ${
                    form.guardianSmsAlertsEnabled ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>
          </div>

          <div className="pt-4 border-t border-slate-800 flex justify-end">
            <button
              type="submit"
              className="px-6 py-3 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-600 hover:from-teal-400 hover:to-emerald-500 text-white font-bold text-xs shadow-lg shadow-teal-950/40 transition-all flex items-center gap-2"
            >
              <span className="material-symbols-outlined text-[18px]">save</span>
              <span>Save & Propagate Security Policies</span>
            </button>
          </div>
        </div>
      </form>
    </div>
  )
}
