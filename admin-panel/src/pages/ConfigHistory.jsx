import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function ConfigHistory() {
  const { configHistory, addConfigVersion, addAuditLog } = useAdminData()
  const [newVersion, setNewVersion] = useState('')
  const [newChanges, setNewChanges] = useState('')
  const [showDeployModal, setShowDeployModal] = useState(false)
  const [feedbackMessage, setFeedbackMessage] = useState('')

  const handleDeploy = (e) => {
    e.preventDefault()
    if (!newVersion || !newChanges) return
    addConfigVersion(newVersion, newChanges)
    setFeedbackMessage(`Deployed ${newVersion} successfully to all edge relays.`)
    setShowDeployModal(false)
    setNewVersion('')
    setNewChanges('')
    setTimeout(() => setFeedbackMessage(''), 4000)
  }

  const handleRollback = (ver) => {
    addAuditLog('Configuration Rollback', `Reverted active policy parameters to ${ver}`)
    setFeedbackMessage(`Rolled back policy parameters to ${ver}.`)
    setTimeout(() => setFeedbackMessage(''), 4000)
  }

  return (
    <div className="space-y-6 max-w-5xl mx-auto">
      {/* ── Header (Stitch Screen 91) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">System Configuration History</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Immutable version control, rollback capabilities, and parameter audit trail.
          </p>
        </div>
        <button
          onClick={() => setShowDeployModal(true)}
          className="h-[44px] px-5 rounded-xl bg-primary text-on-primary font-label-md text-xs font-bold hover:bg-primary-container transition-colors shadow-sm flex items-center gap-2"
        >
          <span className="material-symbols-outlined text-[18px]">rocket_launch</span>
          Deploy New Configuration
        </button>
      </div>

      {feedbackMessage && (
        <div className="bg-primary text-on-primary p-4 rounded-2xl flex items-center gap-3 shadow-md text-xs font-bold animate-pulse">
          <span className="material-symbols-outlined text-[20px]">check_circle</span>
          {feedbackMessage}
        </div>
      )}

      {showDeployModal && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-surface rounded-3xl p-6 md:p-8 max-w-md w-full shadow-2xl border border-surface-container-high space-y-4">
            <h2 className="font-headline-sm text-base font-bold text-on-surface">Deploy Configuration Release</h2>
            <form onSubmit={handleDeploy} className="space-y-4 text-xs">
              <div>
                <label className="block font-bold text-on-surface mb-1">Version Identifier</label>
                <input
                  type="text"
                  placeholder="e.g., v2.4.2"
                  value={newVersion}
                  onChange={(e) => setNewVersion(e.target.value)}
                  required
                  className="w-full h-[44px] px-3.5 bg-surface-container-low rounded-xl border border-outline font-bold focus:border-primary focus:outline-none"
                />
              </div>
              <div>
                <label className="block font-bold text-on-surface mb-1">Release Changes & Summary</label>
                <textarea
                  rows={3}
                  placeholder="Describe adjusted neural weights or thresholds..."
                  value={newChanges}
                  onChange={(e) => setNewChanges(e.target.value)}
                  required
                  className="w-full p-3 bg-surface-container-low rounded-xl border border-outline leading-relaxed focus:border-primary focus:outline-none resize-none"
                />
              </div>
              <div className="flex gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowDeployModal(false)}
                  className="flex-1 py-2.5 rounded-xl border border-outline font-bold hover:bg-surface-container-low transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 rounded-xl bg-primary text-on-primary font-bold hover:bg-primary-container transition-colors shadow-sm"
                >
                  Deploy
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="space-y-4">
        {configHistory.map((cfg, idx) => (
          <div
            key={cfg.id}
            className={`p-6 rounded-3xl border transition-all flex flex-col md:flex-row md:items-center justify-between gap-4 ${
              idx === 0
                ? 'border-primary bg-primary-container/5 shadow-sm'
                : 'border-surface-container-high bg-surface'
            }`}
          >
            <div>
              <div className="flex items-center gap-2 mb-1.5">
                <span className={`px-2.5 py-0.5 rounded-full text-[11px] font-bold ${
                  idx === 0 ? 'bg-primary text-on-primary' : 'bg-surface-container-high text-on-surface-variant'
                }`}>
                  {idx === 0 ? 'Current Active' : 'Archived'}
                </span>
                <span className="font-bold text-base text-on-surface">{cfg.version}</span>
                <span className="text-xs text-on-surface-variant font-mono">• {cfg.timestamp}</span>
              </div>

              <div className="text-xs text-on-surface-variant mb-1 font-semibold">
                Author: <span className="text-on-surface font-bold">{cfg.author}</span>
              </div>

              <p className="text-xs text-on-surface max-w-2xl leading-relaxed">
                {cfg.changes}
              </p>
            </div>

            {idx !== 0 && (
              <button
                onClick={() => handleRollback(cfg.version)}
                className="px-4 py-2 rounded-xl border border-outline hover:bg-surface-container-high text-xs font-bold text-on-surface transition-colors shrink-0 flex items-center gap-1.5"
              >
                <span className="material-symbols-outlined text-[16px]">rotate_left</span>
                Rollback
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
