import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function SecuritySettings() {
  const { securitySettings, updateSettings } = useAdminData()
  const [form, setForm] = useState(securitySettings)
  const [savedMessage, setSavedMessage] = useState('')

  const handleSave = (e) => {
    e.preventDefault()
    updateSettings(form)
    setSavedMessage('Global security policies and 2FA authentication requirements updated.')
    setTimeout(() => setSavedMessage(''), 4000)
  }

  return (
    <div className="space-y-8 max-w-4xl mx-auto">
      {/* ── Page Header (Stitch Screen 92) ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">Global Security Settings</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-1">
            Enterprise SecOps policies, mandatory 2FA enforcement, and carrier-level screening thresholds.
          </p>
        </div>
      </div>

      {savedMessage && (
        <div className="bg-primary text-on-primary p-4 rounded-2xl flex items-center gap-3 shadow-md text-xs font-bold animate-pulse">
          <span className="material-symbols-outlined text-[20px]">check_circle</span>
          {savedMessage}
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-6">
        {/* Policy Controls */}
        <div className="bg-surface rounded-3xl p-6 md:p-8 shadow-sm border border-surface-container-high space-y-5">
          <h2 className="font-headline-sm text-sm font-bold text-on-surface flex items-center gap-2">
            <span className="material-symbols-outlined text-primary">verified_user</span>
            Authentication & Access Policies
          </h2>

          <div className="space-y-4 text-xs">
            {/* 2FA Toggle */}
            <div className="bg-surface-container-low p-4 rounded-2xl border border-surface-container-high flex items-center justify-between">
              <div>
                <h3 className="font-bold text-sm text-on-surface">Enforce Mandatory 2FA for All Admins</h3>
                <p className="text-on-surface-variant mt-0.5">Requires hardware TOTP / Authenticator app before unlocking console.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, twoFactorRequired: !form.twoFactorRequired })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.twoFactorRequired ? 'bg-primary' : 'bg-outline-variant'
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
            <div className="bg-surface-container-low p-4 rounded-2xl border border-surface-container-high flex items-center justify-between">
              <div>
                <h3 className="font-bold text-sm text-on-surface">Carrier-Level Spoofing & VoIP Screening</h3>
                <p className="text-on-surface-variant mt-0.5">Real-time STIR/SHAKEN reputation lookup on all incoming calls.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, carrierLookupEnabled: !form.carrierLookupEnabled })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.carrierLookupEnabled ? 'bg-primary' : 'bg-outline-variant'
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
            <div className="bg-surface-container-low p-4 rounded-2xl border border-surface-container-high flex items-center justify-between">
              <div>
                <h3 className="font-bold text-sm text-on-surface">Spectral Deepfake Voice Frequency Analysis</h3>
                <p className="text-on-surface-variant mt-0.5">Detects synthetic vocal synthesis artifacts on live call screening.</p>
              </div>
              <button
                type="button"
                onClick={() => setForm({ ...form, spectralAudioScan: !form.spectralAudioScan })}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                  form.spectralAudioScan ? 'bg-primary' : 'bg-outline-variant'
                }`}
              >
                <div
                  className={`bg-white w-4 h-4 rounded-full shadow transform transition-transform ${
                    form.spectralAudioScan ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>
          </div>
        </div>

        {/* Configuration Parameters */}
        <div className="bg-surface rounded-3xl p-6 md:p-8 shadow-sm border border-surface-container-high space-y-5 text-xs">
          <h2 className="font-headline-sm text-sm font-bold text-on-surface flex items-center gap-2">
            <span className="material-symbols-outlined text-primary">tune</span>
            Quarantine Thresholds & Network Security
          </h2>

          <div className="space-y-4">
            <div>
              <div className="flex justify-between items-center mb-1 font-bold">
                <label className="text-on-surface">Autonomous Quarantine Confidence Threshold</label>
                <span className="text-primary">{form.autoQuarantineThreshold}%</span>
              </div>
              <input
                type="range"
                min={50}
                max={99}
                value={form.autoQuarantineThreshold}
                onChange={(e) => setForm({ ...form, autoQuarantineThreshold: Number(e.target.value) })}
                className="w-full accent-primary"
              />
            </div>

            <div>
              <label className="block font-bold text-on-surface mb-1">Admin IP Address Allowlist (CIDR notation)</label>
              <input
                type="text"
                value={form.ipAllowlist}
                onChange={(e) => setForm({ ...form, ipAllowlist: e.target.value })}
                className="w-full h-[48px] px-3.5 bg-surface-container-low rounded-xl border border-outline text-xs text-on-surface font-mono focus:border-primary focus:outline-none"
              />
            </div>

            <div>
              <label className="block font-bold text-on-surface mb-1">Session Inactivity Timeout (Minutes)</label>
              <input
                type="number"
                value={form.sessionTimeoutMinutes}
                onChange={(e) => setForm({ ...form, sessionTimeoutMinutes: Number(e.target.value) })}
                className="w-48 h-[48px] px-3.5 bg-surface-container-low rounded-xl border border-outline text-xs text-on-surface font-bold focus:border-primary focus:outline-none"
              />
            </div>
          </div>
        </div>

        <button
          type="submit"
          className="w-full h-[48px] bg-primary text-on-primary rounded-2xl font-label-md text-xs font-bold hover:bg-primary-container transition-colors shadow-sm"
        >
          Save & Apply Security Policies
        </button>
      </form>
    </div>
  )
}
