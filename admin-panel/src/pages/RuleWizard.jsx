import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function RuleWizard() {
  const navigate = useNavigate()
  const [ruleName, setRuleName] = useState('')
  const [ruleDesc, setRuleDesc] = useState('')
  const [sourceType, setSourceType] = useState('SMS')
  const [keywordInput, setKeywordInput] = useState('')
  const [keywords, setKeywords] = useState(['western union', 'gift card'])
  const [severity, setSeverity] = useState('Medium')
  const [autoAction, setAutoAction] = useState('notify')
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
    setSaved(true)
    setTimeout(() => {
      navigate('/patterns')
    }, 1500)
  }

  return (
    <div className="space-y-8 max-w-4xl mx-auto">
      {/* ── Header (Stitch Screen 78) ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">New Detection Rule Wizard</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-1">
            Author and deploy neural classifier pattern rules across the safe browsing & carrier inspection layers.
          </p>
        </div>
      </div>

      {saved && (
        <div className="bg-primary text-on-primary p-4 rounded-2xl flex items-center gap-3 shadow-md text-sm font-bold animate-pulse">
          <span className="material-symbols-outlined text-[24px]">check_circle</span>
          Rule "{ruleName || 'New Rule'}" deployed to edge classifier nodes.
        </div>
      )}

      {/* ── Section 1: Rule Details Card ── */}
      <section className="bg-surface rounded-2xl p-6 md:p-8 shadow-sm border border-surface-container-high space-y-5">
        <h2 className="font-headline-sm text-headline-sm text-on-surface font-bold flex items-center gap-2 text-base">
          <span className="material-symbols-outlined text-primary">description</span>
          Rule Metadata
        </h2>
        <div className="space-y-4 text-xs">
          <div>
            <label className="block font-label-lg font-bold text-on-surface mb-1.5" htmlFor="rule-name">
              Rule Name
            </label>
            <input
              id="rule-name"
              type="text"
              value={ruleName}
              onChange={(e) => setRuleName(e.target.value)}
              placeholder="e.g., Grandparent Scam Keywords"
              className="h-[52px] w-full px-4 rounded-xl border border-outline-variant bg-surface-bright font-body-lg text-xs text-on-surface focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary placeholder:text-outline transition-all font-semibold"
            />
          </div>
          <div>
            <label className="block font-label-lg font-bold text-on-surface mb-1.5" htmlFor="rule-desc">
              Internal Description
            </label>
            <textarea
              id="rule-desc"
              rows={3}
              value={ruleDesc}
              onChange={(e) => setRuleDesc(e.target.value)}
              placeholder="Explain the purpose and intended behavior of this rule for other SecOps admins..."
              className="w-full p-4 rounded-xl border border-outline-variant bg-surface-bright font-body-lg text-xs text-on-surface focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary placeholder:text-outline transition-all resize-none leading-relaxed"
            />
          </div>
        </div>
      </section>

      {/* ── Section 2: Triggers Card ── */}
      <section className="bg-surface rounded-2xl p-6 md:p-8 shadow-sm border border-surface-container-high space-y-6">
        <h2 className="font-headline-sm text-headline-sm text-on-surface font-bold flex items-center gap-2 text-base">
          <span className="material-symbols-outlined text-primary">radar</span>
          Detection Triggers
        </h2>

        <div className="space-y-5 text-xs">
          <div>
            <span className="block font-label-lg font-bold text-on-surface mb-2">Inspection Source</span>
            <div className="flex flex-wrap gap-3">
              {[
                { id: 'SMS', label: 'SMS/Text Messages', icon: 'sms' },
                { id: 'URL', label: 'Suspicious URLs', icon: 'link' },
                { id: 'CALL', label: 'Call Patterns & VoIP', icon: 'call' }
              ].map((s) => (
                <button
                  key={s.id}
                  onClick={() => setSourceType(s.id)}
                  className={`h-[44px] px-5 rounded-full font-label-lg text-xs font-bold flex items-center gap-2 transition-all ${
                    sourceType === s.id
                      ? 'bg-primary text-on-primary shadow-sm border border-transparent'
                      : 'bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest border border-transparent'
                  }`}
                >
                  <span className="material-symbols-outlined text-[18px]">{s.icon}</span>
                  {s.label}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block font-label-lg font-bold text-on-surface mb-1.5" htmlFor="rule-pattern">
              Match Keywords (Press Enter or comma to add)
            </label>
            <div className="relative">
              <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-outline text-[18px]">
                search
              </span>
              <input
                id="rule-pattern"
                type="text"
                value={keywordInput}
                onChange={(e) => setKeywordInput(e.target.value)}
                onKeyDown={handleAddKeyword}
                placeholder="e.g., western union, wire transfer, gift card, jail"
                className="h-[52px] w-full pl-10 pr-4 rounded-xl border border-outline-variant bg-surface-bright font-body-lg text-xs text-on-surface focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary placeholder:text-outline transition-all"
              />
            </div>
            <div className="flex flex-wrap gap-2 mt-2.5">
              {keywords.map((kw, idx) => (
                <span
                  key={idx}
                  className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-surface-container-high text-on-surface font-label-md text-xs font-bold border border-surface-container-highest"
                >
                  {kw}
                  <button
                    onClick={() => removeKeyword(kw)}
                    className="hover:text-error transition-colors"
                  >
                    <span className="material-symbols-outlined text-[14px]">close</span>
                  </button>
                </span>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── Section 3: Severity & Action Card ── */}
      <section className="bg-surface rounded-2xl p-6 md:p-8 shadow-sm border border-surface-container-high space-y-6">
        <h2 className="font-headline-sm text-headline-sm text-on-surface font-bold flex items-center gap-2 text-base">
          <span className="material-symbols-outlined text-primary">security</span>
          Severity & Automated Action
        </h2>

        <div className="space-y-6 text-xs">
          <div>
            <span className="block font-label-lg font-bold text-on-surface mb-2.5">Threat Severity Level</span>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              {[
                { id: 'Low', label: 'Low', desc: 'Monitor silently in background', icon: 'info', activeClass: 'border-primary bg-primary-container/5' },
                { id: 'Medium', label: 'Medium', desc: 'Alert senior gently with warning', icon: 'warning', activeClass: 'border-tertiary bg-tertiary-container/10' },
                { id: 'Critical', label: 'Critical', desc: 'Immediate block & guardian dispatch', icon: 'gpp_bad', activeClass: 'border-error bg-error-container/20' }
              ].map((sev) => {
                const isSelected = severity === sev.id
                return (
                  <div
                    key={sev.id}
                    onClick={() => setSeverity(sev.id)}
                    className={`p-4 rounded-xl border-2 cursor-pointer transition-all flex flex-col items-center text-center gap-1.5 ${
                      isSelected ? sev.activeClass : 'border-surface-container-high bg-surface hover:bg-surface-container-low'
                    }`}
                  >
                    <span className={`material-symbols-outlined text-2xl ${isSelected ? 'text-primary' : 'text-outline'}`}>
                      {sev.icon}
                    </span>
                    <span className="font-label-lg font-bold text-sm text-on-surface">{sev.label}</span>
                    <span className="font-body-md text-[11px] text-on-surface-variant">{sev.desc}</span>
                  </div>
                )
              })}
            </div>
          </div>

          <div>
            <label className="block font-label-lg font-bold text-on-surface mb-1.5" htmlFor="automated-action">
              Automated Response Action
            </label>
            <div className="relative">
              <select
                id="automated-action"
                value={autoAction}
                onChange={(e) => setAutoAction(e.target.value)}
                className="h-[52px] w-full px-4 rounded-xl border border-outline-variant bg-surface-bright font-body-lg text-xs font-bold text-on-surface focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary appearance-none cursor-pointer pr-10"
              >
                <option value="review">Flag for SecOps Manual Review</option>
                <option value="notify">Notify Verified Family Guardian Instantly</option>
                <option value="block">Quarantine Message & Auto-Block Number</option>
              </select>
              <span className="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 text-outline pointer-events-none text-[20px]">
                expand_more
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* ── Footer Actions (Stitch Screen 78 Exact Layout) ── */}
      <div className="flex items-center justify-end gap-3 pt-4 border-t border-surface-container-high">
        <button
          onClick={() => navigate('/patterns')}
          className="h-[48px] px-6 rounded-full font-label-lg text-xs font-bold text-on-surface-variant hover:bg-surface-container-high transition-colors"
        >
          Cancel
        </button>
        <button
          onClick={handleSave}
          className="h-[48px] px-8 rounded-full font-label-lg text-xs font-bold bg-primary text-on-primary hover:bg-primary-container transition-colors shadow-sm flex items-center gap-2"
        >
          Save & Deploy Rule
          <span className="material-symbols-outlined text-[18px]">check</span>
        </button>
      </div>
    </div>
  )
}
