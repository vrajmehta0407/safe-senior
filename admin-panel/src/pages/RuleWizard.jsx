import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

export default function RuleWizard() {
  const navigate = useNavigate()
  const { addOrUpdateRule } = useAdminData()
  const [ruleName, setRuleName] = useState('')
  const [ruleDesc, setRuleDesc] = useState('')
  const [sourceType, setSourceType] = useState('SMS')
  const [keywordInput, setKeywordInput] = useState('')
  const [keywords, setKeywords] = useState(['digital arrest', 'cbi officer', 'western union'])
  const [severity, setSeverity] = useState('Critical')
  const [autoAction, setAutoAction] = useState('quarantine')
  const [broadcastToUsers, setBroadcastToUsers] = useState(true)
  const [saved, setSaved] = useState(false)

  const handleAddKeyword = (e) => {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault()
      const val = keywordInput.trim().replace(',', '')
      if (val && !keywords.includes(val)) {
        setKeywords([...keywords, val])
        setKeywordInput('')
      }
    }
  }

  const removeKeyword = (kw) => {
    setKeywords(keywords.filter(k => k !== kw))
  }

  const handleSave = () => {
    const newRule = {
      id: `PTN-0${Date.now().toString().slice(-3)}`,
      name: ruleName.trim() || 'New Threat Pattern',
      desc: ruleDesc.trim() || 'Custom neural classifier rule deployed via wizard',
      trigger: keywords.join(', ') || 'Keyword match',
      category: sourceType === 'SMS' ? 'Phishing Vectors' : sourceType === 'VoIP' ? 'Deepfake Audio' : 'Financial Coercion',
      accuracy: '98.5%',
      hitsToday: 0,
      enabled: true,
      severity,
      action: autoAction,
      broadcast: broadcastToUsers
    }
    
    if (addOrUpdateRule) {
      addOrUpdateRule(newRule)
    }
    setSaved(true)
    setTimeout(() => {
      navigate('/patterns')
    }, 1500)
  }

  return (
    <div className="space-y-8 max-w-4xl mx-auto font-body-md text-slate-100">
      {/* ── Header ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
            <span className="text-xs font-mono font-bold text-emerald-400 uppercase tracking-widest">Classifier Authoring</span>
          </div>
          <h1 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight">New Detection Rule Wizard</h1>
          <p className="text-xs sm:text-sm text-slate-400 mt-1">
            Deploy neural pattern rules across the safe browsing, telecom & carrier inspection layers.
          </p>
        </div>
      </div>

      {saved && (
        <div className="bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 p-4 rounded-2xl flex items-center gap-3 shadow-lg text-xs font-bold animate-pulse">
          <span className="material-symbols-outlined text-[24px] text-emerald-400">check_circle</span>
          <span>Rule "{ruleName || 'New Rule'}" deployed to edge classifier nodes & broadcasted to all senior endpoints. Redirecting to library...</span>
        </div>
      )}

      {/* ── Section 1: Rule Details Card ── */}
      <section className="bg-slate-900/80 backdrop-blur-xl rounded-3xl p-6 md:p-8 shadow-xl border border-slate-800/80 space-y-5">
        <h2 className="font-headline-sm text-base font-bold text-white flex items-center gap-2">
          <span className="material-symbols-outlined text-emerald-400 text-xl">description</span>
          Rule Metadata
        </h2>
        <div className="space-y-4 text-xs">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider" htmlFor="rule-name">
              Rule Name
            </label>
            <input
              id="rule-name"
              type="text"
              value={ruleName}
              onChange={(e) => setRuleName(e.target.value)}
              placeholder="e.g., Grandparent Voice Clone Protection"
              className="w-full px-4 py-3.5 rounded-xl border border-slate-800 bg-slate-950/60 font-semibold text-xs text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 transition-all"
            />
          </div>
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider" htmlFor="rule-desc">
              Internal Description
            </label>
            <textarea
              id="rule-desc"
              rows={3}
              value={ruleDesc}
              onChange={(e) => setRuleDesc(e.target.value)}
              placeholder="Explain the purpose and intended behavior of this rule for other SecOps admins..."
              className="w-full p-4 rounded-xl border border-slate-800 bg-slate-950/60 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 transition-all resize-none leading-relaxed"
            />
          </div>
        </div>
      </section>

      {/* ── Section 2: Triggers Card ── */}
      <section className="bg-slate-900/80 backdrop-blur-xl rounded-3xl p-6 md:p-8 shadow-xl border border-slate-800/80 space-y-6">
        <h2 className="font-headline-sm text-base font-bold text-white flex items-center gap-2">
          <span className="material-symbols-outlined text-emerald-400 text-xl">radar</span>
          Detection Triggers & Channel
        </h2>

        <div className="space-y-5 text-xs">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider">
              Source Channel
            </label>
            <div className="flex flex-wrap gap-3">
              {['SMS', 'VoIP', 'WhatsApp', 'UPI QR'].map((st) => (
                <button
                  key={st}
                  type="button"
                  onClick={() => setSourceType(st)}
                  className={`px-4 py-2.5 rounded-xl font-bold transition-all ${
                    sourceType === st
                      ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-950/40 border border-emerald-400/40'
                      : 'bg-slate-950/60 text-slate-400 border border-slate-800 hover:text-slate-200'
                  }`}
                >
                  {st}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider">
              Trigger Keywords (Press Enter or Comma to add)
            </label>
            <input
              type="text"
              value={keywordInput}
              onChange={(e) => setKeywordInput(e.target.value)}
              onKeyDown={handleAddKeyword}
              placeholder="Type keyword and press Enter..."
              className="w-full px-4 py-3 rounded-xl border border-slate-800 bg-slate-950/60 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 transition-all mb-3"
            />
            <div className="flex flex-wrap gap-2">
              {keywords.map((kw) => (
                <span key={kw} className="px-3 py-1 bg-slate-800 text-emerald-300 rounded-lg text-xs font-semibold flex items-center gap-1.5 border border-slate-700">
                  <span>{kw}</span>
                  <button type="button" onClick={() => removeKeyword(kw)} className="text-slate-400 hover:text-rose-400">
                    <span className="material-symbols-outlined text-[14px]">close</span>
                  </button>
                </span>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── Section 3: Severity & Actions Card ── */}
      <section className="bg-slate-900/80 backdrop-blur-xl rounded-3xl p-6 md:p-8 shadow-xl border border-slate-800/80 space-y-6">
        <h2 className="font-headline-sm text-base font-bold text-white flex items-center gap-2">
          <span className="material-symbols-outlined text-emerald-400 text-xl">gavel</span>
          Severity Level & Automated Response
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-xs">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider">
              Threat Severity
            </label>
            <div className="space-y-2">
              {['Critical', 'High', 'Medium'].map((sev) => (
                <button
                  key={sev}
                  type="button"
                  onClick={() => setSeverity(sev)}
                  className={`w-full p-3 rounded-xl text-left font-bold transition-all border ${
                    severity === sev
                      ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30'
                      : 'bg-slate-950/60 text-slate-400 border-slate-800 hover:bg-slate-800'
                  }`}
                >
                  {sev} Severity
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-2 uppercase tracking-wider">
              Automated Response Action
            </label>
            <div className="space-y-2">
              {[
                { key: 'quarantine', label: 'Quarantine Call & Alert Guardian' },
                { key: 'block', label: 'Block SMS & Redact URL' },
                { key: 'notify', label: 'Notify Operator Only' }
              ].map((act) => (
                <button
                  key={act.key}
                  type="button"
                  onClick={() => setAutoAction(act.key)}
                  className={`w-full p-3 rounded-xl text-left font-semibold transition-all border ${
                    autoAction === act.key
                      ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30 font-bold'
                      : 'bg-slate-950/60 text-slate-400 border-slate-800 hover:bg-slate-800'
                  }`}
                >
                  {act.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Real-time broadcast notification toggle */}
        <div className="pt-4 border-t border-slate-800/80">
          <label className="flex items-center gap-3 cursor-pointer select-none">
            <input
              type="checkbox"
              checked={broadcastToUsers}
              onChange={(e) => setBroadcastToUsers(e.target.checked)}
              className="w-4 h-4 rounded text-emerald-500 focus:ring-emerald-500 border-slate-750 bg-slate-950 accent-emerald-500 cursor-pointer"
            />
            <div>
              <span className="font-bold text-xs text-white flex items-center gap-1.5">
                <span className="material-symbols-outlined text-emerald-400 text-[16px]">notifications_active</span>
                Immediately Broadcast Dynamic Scam Alert to All Protected Users
              </span>
              <p className="text-[11px] text-slate-400">
                Automatically dispatches real-time push and in-app alerts to every senior endpoint via FCM topic 'all-users'.
              </p>
            </div>
          </label>
        </div>
      </section>

      {/* ── Submit Actions ── */}
      <div className="flex items-center justify-end gap-3 pt-4">
        <button
          type="button"
          onClick={() => navigate('/patterns')}
          className="px-5 py-3 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-bold transition-colors"
        >
          Cancel
        </button>
        <button
          type="button"
          onClick={handleSave}
          className="px-6 py-3 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white rounded-xl text-xs font-bold shadow-lg shadow-emerald-950/40 transition-all flex items-center gap-2 active:scale-[0.99]"
        >
          <span className="material-symbols-outlined text-[18px]">publish</span>
          Deploy & Broadcast Rule
        </button>
      </div>
    </div>
  )
}
