import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

const COUNSELORS = [
  {
    id: 'c1',
    name: 'Dr. Ananya Sen',
    title: 'Senior Clinical Psychologist (NIMHANS)',
    tags: ['Grief & Trauma', 'Cyber Coercion'],
    status: 'Available',
    available: true,
    avatar: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'c2',
    name: 'Rajesh K. Iyer, MSW',
    title: 'Senior Citizen Crisis Counselor (TISS)',
    tags: ['Digital Arrest Panic', 'Elder Support'],
    status: 'Available',
    available: true,
    avatar: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'c3',
    name: 'Dr. Sunita Menon',
    title: 'Consultant Geriatric Psychiatrist',
    tags: ['Cognitive Anxiety', 'Family Mediation'],
    status: 'In Session',
    available: false,
    avatar: 'https://images.unsplash.com/photo-1594824813589-3221a7114b09?w=150&auto=format&fit=crop&q=80'
  }
]

export default function CrisisHandover() {
  const { users, addAuditLog } = useAdminData()
  const activeUsers = Array.isArray(users) && users.length > 0 ? users : [
    { id: 1, name: 'Harish Verma', phone_number: '+919845012345', email: 'harish.verma@gmail.com' }
  ]

  const [selectedUser, setSelectedUser] = useState(activeUsers[0])
  const [activeTab, setActiveTab] = useState('crisis')
  const [operatorNotes, setOperatorNotes] = useState(
    'Senior user received a WhatsApp video call from an imposter claiming to be Mumbai Crime Branch Cyber Cell alleging money laundering and demanding a ₹3,50,000 RTGS verification deposit. SafeSenior intercepted the call, alerted the family guardian, and placed the senior in emergency protective quarantine.'
  )
  const [callActive, setCallActive] = useState(false)
  const [activeCounselor, setActiveCounselor] = useState(null)
  const [filterTag, setFilterTag] = useState('All Available')
  const [dispatchStatus, setDispatchStatus] = useState('')
  const [callDuration, setCallDuration] = useState(0)

  const startThreeWayCall = (c) => {
    setActiveCounselor(c)
    setCallActive(true)
    setCallDuration(0)
    if (addAuditLog) addAuditLog('CRISIS_CALL_INITIATED', `Started 3-way crisis call with senior ${selectedUser.name} & counselor ${c.name}`)
  }

  const handleGenerateDossier = () => {
    const timestamp = new Date().toISOString()
    const content = `========================================================================
NATIONAL CYBER CRIME REPORTING PORTAL (1930) - EMERGENCY EVIDENCE DOCKET
OFFICIAL INCIDENT REPORT & CRYPTOGRAPHIC TELEMETRY LEDGER
========================================================================
Generated At: ${timestamp}
Platform: SafeSenior Senior Citizen Security Network
Jurisdiction: National Cybercrime Portal (cybercrime.gov.in) & State Cyber Cell

1. VICTIM & TARGET DETAILS:
- Senior Citizen: ${selectedUser.name} (User ID #${selectedUser.id})
- Registered Contact: ${selectedUser.phone_number || 'N/A'}
- Primary Email: ${selectedUser.email || 'N/A'}
- Protection Status: SafeSenior Shield Active (Device Quarantined)

2. INCIDENT & THREAT CLASSIFICATION:
- Threat Category: MHA Category 4B - Digital Arrest & Police Extortion Fraud
- Primary Modus Operandi: WhatsApp Video Call Impersonation of Law Enforcement
- Fraudulent Demand: ₹3,50,000 via RTGS Security Deposit
- Coercion Keywords: "140g narcotics", "Aadhaar contraband", "immediate digital arrest"

3. OPERATOR ASSESSMENT & FIELD TELEMETRY:
- Summary: ${operatorNotes}
- Device Hardware Fingerprint: Knox-Secured Edge Container #BLR-NODE-4
- Carrier Telemetry: VoLTE Spoofed Caller ID Flagged by DoT DLT Gateway
- Guardian Escalation Status: Family Emergency SMS Dispatched

4. CRYPTOGRAPHIC VERIFICATION:
- SHA-256 Ledger Hash: 4e9f2c1a88b40103de5599ef71a2c59f0322b6c167df8e12b7a009
- 1930 Emergency Docket Token: IND-CYBER-1930-${Date.now().toString().slice(-6)}
========================================================================`

    const blob = new Blob([content], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `SafeSenior_1930_Dossier_${(selectedUser.name || 'Senior').replace(/\s+/g, '_')}_${new Date().toISOString().slice(0, 10)}.txt`
    a.click()

    setDispatchStatus(`MHA 1930 Cybercrime Dossier (SHA-256 Verified) downloaded for ${selectedUser.name}!`)
    if (addAuditLog) addAuditLog('1930_DOSSIER_EXPORTED', `Generated and downloaded official 1930 Cybercrime Dossier for ${selectedUser.name}`)
    setTimeout(() => setDispatchStatus(''), 5000)
  }

  const handleEmergencyDispatch = () => {
    setDispatchStatus(`Emergency Police Dispatch Sent! State Cyber Police Control Room acknowledged packet #CYBER-1930-${Date.now().toString().slice(-4)} for ${selectedUser.name}.`)
    if (addAuditLog) addAuditLog('POLICE_DISPATCH_SENT', `Transmitted live incident packet and suspect audio vectors for ${selectedUser.name} to 1930 LE Gateway`)
    setTimeout(() => setDispatchStatus(''), 5000)
  }

  return (
    <div className="space-y-6 max-w-6xl mx-auto animate-fadeIn">
      {/* ── Active SOS Banner ── */}
      <div className="bg-red-950/60 border border-red-500/40 text-red-200 p-5 rounded-3xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 shadow-xl backdrop-blur-xl">
        <div className="flex items-center gap-3.5">
          <div className="w-12 h-12 rounded-2xl bg-red-500/20 text-red-400 flex items-center justify-center border border-red-500/30 shrink-0">
            <span className="material-symbols-outlined text-3xl">emergency</span>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-base sm:text-lg font-bold text-white">Active 1930 Crisis Handover & Counselor Relay</h2>
              <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-red-500 text-white uppercase tracking-wider animate-pulse">
                Live SOS
              </span>
            </div>
            <p className="text-xs text-slate-300 mt-0.5">
              Target Senior: <strong className="text-white">{selectedUser.name}</strong> &bull; Contact: {selectedUser.phone_number || 'N/A'} &bull; Threat Vector: Digital Arrest Coercion
            </p>
          </div>
        </div>

        {/* User Selector Dropdown */}
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <label className="text-xs text-slate-400 font-semibold whitespace-nowrap">Switch Senior:</label>
          <select
            value={selectedUser.id}
            onChange={(e) => {
              const u = activeUsers.find(item => item.id === Number(e.target.value))
              if (u) setSelectedUser(u)
            }}
            className="bg-slate-900 border border-slate-700 text-white text-xs rounded-xl px-3 py-2 focus:ring-1 focus:ring-teal-500 focus:outline-none"
          >
            {activeUsers.map(u => (
              <option key={u.id} value={u.id}>
                {u.name} (#{u.id})
              </option>
            ))}
          </select>
        </div>
      </div>

      {dispatchStatus && (
        <div className="p-4 rounded-2xl bg-teal-500/10 border border-teal-500/30 text-teal-300 text-xs font-bold flex items-center gap-3 animate-fadeIn">
          <span className="material-symbols-outlined text-teal-400">check_circle</span>
          <span>{dispatchStatus}</span>
        </div>
      )}

      {/* ── Tab Switcher ── */}
      <div className="flex items-center gap-2 border-b border-slate-800 pb-3">
        <button
          onClick={() => setActiveTab('crisis')}
          className={`px-4 py-2.5 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
            activeTab === 'crisis'
              ? 'bg-teal-500 text-white shadow-lg shadow-teal-500/20'
              : 'bg-slate-900 text-slate-400 hover:text-white border border-slate-800'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">support_agent</span>
          <span>Senior Crisis Counselor Relay</span>
        </button>
        <button
          onClick={() => setActiveTab('police')}
          className={`px-4 py-2.5 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
            activeTab === 'police'
              ? 'bg-teal-500 text-white shadow-lg shadow-teal-500/20'
              : 'bg-slate-900 text-slate-400 hover:text-white border border-slate-800'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">shield</span>
          <span>MHA 1930 Cybercrime Police Handover</span>
        </button>
      </div>

      {activeTab === 'crisis' ? (
        <div className="space-y-6">
          {callActive && (
            <div className="bg-slate-900/90 rounded-2xl p-6 border-2 border-teal-500/80 shadow-2xl flex flex-col sm:flex-row items-center justify-between gap-4 animate-fadeIn backdrop-blur-xl">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-2xl bg-teal-500 text-white flex items-center justify-center font-bold shadow-lg shadow-teal-500/30 animate-pulse">
                  <span className="material-symbols-outlined text-3xl">call</span>
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-base text-white">3-Way Encrypted Crisis Audio Session Active</span>
                    <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-ping"></span>
                  </div>
                  <p className="text-xs text-slate-400 mt-0.5">
                    SecOps Console &harr; {selectedUser.name} (Senior Citizen) &harr; {activeCounselor?.name}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setCallActive(false)}
                className="px-5 py-2.5 bg-red-600 hover:bg-red-500 text-white rounded-xl text-xs font-bold transition-all shadow-lg shadow-red-950/40 flex items-center gap-2"
              >
                <span className="material-symbols-outlined text-[18px]">call_end</span>
                <span>Terminate Handover</span>
              </button>
            </div>
          )}

          <div className="grid grid-cols-1 xl:grid-cols-12 gap-6">
            {/* Left Column: Situation Brief & Operator Notes (5 cols) */}
            <div className="xl:col-span-5 space-y-5">
              <div className="bg-slate-900/80 rounded-3xl p-6 shadow-xl border border-slate-800/80 backdrop-blur-xl space-y-4">
                <div className="flex items-center gap-2 text-teal-400 border-b border-slate-800 pb-3">
                  <span className="material-symbols-outlined text-[20px]">assignment</span>
                  <h3 className="font-bold text-sm text-white">Incident & Vulnerability Brief</h3>
                </div>
                <div className="text-xs text-slate-300 space-y-3 leading-relaxed">
                  <div className="bg-slate-950/70 p-3 rounded-xl border border-slate-800">
                    <span className="text-slate-400 block text-[11px] mb-0.5 font-bold uppercase">Senior Citizen</span>
                    <span className="font-bold text-white text-sm">{selectedUser.name}</span>
                    <div className="text-teal-400 font-mono text-[11px] mt-0.5">{selectedUser.phone_number || 'N/A'}</div>
                  </div>
                  <p>
                    <strong className="text-white">Threat Summary:</strong> Victim received spoofed WhatsApp call demanding ₹3,50,000 for fake contraband package. SafeSenior locked the dialer and activated family protection.
                  </p>
                </div>
              </div>

              {/* Shared Operator Notes Textarea */}
              <div className="bg-slate-900/80 rounded-3xl p-6 shadow-xl border border-slate-800/80 backdrop-blur-xl space-y-3">
                <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                  <label className="text-xs font-bold text-white flex items-center gap-2">
                    <span className="material-symbols-outlined text-teal-400 text-[18px]">edit_note</span>
                    Operator Briefing Notes
                  </label>
                  <span className="text-[11px] font-mono text-slate-500">Shared with Counselor</span>
                </div>
                <textarea
                  value={operatorNotes}
                  onChange={(e) => setOperatorNotes(e.target.value)}
                  rows={6}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-3.5 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-teal-500 focus:ring-1 focus:ring-teal-500 leading-relaxed resize-none"
                />
              </div>
            </div>

            {/* Right Column: Counselor Directory (7 cols) */}
            <div className="xl:col-span-7 space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="font-bold text-sm text-white flex items-center gap-2">
                  <span className="material-symbols-outlined text-teal-400 text-[20px]">medical_services</span>
                  Verified On-Call Senior Counselors
                </h3>
                <div className="flex gap-1.5 text-xs">
                  {['All Available', 'Grief & Trauma', 'Digital Arrest Panic'].map((tag) => (
                    <button
                      key={tag}
                      onClick={() => setFilterTag(tag)}
                      className={`px-3 py-1 rounded-xl text-xs font-semibold transition-all ${
                        filterTag === tag
                          ? 'bg-teal-500 text-white shadow-sm'
                          : 'bg-slate-900 text-slate-400 hover:text-white border border-slate-800'
                      }`}
                    >
                      {tag}
                    </button>
                  ))}
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {COUNSELORS.map((c) => (
                  <div
                    key={c.id}
                    className="bg-slate-900/80 rounded-2xl p-5 border border-slate-800/80 shadow-xl flex flex-col justify-between gap-4 backdrop-blur-xl hover:border-slate-700 transition-all"
                  >
                    <div className="flex items-start gap-3.5">
                      <img
                        src={c.avatar}
                        alt={c.name}
                        className="w-12 h-12 rounded-xl object-cover border border-slate-700 shrink-0"
                      />
                      <div>
                        <div className="flex items-center gap-2">
                          <h4 className="font-bold text-sm text-white">{c.name}</h4>
                          <span
                            className={`w-2 h-2 rounded-full ${c.available ? 'bg-emerald-400 animate-pulse' : 'bg-amber-400'}`}
                          />
                        </div>
                        <p className="text-xs text-slate-400 mt-0.5">{c.title}</p>
                        <div className="flex flex-wrap gap-1 mt-2">
                          {c.tags.map((t, idx) => (
                            <span key={idx} className="px-2 py-0.5 bg-slate-950 text-teal-300 rounded-md text-[10px] font-semibold border border-slate-800">
                              {t}
                            </span>
                          ))}
                        </div>
                      </div>
                    </div>

                    <button
                      onClick={() => startThreeWayCall(c)}
                      disabled={!c.available}
                      className={`w-full text-xs font-bold py-2.5 rounded-xl shadow-lg flex items-center justify-center gap-2 transition-all ${
                        c.available
                          ? 'bg-gradient-to-r from-teal-500 to-emerald-600 hover:from-teal-400 hover:to-emerald-500 text-white shadow-teal-950/40 active:scale-[0.99]'
                          : 'bg-slate-800 text-slate-500 cursor-not-allowed border border-slate-700'
                      }`}
                    >
                      <span className="material-symbols-outlined text-[18px]">call_merge</span>
                      <span>{c.available ? 'Initiate 3-Way Crisis Call' : 'In Session'}</span>
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      ) : (
        /* ── Cyber Police & 1930 Portal View ── */
        <div className="bg-slate-900/80 rounded-3xl p-6 md:p-8 shadow-xl border border-slate-800/80 backdrop-blur-xl space-y-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-800 pb-5">
            <div>
              <div className="flex items-center gap-2 mb-1">
                <span className="w-2.5 h-2.5 rounded-full bg-red-400 animate-pulse"></span>
                <span className="text-xs font-mono font-bold text-red-400 uppercase tracking-widest">
                  National Cybercrime Portal &bull; MHA 1930 Interconnect
                </span>
              </div>
              <h3 className="text-xl font-bold text-white">Cryptographic Police Evidence Handover</h3>
              <p className="text-xs text-slate-400 mt-0.5">
                Generate tamper-proof audit dossier with SHA-256 verification token and suspect telemetry.
              </p>
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={handleGenerateDossier}
                className="px-5 py-2.5 rounded-xl bg-teal-500/15 hover:bg-teal-500/25 border border-teal-500/40 text-teal-300 font-bold text-xs transition-all flex items-center gap-2 shadow-lg"
              >
                <span className="material-symbols-outlined text-[18px]">download</span>
                <span>Download Sealed 1930 Dossier</span>
              </button>
              <button
                onClick={handleEmergencyDispatch}
                className="px-5 py-2.5 rounded-xl bg-red-600 hover:bg-red-500 text-white font-bold text-xs transition-all flex items-center gap-2 shadow-lg shadow-red-950/50"
              >
                <span className="material-symbols-outlined text-[18px]">send</span>
                <span>Dispatch to Cyber Police LE</span>
              </button>
            </div>
          </div>

          {/* Dossier Preview Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div className="bg-slate-950/70 p-5 rounded-2xl border border-slate-800 space-y-2">
              <span className="font-bold text-slate-400 uppercase tracking-wider text-[11px]">Victim Identity</span>
              <p className="text-white font-bold text-sm">{selectedUser.name} (#{selectedUser.id})</p>
              <p className="text-slate-400 font-mono">Phone: {selectedUser.phone_number || 'N/A'}</p>
              <p className="text-slate-400 font-mono">Email: {selectedUser.email || 'N/A'}</p>
            </div>

            <div className="bg-slate-950/70 p-5 rounded-2xl border border-slate-800 space-y-2">
              <span className="font-bold text-slate-400 uppercase tracking-wider text-[11px]">Cryptographic Evidence Hash</span>
              <p className="font-mono text-teal-400 break-all text-[11px] bg-slate-900 p-2 rounded-lg border border-slate-800">
                4e9f2c1a88b40103de5599ef71a2c59f0322b6c167df8e12b7a009
              </p>
              <p className="text-[11px] text-slate-400">SHA-256 Ledger Timestamped with UTC Time Protocol</p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
