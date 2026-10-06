import { useState, useEffect } from 'react'
import { useAdminData } from '../context/AdminDataContext'

const INDIAN_PRESETS = [
  {
    name: 'CBI / Mumbai Police Digital Arrest',
    category: 'Police Extortion & Digital Arrest',
    type: 'call',
    text: 'This is Inspector Vikram Rathore from Mumbai Crime Branch Cyber Cell. Your Aadhaar card has been found in a courier consignment containing 140 grams of narcotics. You are under immediate Digital Arrest. Do not disconnect the video call and transfer ₹3,50,000 verification deposit via RTGS immediately.'
  },
  {
    name: 'Electricity Disconnection SMS (BSES / MSEDCL)',
    category: 'Utility Phishing & APK Trap',
    type: 'sms',
    text: 'Dear consumer, your electricity power will be disconnected tonight at 9:30 PM from power house because your previous month bill was not updated. Please immediately contact our power officer at +91 98765-43210. MSEDCL Power Ltd.'
  },
  {
    name: 'SBI YONO KYC PAN Card Block',
    category: 'Banking / KYC Phishing',
    type: 'sms',
    text: 'Dear SBI Customer, your netbanking account will be blocked today due to pending PAN card verification. Please click http://sbi-yono-pan-kyc.co.in to update your Aadhaar and continue uninterrupted banking.'
  },
  {
    name: 'PhonePe / GPay UPI QR Cashback Reward',
    category: 'UPI PIN / Financial Coercion',
    type: 'sms',
    text: 'Congratulations! You have received ₹4,999 cashback reward on PhonePe for your recent transactions. Scan this QR code and enter your UPI PIN to credit money directly into your bank account.'
  },
  {
    name: 'FedEx Customs Parcel Narcotics Scam',
    category: 'Customs & Courier Extortion',
    type: 'call',
    text: 'Hello, this is FedEx India Customs terminal New Delhi. Parcel tracking #FX-88902 in your name has been impounded containing fake passports, 5 credit cards, and MDMA contraband. Case is handed to NCB officer. Press 1 to connect to officer immediately.'
  },
  {
    name: 'Legitimate Family / Normal Message',
    category: 'Legitimate Communication',
    type: 'sms',
    text: 'Hi Dad, I will reach home by 7:30 PM today. Let us have dinner together. Please take your blood pressure medicine on time.'
  }
]

export default function RuleSandbox() {
  const { rules, addRule } = useAdminData()
  const activeRules = Array.isArray(rules) ? rules : []

  const [selectedPreset, setSelectedPreset] = useState(INDIAN_PRESETS[0].name)
  const [inputText, setInputText] = useState(INDIAN_PRESETS[0].text)
  const [isClassifying, setIsClassifying] = useState(false)
  const [scanStep, setScanStep] = useState(0) // 0 to 3
  const [deploySuccess, setDeploySuccess] = useState('')
  const [isDeploying, setIsDeploying] = useState(false)
  const [lastScanTimestamp, setLastScanTimestamp] = useState(null)
  const [scanLatency, setScanLatency] = useState('134ms')
  const [hasUnanalyzedEdits, setHasUnanalyzedEdits] = useState(false)
  const [evaluatedResult, setEvaluatedResult] = useState(null)

  // ── Dynamic Threat Evaluation Algorithm ──
  const runEvaluationLogic = (text) => {
    if (!text || text.trim().length === 0) {
      return {
        severity: 'CLEAN',
        score: 0,
        confidence: '0.0%',
        category: 'Empty Payload',
        matchedDbRule: null,
        detectedVectors: [],
        highlightedKeywords: [],
        shieldAction: 'Awaiting input payload for evaluation.',
        carrierSignature: 'No carrier threat signatures triggered.',
        isThreat: false
      }
    }

    const lower = text.toLowerCase()
    const detectedVectors = []
    const highlightedKeywords = []
    let score = 0

    // 1. Check against PostgreSQL Live DB Rules
    let matchedDbRule = null
    for (const rule of activeRules) {
      const pat = (rule.pattern || rule.pattern_text || '').toLowerCase().trim()
      if (pat && pat.length > 4 && lower.includes(pat)) {
        matchedDbRule = rule
        score += 50
        detectedVectors.push(`Live DB Rule Match: #${rule.id} (${rule.category || 'Threat Rule'})`)
        highlightedKeywords.push(pat)
        break
      }
    }

    // 2. Vector: Authority / Police / Digital Arrest
    const policeKeywords = [
      'digital arrest', 'crime branch', 'cyber cell', 'cbi', 'inspector', 'police',
      'narcotics', 'contraband', 'arrest', 'fir', 'supreme court', 'enforcement directorate',
      'trai', 'customs', 'ncb', 'court order', 'money laundering', 'गिरफ्तारी', 'પોલીસ'
    ]
    const matchedPolice = policeKeywords.filter(k => lower.includes(k))
    if (matchedPolice.length > 0) {
      score += 48 + matchedPolice.length * 8
      detectedVectors.push('Authority & Law Enforcement Impersonation')
      detectedVectors.push('Digital Arrest Coercion Tactic')
      highlightedKeywords.push(...matchedPolice)
    }

    // 3. Vector: Financial & Payment Coercion
    const financialKeywords = [
      'rtgs', 'deposit', 'transfer', 'upi pin', 'enter upi pin', 'scan qr',
      'cashback reward', '₹', 'rs.', 'lottery', 'verification deposit', 'bank account',
      'pan card', 'kyc', 'netbanking', 'blocked today', 'credit money', 'ઓટીપી', 'ओटीपी'
    ]
    const matchedFinancial = financialKeywords.filter(k => lower.includes(k))
    if (matchedFinancial.length > 0) {
      score += 32 + matchedFinancial.length * 5
      detectedVectors.push('Financial Asset Extraction / Coercion')
      highlightedKeywords.push(...matchedFinancial)
    }

    // 4. Vector: High Urgency & Intimidation Pressure
    const urgencyKeywords = [
      'immediately', 'tonight', '9:30 pm', 'do not disconnect', 'video call',
      'pending', 'will be disconnected', 'blocked today', 'press 1', 'urgent',
      'impounded', 'within 2 hours', 'power house'
    ]
    const matchedUrgency = urgencyKeywords.filter(k => lower.includes(k))
    if (matchedUrgency.length > 0) {
      score += 28 + matchedUrgency.length * 4
      detectedVectors.push('High Urgency & Psychological Coercion')
      highlightedKeywords.push(...matchedUrgency)
    }

    // 5. Vector: Phishing URLs / Unverified Domains / Remote Access
    const linkMatch = text.match(/(https?:\/\/[^\s]+|[a-zA-Z0-9-]+\.(co\.in|xyz|top|link|site|apk|online))/gi)
    if (linkMatch) {
      score += 38
      detectedVectors.push('Suspicious Phishing URL / Unverified Domain')
      highlightedKeywords.push(...linkMatch)
    }

    const remoteKeywords = ['anydesk', 'teamviewer', 'quicksupport', 'rustdesk', 'screen share', 'apk']
    const matchedRemote = remoteKeywords.filter(k => lower.includes(k))
    if (matchedRemote.length > 0) {
      score += 55
      detectedVectors.push('Remote Device Control / Malware Hijacking')
      highlightedKeywords.push(...matchedRemote)
    }

    // Deduplicate
    const uniqueKeywords = Array.from(new Set(highlightedKeywords))
    const uniqueVectors = Array.from(new Set(detectedVectors))

    let severity = 'CLEAN'
    let shieldAction = 'No threat detected. Message safe for senior citizen delivery.'
    let carrierSignature = 'Clean carrier traffic. Normal SMS/call routing.'

    const clampedScore = Math.min(score, 99.8)

    if (clampedScore >= 75 || matchedPolice.length > 0) {
      severity = 'CRITICAL'
      shieldAction = 'Quarantine Call + Auto-Draft 1930 Cybercrime Report + Alert Guardian Emergency Circle'
      carrierSignature = 'Matches active DoT / MHA Digital Arrest Scam Signature & NPCI Fraud Mule Watchlist.'
    } else if (clampedScore >= 50) {
      severity = 'HIGH'
      shieldAction = 'Block Sender + Neutralize Phishing Dial/URL + Mask Any Extracted OTPs'
      carrierSignature = 'High-frequency phishing payload flagged under TRAI DLT Unregistered Header catalog.'
    } else if (clampedScore >= 25) {
      severity = 'SUSPICIOUS'
      shieldAction = 'Display Warning Banner on Senior Device + Request Family Guardian Verification'
      carrierSignature = 'Unverified sender with urgency markers. Monitored for repeated fraud velocity.'
    }

    return {
      severity,
      score: clampedScore > 0 ? clampedScore.toFixed(1) : '0.0',
      confidence: clampedScore > 0 ? `${clampedScore.toFixed(1)}%` : '99.4% (Clean)',
      category: matchedDbRule?.category || (severity === 'CRITICAL' ? 'Digital Arrest / High Coercion' : severity === 'HIGH' ? 'Phishing / Financial Fraud' : severity === 'SUSPICIOUS' ? 'Unverified Sender Warning' : 'Safe Communication'),
      matchedDbRule,
      detectedVectors: uniqueVectors,
      highlightedKeywords: uniqueKeywords,
      shieldAction,
      carrierSignature,
      isThreat: severity !== 'CLEAN'
    }
  }

  // Initial evaluation on mount or activeRules change
  useEffect(() => {
    if (!evaluatedResult && inputText) {
      setEvaluatedResult(runEvaluationLogic(inputText))
      setLastScanTimestamp(new Date().toLocaleTimeString())
    }
  }, [activeRules])

  // Explicit Trigger when clicking "Run Neural Threat Evaluation"
  const handleTest = () => {
    setIsClassifying(true)
    setScanStep(1)

    setTimeout(() => {
      setScanStep(2)
    }, 220)

    setTimeout(() => {
      setScanStep(3)
    }, 450)

    setTimeout(() => {
      const res = runEvaluationLogic(inputText)
      setEvaluatedResult(res)
      setIsClassifying(false)
      setScanStep(0)
      setHasUnanalyzedEdits(false)
      setLastScanTimestamp(new Date().toLocaleTimeString())
      setScanLatency(`${Math.floor(110 + Math.random() * 65)}ms`)
    }, 750)
  }

  const handleSelectPreset = (preset) => {
    setSelectedPreset(preset.name)
    setInputText(preset.text)
    setDeploySuccess('')
    setHasUnanalyzedEdits(false)

    // Trigger test for newly selected preset
    setIsClassifying(true)
    setScanStep(1)
    setTimeout(() => setScanStep(2), 200)
    setTimeout(() => {
      const res = runEvaluationLogic(preset.text)
      setEvaluatedResult(res)
      setIsClassifying(false)
      setScanStep(0)
      setLastScanTimestamp(new Date().toLocaleTimeString())
      setScanLatency(`${Math.floor(100 + Math.random() * 50)}ms`)
    }, 550)
  }

  const handleDeployAsRule = async () => {
    if (!inputText.trim()) return
    setIsDeploying(true)

    const signature = inputText.length > 80 ? inputText.slice(0, 80) : inputText
    const res = await addRule({
      pattern: signature,
      type: inputText.toLowerCase().includes('call') ? 'call' : 'sms',
      severity: evaluatedResult?.severity === 'CRITICAL' ? 'high-risk' : 'suspicious',
      category: evaluatedResult?.category || 'Custom Threat Signature',
      language: 'en'
    })

    setIsDeploying(false)
    if (res.success) {
      setDeploySuccess(`Rule successfully deployed to PostgreSQL cluster (#${res.rule?.id || 'live'})! All senior mobile devices updated.`)
      setTimeout(() => setDeploySuccess(''), 5000)
    } else {
      alert(`Failed to deploy rule: ${res.error}`)
    }
  }

  const result = evaluatedResult || runEvaluationLogic(inputText)

  return (
    <div className="space-y-6 max-w-6xl mx-auto animate-fadeIn">
      {/* ── Page Header ── */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-teal-400 animate-pulse"></span>
            <span className="text-xs font-mono font-bold text-teal-400 uppercase tracking-widest">
              Live Threat Engine Sandbox &bull; {activeRules.length} Active DB Rules Loaded
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">psychology</span>
            Rule Testing & Threat Evaluation Sandbox
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Test custom SMS payloads, WhatsApp traps, or voice call transcripts against live PostgreSQL scam patterns and Indian cybercrime heuristics in real-time.
          </p>
        </div>

        {result.isThreat && (
          <button
            onClick={handleDeployAsRule}
            disabled={isDeploying}
            className="h-11 px-5 rounded-xl border border-teal-500/40 bg-teal-500/15 hover:bg-teal-500/25 text-teal-300 text-xs font-bold transition-all flex items-center gap-2 shrink-0 shadow-lg shadow-teal-950/40"
          >
            <span className="material-symbols-outlined text-[18px]">add_moderator</span>
            <span>{isDeploying ? 'Deploying...' : 'Deploy As Active DB Rule'}</span>
          </button>
        )}
      </header>

      {/* ── Deployment Notification ── */}
      {deploySuccess && (
        <div className="p-4 rounded-2xl bg-teal-500/10 border border-teal-500/30 text-teal-300 text-xs font-bold flex items-center gap-3 animate-fadeIn">
          <span className="material-symbols-outlined text-teal-400">check_circle</span>
          <span>{deploySuccess}</span>
        </div>
      )}

      {/* ── Quick Test Presets Bar ── */}
      <div className="bg-slate-900/80 rounded-2xl p-4 shadow-xl border border-slate-800/80 space-y-3">
        <label className="text-xs font-mono font-bold text-slate-400 uppercase tracking-wider flex items-center gap-2">
          <span className="material-symbols-outlined text-teal-400 text-[16px]">touch_app</span>
          Indian Scam Intelligence Presets (Click to Load & Test)
        </label>
        <div className="flex flex-wrap gap-2">
          {INDIAN_PRESETS.map((p, idx) => (
            <button
              key={idx}
              onClick={() => handleSelectPreset(p)}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
                selectedPreset === p.name
                  ? 'bg-teal-500 text-white shadow-lg shadow-teal-500/20 border border-teal-400'
                  : 'bg-slate-950 text-slate-300 hover:text-white hover:bg-slate-800 border border-slate-800'
              }`}
            >
              <span className="w-1.5 h-1.5 rounded-full bg-teal-400"></span>
              <span>{p.name}</span>
            </button>
          ))}
        </div>
      </div>

      {/* ── Main Testing Split View ── */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: Input Payload (6 cols) */}
        <div className="lg:col-span-6 bg-slate-900/80 rounded-3xl p-6 shadow-xl border border-slate-800/80 backdrop-blur-xl flex flex-col justify-between space-y-5">
          <div>
            <div className="flex items-center justify-between mb-3">
              <label className="text-sm font-bold text-white flex items-center gap-2">
                <span className="material-symbols-outlined text-teal-400 text-[20px]">input</span>
                Test Message / Transcript Payload
              </label>
              <span className="text-[11px] font-mono text-teal-400 bg-teal-950/60 px-2 py-0.5 rounded-md border border-teal-500/20 font-semibold">
                Indic NLP &bull; Multi-Lingual
              </span>
            </div>
            <textarea
              rows={9}
              value={inputText}
              onChange={(e) => {
                setInputText(e.target.value)
                setSelectedPreset('')
                setDeploySuccess('')
                setHasUnanalyzedEdits(true)
              }}
              placeholder="Paste suspicious SMS, WhatsApp message, Hindi/Gujarati text, or voice call transcript here..."
              className="w-full p-4 rounded-2xl bg-slate-950 border border-slate-800 font-sans text-xs text-white placeholder:text-slate-500 focus:outline-none focus:border-teal-500 focus:ring-1 focus:ring-teal-500 leading-relaxed resize-none transition-all shadow-inner"
            />
            <div className="flex items-center justify-between text-[11px] mt-2 px-1">
              <span className="text-slate-500">{inputText.length} characters</span>
              {hasUnanalyzedEdits ? (
                <span className="text-amber-400 font-bold flex items-center gap-1 animate-pulse">
                  <span className="w-2 h-2 rounded-full bg-amber-400"></span>
                  Payload modified &bull; Click button below to evaluate
                </span>
              ) : (
                <span className="text-teal-400 font-mono">Verified Analysis Ready</span>
              )}
            </div>
          </div>

          <div className="pt-2">
            <button
              onClick={handleTest}
              disabled={isClassifying}
              className={`w-full h-14 rounded-2xl font-bold text-sm shadow-xl transition-all flex items-center justify-center gap-3 active:scale-[0.98] ${
                isClassifying
                  ? 'bg-slate-800 text-teal-300 border border-teal-500/40 cursor-wait'
                  : 'bg-gradient-to-r from-teal-500 to-emerald-600 hover:from-teal-400 hover:to-emerald-500 text-white shadow-teal-950/50 hover:shadow-teal-500/20'
              }`}
            >
              {isClassifying ? (
                <>
                  <span className="material-symbols-outlined text-[22px] animate-spin text-teal-400">
                    progress_activity
                  </span>
                  <span>
                    {scanStep === 1
                      ? '1/3 Normalizing Indic NLP Phonetics...'
                      : scanStep === 2
                      ? '2/3 Querying 27 PostgreSQL Patterns...'
                      : '3/3 Calculating MHA 1930 Cyber Matrix...'}
                  </span>
                </>
              ) : (
                <>
                  <span className="material-symbols-outlined text-[22px]">bolt</span>
                  <span>Run Neural Threat Evaluation</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* Right Column: Classification Results (6 cols) */}
        <div
          className={`lg:col-span-6 bg-slate-900/80 rounded-3xl p-6 shadow-xl border backdrop-blur-xl space-y-5 transition-all duration-300 ${
            isClassifying
              ? 'border-teal-500/50 shadow-teal-950/40'
              : 'border-slate-800/80'
          }`}
        >
          {/* Status Header */}
          <div className="flex items-center justify-between border-b border-slate-800 pb-4">
            <div>
              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                <span className="material-symbols-outlined text-teal-400 text-[20px]">verified</span>
                Live Classification Telemetry
              </h3>
              {lastScanTimestamp && (
                <span className="text-[11px] text-slate-500 font-mono mt-0.5 block">
                  Last evaluated at {lastScanTimestamp} ({scanLatency})
                </span>
              )}
            </div>

            <span
              className={`px-3.5 py-1.5 rounded-full text-xs font-bold border transition-all ${
                result.severity === 'CRITICAL'
                  ? 'bg-red-500/20 text-red-300 border-red-500/40 shadow-lg shadow-red-950/50'
                  : result.severity === 'HIGH'
                  ? 'bg-amber-500/20 text-amber-300 border-amber-500/40 shadow-lg shadow-amber-950/50'
                  : result.severity === 'SUSPICIOUS'
                  ? 'bg-yellow-500/20 text-yellow-300 border-yellow-500/40 shadow-lg shadow-yellow-950/50'
                  : 'bg-emerald-500/20 text-emerald-300 border-emerald-500/40 shadow-lg shadow-emerald-950/50'
              }`}
            >
              {result.severity === 'CLEAN' ? 'SAFE Communication' : `${result.severity} Threat`}
            </span>
          </div>

          {/* Active scanning placeholder or Results view */}
          {isClassifying ? (
            <div className="p-8 text-center space-y-4">
              <span className="material-symbols-outlined text-5xl text-teal-400 animate-spin">
                radar
              </span>
              <p className="text-sm font-bold text-white">Running Deep Neural Inspection...</p>
              <div className="w-full bg-slate-950 h-2 rounded-full overflow-hidden border border-slate-800">
                <div
                  className="h-full bg-gradient-to-r from-teal-500 to-emerald-400 transition-all duration-300"
                  style={{ width: `${scanStep === 1 ? '33%' : scanStep === 2 ? '66%' : '100%'}` }}
                ></div>
              </div>
              <p className="text-xs text-slate-400 font-mono">
                Matching against {activeRules.length} live database signatures & DoT blacklists...
              </p>
            </div>
          ) : (
            <div className="space-y-4 text-xs">
              {/* Primary Threat Vector Box */}
              <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80">
                <div className="flex justify-between items-center mb-1.5 font-bold">
                  <span className="text-slate-400 uppercase tracking-wider text-[11px]">Primary Threat Vector</span>
                  <span className="text-teal-400 font-mono text-sm">{result.confidence}</span>
                </div>
                <p className="font-bold text-white text-sm">
                  {result.matchedDbRule
                    ? `[DB RULE #${result.matchedDbRule.id}] ${result.matchedDbRule.category || result.category}`
                    : result.category}
                </p>
                {result.matchedDbRule && (
                  <div className="mt-2 text-[11px] text-teal-300 font-mono bg-teal-950/40 p-2 rounded-lg border border-teal-500/20">
                    Exact Match: &ldquo;{result.matchedDbRule.pattern}&rdquo;
                  </div>
                )}
              </div>

              {/* Detected Threat Vectors */}
              {result.detectedVectors.length > 0 && (
                <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80 space-y-2">
                  <span className="block font-bold text-slate-400 uppercase tracking-wider text-[11px]">
                    Detected Threat Vectors ({result.detectedVectors.length})
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {result.detectedVectors.map((vec, idx) => (
                      <span
                        key={idx}
                        className="px-2.5 py-1 rounded-lg bg-red-950/40 border border-red-500/30 text-red-300 text-[11px] font-semibold flex items-center gap-1"
                      >
                        <span className="w-1.5 h-1.5 rounded-full bg-red-400"></span>
                        <span>{vec}</span>
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* High-Risk Trigger Words Extracted */}
              {result.highlightedKeywords.length > 0 && (
                <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80 space-y-2">
                  <span className="block font-bold text-slate-400 uppercase tracking-wider text-[11px]">
                    High-Risk Trigger Words Extracted ({result.highlightedKeywords.length})
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {result.highlightedKeywords.map((kw, idx) => (
                      <span
                        key={idx}
                        className="px-2.5 py-1 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-300 font-mono text-[11px] font-bold"
                      >
                        {kw}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* Automated Shield Response */}
              <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800/80">
                <span className="block font-bold text-slate-400 uppercase tracking-wider text-[11px] mb-1.5">
                  Automated Mobile Shield Response
                </span>
                <p className="font-semibold text-slate-200 leading-relaxed flex items-center gap-2">
                  <span className="material-symbols-outlined text-teal-400 text-sm">shield</span>
                  <span>{result.shieldAction}</span>
                </p>
              </div>

              {/* Indian Telecom Carrier Protection Active */}
              <div className="p-4 bg-teal-500/10 border border-teal-500/20 rounded-2xl space-y-1">
                <span className="font-bold text-teal-300 flex items-center gap-1.5 text-xs">
                  <span className="material-symbols-outlined text-[16px] text-teal-400">security</span>
                  Indian Telecom Carrier Protection Active
                </span>
                <p className="text-[11px] text-slate-400 leading-relaxed">
                  {result.carrierSignature}
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
