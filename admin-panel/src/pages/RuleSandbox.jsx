import { useState } from 'react'

const indianPresets = [
  {
    name: 'CBI / Mumbai Police Digital Arrest',
    category: 'Police Extortion',
    text: 'This is Inspector Vikram Rathore from Mumbai Crime Branch Cyber Cell. Your Aadhaar card has been found in a courier consignment containing 140 grams of narcotics. You are under immediate Digital Arrest. Do not disconnect the video call and transfer ₹3,50,000 verification deposit via RTGS immediately.',
    expectedSeverity: 'CRITICAL',
    matchedRule: 'PTN-001: Digital Arrest & Cyber Police Coercion',
    confidence: '98.9%',
    action: 'Quarantine Call + 1930 Cybercrime Draft'
  },
  {
    name: 'Electricity Disconnection SMS (BSES / MSEDCL)',
    category: 'Utility Phishing',
    text: 'Dear consumer, your electricity power will be disconnected tonight at 9:30 PM from power house because your previous month bill was not updated. Please immediately contact our power officer at +91 98765-43210. MSEDCL Power Ltd.',
    expectedSeverity: 'HIGH',
    matchedRule: 'PTN-002: Electricity Bill Disconnection SMS & APK Trap',
    confidence: '96.4%',
    action: 'Block SMS + Neutralize Dialer'
  },
  {
    name: 'SBI YONO KYC PAN Card Block',
    category: 'Banking Phishing',
    text: 'Dear SBI Customer, your netbanking account will be blocked today due to pending PAN card verification. Please click sbi-yono-pan-kyc.co.in to update your Aadhaar and continue uninterrupted banking.',
    expectedSeverity: 'HIGH',
    matchedRule: 'PTN-003: SBI / HDFC NetBanking KYC & PAN Block',
    confidence: '94.8%',
    action: 'Domain Blocked + Carrier URL Filter'
  },
  {
    name: 'PhonePe / GPay UPI QR Cashback Reward',
    category: 'Financial Coercion',
    text: 'Congratulations! You have received ₹4,999 cashback reward on PhonePe for your recent transactions. Scan this QR code and enter your UPI PIN to credit money directly into your bank account.',
    expectedSeverity: 'HIGH',
    matchedRule: 'PTN-004: UPI "Receive Money / Scan QR" PIN Scam',
    confidence: '97.2%',
    action: 'Shield UPI Keypad + Emergency Guardian Prompt'
  }
]

export default function RuleSandbox() {
  const [selectedPreset, setSelectedPreset] = useState(indianPresets[0])
  const [inputText, setInputText] = useState(indianPresets[0].text)
  const [isClassifying, setIsClassifying] = useState(false)
  const [result, setResult] = useState(indianPresets[0])

  const handleTest = () => {
    setIsClassifying(true)
    setTimeout(() => {
      setIsClassifying(false)
      const matched = indianPresets.find(p => p.name === selectedPreset.name) || indianPresets[0]
      setResult(matched)
    }, 450)
  }

  const selectPreset = (preset) => {
    setSelectedPreset(preset)
    setInputText(preset.text)
    setResult(preset)
  }

  return (
    <div className="space-y-8 max-w-5xl mx-auto">
      {/* ── Header (Stitch Screen 77) ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">Rule Testing Sandbox</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-1">
            Test and evaluate Indian threat detection vectors against multi-lingual natural language models.
          </p>
        </div>
      </div>

      {/* ── Quick Test Presets Bar ── */}
      <div className="space-y-2">
        <label className="text-xs font-bold text-outline uppercase tracking-wider">
          Indian Scam Intelligence Presets
        </label>
        <div className="flex flex-wrap gap-2">
          {indianPresets.map((p, idx) => (
            <button
              key={idx}
              onClick={() => selectPreset(p)}
              className={`px-4 py-2 rounded-xl text-xs font-label-md font-bold transition-all ${
                selectedPreset.name === p.name
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'bg-surface-container-high text-on-surface hover:bg-surface-container-highest'
              }`}
            >
              {p.name}
            </button>
          ))}
        </div>
      </div>

      {/* ── Main Testing Split View ── */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: Input Payload (6 cols) */}
        <div className="lg:col-span-6 bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high flex flex-col justify-between space-y-4">
          <div>
            <div className="flex items-center justify-between mb-3">
              <label className="font-headline-sm text-sm font-bold text-on-surface flex items-center gap-2">
                <span className="material-symbols-outlined text-primary text-[20px]">input</span>
                Test Message / Transcript Payload
              </label>
              <span className="text-[11px] text-outline font-semibold">Indic NLP Multi-Lingual</span>
            </div>
            <textarea
              rows={8}
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              placeholder="Paste suspicious SMS, WhatsApp message, or voice call transcript..."
              className="w-full p-4 rounded-2xl bg-surface-container-low border border-outline font-body-md text-xs text-on-surface focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary leading-relaxed resize-none"
            />
          </div>

          <button
            onClick={handleTest}
            disabled={isClassifying}
            className="w-full h-[48px] rounded-xl bg-primary text-on-primary font-label-md text-xs font-bold hover:bg-primary-container transition-colors shadow-sm flex items-center justify-center gap-2"
          >
            {isClassifying ? (
              <>
                <span className="material-symbols-outlined text-[18px] animate-spin">refresh</span>
                Classifying Multi-Model Stream...
              </>
            ) : (
              <>
                <span className="material-symbols-outlined text-[18px]">psychology</span>
                Run Neural Threat Evaluation
              </>
            )}
          </button>
        </div>

        {/* Right Column: Classification Results (6 cols) */}
        <div className="lg:col-span-6 bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high space-y-5">
          <div className="flex items-center justify-between border-b border-surface-container-high pb-3">
            <h2 className="font-headline-sm text-sm font-bold text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary text-[20px]">verified</span>
              Classification Telemetry
            </h2>
            <span className={`px-3 py-1 rounded-full text-xs font-bold ${
              result.expectedSeverity === 'CRITICAL' ? 'bg-error-container text-on-error-container' : 'bg-tertiary-container/20 text-tertiary'
            }`}>
              {result.expectedSeverity} Threat
            </span>
          </div>

          <div className="space-y-4 text-xs">
            <div className="bg-surface-container-low p-4 rounded-2xl border border-surface-container-high">
              <div className="flex justify-between items-center mb-1 font-bold">
                <span className="text-on-surface-variant">Matched Protection Rule</span>
                <span className="text-primary font-mono">{result.confidence}</span>
              </div>
              <p className="font-bold text-sm text-on-surface">{result.matchedRule}</p>
            </div>

            <div className="bg-surface-container-low p-4 rounded-2xl border border-surface-container-high">
              <span className="block font-bold text-on-surface-variant mb-1">Automated Shield Response</span>
              <p className="font-semibold text-on-surface">{result.action}</p>
            </div>

            <div className="p-4 bg-primary-container/10 border border-primary/20 rounded-2xl space-y-1">
              <span className="font-bold text-primary flex items-center gap-1.5">
                <span className="material-symbols-outlined text-[16px]">security</span>
                Indian Telecom Carrier Protection Active
              </span>
              <p className="text-[11px] text-on-surface-variant leading-relaxed">
                Matches active DoT / TRAI spam signature catalog and NPCI UPI mule patterns.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
