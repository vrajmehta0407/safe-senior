import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

const counselors = [
  {
    id: 'c1',
    name: 'Dr. Ananya Sen',
    title: 'Senior Clinical Psychologist (NIMHANS)',
    tags: ['Grief & Trauma', 'Cyber Coercion'],
    status: 'Available',
    statusClass: 'bg-primary-container/20 text-primary',
    dotClass: 'bg-primary',
    available: true,
    avatar: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'c2',
    name: 'Rajesh K. Iyer, MSW',
    title: 'Senior Citizen Crisis Counselor (TISS)',
    tags: ['Digital Arrest Panic', 'Elder Support'],
    status: 'Available',
    statusClass: 'bg-primary-container/20 text-primary',
    dotClass: 'bg-primary',
    available: true,
    avatar: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'c3',
    name: 'Dr. Sunita Menon',
    title: 'Consultant Geriatric Psychiatrist',
    tags: ['Cognitive Anxiety', 'Family Mediation'],
    status: 'In Session',
    statusClass: 'bg-tertiary-container/20 text-tertiary',
    dotClass: 'bg-tertiary',
    available: false,
    avatar: 'https://images.unsplash.com/photo-1594824813589-3221a7114b09?w=150&auto=format&fit=crop&q=80'
  }
]

export default function CrisisHandover() {
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState('crisis')
  const [operatorNotes, setOperatorNotes] = useState(
    'Harish ji is currently on the line, hyperventilating after receiving a fake CBI Digital Arrest video call demanding ₹3,50,000 via RTGS. I have calmed him down, confirmed he is safe inside his Jayanagar residence, and his son Vikram has been patched in.'
  )
  const [callActive, setCallActive] = useState(false)
  const [activeCounselor, setActiveCounselor] = useState(null)
  const [filterTag, setFilterTag] = useState('All Available')

  const startThreeWayCall = (c) => {
    setActiveCounselor(c)
    setCallActive(true)
  }

  return (
    <div className="space-y-6">
      {/* ── Active SOS Escalation Context Banner ── */}
      <div className="bg-error-container text-on-error-container p-5 rounded-2xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border border-error/20 shadow-sm">
        <div className="flex items-center gap-3">
          <span className="material-symbols-outlined text-error text-3xl">warning</span>
          <div>
            <h1 className="font-headline-sm text-base md:text-lg font-bold">Active SOS Escalation: Requires Crisis Counselor</h1>
            <p className="font-body-md text-xs opacity-90 mt-0.5">
              Protected Senior: Harish Verma (Age 85) • Location: Bengaluru, Karnataka • Trigger: Digital Arrest Coercion
            </p>
          </div>
        </div>
        <div className="px-4 py-1.5 bg-error text-on-error rounded-full font-label-md text-xs flex items-center gap-2 font-bold animate-pulse">
          <div className="w-2 h-2 rounded-full bg-white"></div>
          Live Crisis Channel Maintained
        </div>
      </div>

      {/* ── Tab Switcher ── */}
      <div className="flex items-center gap-3 border-b border-surface-container-high pb-2">
        <button
          onClick={() => setActiveTab('crisis')}
          className={`px-4 py-2 rounded-xl text-sm font-label-md font-bold transition-all ${
            activeTab === 'crisis'
              ? 'bg-primary text-on-primary shadow-sm'
              : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
          }`}
        >
          Senior Crisis Counselor Connection
        </button>
        <button
          onClick={() => setActiveTab('police')}
          className={`px-4 py-2 rounded-xl text-sm font-label-md font-bold transition-all ${
            activeTab === 'police'
              ? 'bg-primary text-on-primary shadow-sm'
              : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
          }`}
        >
          Cyber Police & 1930 Handover
        </button>
      </div>

      {activeTab === 'crisis' ? (
        <>
          {callActive && (
            <div className="bg-surface rounded-2xl p-6 border-2 border-primary shadow-md flex items-center justify-between gap-4 animate-fade-in">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-full bg-primary text-on-primary flex items-center justify-center font-bold">
                  <span className="material-symbols-outlined text-2xl">call</span>
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-base text-on-surface">3-Way Encrypted Crisis Call Active</span>
                    <span className="w-2.5 h-2.5 rounded-full bg-success animate-ping"></span>
                  </div>
                  <p className="text-xs text-on-surface-variant mt-0.5">
                    SecOps Operator ↔ Harish Verma (Senior) ↔ {activeCounselor?.name}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setCallActive(false)}
                className="px-4 py-2 bg-error text-on-error rounded-xl text-xs font-bold hover:bg-error/90 transition-colors shadow-sm"
              >
                End Handover
              </button>
            </div>
          )}

          <div className="grid grid-cols-1 xl:grid-cols-12 gap-6">
            {/* Left Column: Operator Briefing Area (4 cols) */}
            <section className="xl:col-span-4 flex flex-col gap-6">
              {/* Situation Brief Card */}
              <div className="bg-surface rounded-2xl shadow-sm p-5 flex flex-col gap-3 border border-surface-container-high">
                <div className="flex items-center gap-2 text-primary">
                  <span className="material-symbols-outlined text-[20px]">assignment</span>
                  <h2 className="font-headline-sm text-sm font-bold">Situation Brief</h2>
                </div>
                <div className="text-on-surface-variant space-y-2 text-xs leading-relaxed">
                  <p>
                    <strong className="text-on-surface">Preliminary Assessment:</strong> User received a WhatsApp video call from a fraudster dressed in a fake Mumbai Police uniform alleging money laundering via courier consignment. Scammer demanded immediate ₹3,50,000 transfer.
                  </p>
                  <p>
                    <strong className="text-on-surface">Medical / Vulnerability History:</strong> Hypertension and mild cognitive anxiety. Lives alone in Jayanagar, Bengaluru. Son Vikram lives in Indiranagar.
                  </p>
                </div>
              </div>

              {/* Shared Notes Textarea */}
              <div className="bg-surface rounded-2xl shadow-sm p-5 flex flex-col gap-3 border border-surface-container-high flex-grow">
                <div className="flex items-center justify-between">
                  <label className="font-label-lg text-xs font-bold text-on-surface flex items-center gap-2">
                    <span className="material-symbols-outlined text-[18px]">edit_note</span>
                    Operator Briefing Notes
                  </label>
                  <span className="text-[11px] text-outline font-semibold">Shared with Counselor</span>
                </div>
                <p className="text-[11px] text-on-surface-variant">
                  Draft context here before initiating the three-way call. This will appear on the counselor's console instantly.
                </p>
                <textarea
                  value={operatorNotes}
                  onChange={(e) => setOperatorNotes(e.target.value)}
                  rows={6}
                  className="w-full bg-surface-container-low resize-none border border-outline-variant focus:border-primary focus:ring-1 focus:ring-primary rounded-xl p-3.5 text-xs text-on-surface placeholder:text-outline transition-colors outline-none leading-relaxed"
                />
              </div>
            </section>

            {/* Right Column: Counselor Directory (8 cols) */}
            <section className="xl:col-span-8 flex flex-col gap-6">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <h2 className="font-headline-md text-base font-bold text-on-surface">Available On-Call Senior Counselors</h2>
                <div className="flex gap-2">
                  {['All Available', 'Grief & Trauma', 'Digital Arrest Panic'].map((tag) => (
                    <button
                      key={tag}
                      onClick={() => setFilterTag(tag)}
                      className={`px-3 py-1.5 rounded-full font-label-md text-xs font-bold transition-colors ${
                        filterTag === tag
                          ? 'bg-primary text-on-primary shadow-sm'
                          : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
                      }`}
                    >
                      {tag}
                    </button>
                  ))}
                </div>
              </div>

              {/* Directory Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {counselors.map((c) => (
                  <div
                    key={c.id}
                    className={`bg-surface rounded-2xl shadow-sm p-5 border border-surface-container-high flex flex-col gap-4 ${
                      !c.available ? 'opacity-70' : 'hover:shadow-md'
                    } transition-shadow`}
                  >
                    <div className="flex items-start gap-4">
                      <img
                        src={c.avatar}
                        alt={c.name}
                        className="w-14 h-14 rounded-full object-cover border border-outline-variant"
                      />
                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <h3 className="font-label-lg font-bold text-sm text-on-surface">{c.name}</h3>
                          <div className={`flex items-center gap-1.5 px-2 py-0.5 rounded-md ${c.statusClass}`}>
                            <div className={`w-1.5 h-1.5 rounded-full ${c.dotClass}`}></div>
                            <span className="font-label-md text-[11px] font-bold">{c.status}</span>
                          </div>
                        </div>
                        <p className="font-body-md text-xs text-on-surface-variant mt-0.5">{c.title}</p>
                        <div className="flex flex-wrap gap-1 mt-2">
                          {c.tags.map((t, idx) => (
                            <span key={idx} className="px-2 py-0.5 bg-surface-container text-on-surface-variant rounded-md text-[10px] font-bold">
                              {t}
                            </span>
                          ))}
                        </div>
                      </div>
                    </div>

                    <button
                      onClick={() => startThreeWayCall(c)}
                      disabled={!c.available}
                      className={`w-full font-label-lg text-xs font-bold py-2.5 rounded-xl shadow-sm flex items-center justify-center gap-2 mt-auto transition-colors ${
                        c.available
                          ? 'bg-primary text-on-primary hover:bg-primary-container'
                          : 'bg-surface-variant text-outline cursor-not-allowed'
                      }`}
                    >
                      <span className="material-symbols-outlined text-[18px]">call_merge</span>
                      {c.available ? 'Initiate Three-Way Call' : 'Currently in Session'}
                    </button>
                  </div>
                ))}
              </div>
            </section>
          </div>
        </>
      ) : (
        /* ── Cyber Police & 1930 Portal View ── */
        <div className="bg-surface rounded-2xl p-6 shadow-sm border border-surface-container-high space-y-6">
          <div className="flex items-center justify-between border-b border-surface-container-high pb-4">
            <div>
              <h2 className="font-headline-md text-lg font-bold text-on-surface">National Cyber Crime Portal (1930) & State Police Handover</h2>
              <p className="text-xs text-on-surface-variant mt-0.5">
                Generate tamper-proof cryptographic audit dossier for National Cybercrime Portal (cybercrime.gov.in) and Bengaluru Cyber Police
              </p>
            </div>
            <span className="px-3 py-1 rounded-full text-xs font-bold bg-error-container text-on-error-container">
              Cert-In / MHA 1930 Format
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            <div className="bg-surface-container-low p-4 rounded-xl border border-surface-container-high">
              <strong className="block font-bold mb-1">Target Account</strong>
              <p className="text-on-surface-variant">Harish Verma (Age 85)</p>
              <p className="text-on-surface-variant">Jayanagar, Bengaluru, Karnataka</p>
            </div>
            <div className="bg-surface-container-low p-4 rounded-xl border border-surface-container-high">
              <strong className="block font-bold mb-1">Suspect VoIP / WhatsApp Endpoint</strong>
              <p className="text-on-surface-variant">+91 98450 01928 (Spoofed Virtual)</p>
              <p className="text-on-surface-variant">Originating IP: 103.212.45.18 (Cambodia proxy)</p>
            </div>
            <div className="bg-surface-container-low p-4 rounded-xl border border-surface-container-high">
              <strong className="block font-bold mb-1">Prevented Financial Loss</strong>
              <p className="text-xl font-bold text-primary">₹3,50,000 INR</p>
              <p className="text-on-surface-variant">RTGS Transfer Auto-Blocked</p>
            </div>
          </div>

          <div className="flex gap-3">
            <button
              onClick={() => alert('Generating Sealed 1930 Cybercrime Dossier (PDF)...')}
              className="h-[44px] px-5 bg-primary text-on-primary rounded-xl font-label-md text-xs font-bold flex items-center gap-2 hover:bg-primary-container transition-colors shadow-sm"
            >
              <span className="material-symbols-outlined text-[18px]">download</span>
              Download Sealed Case PDF (1930 Portal)
            </button>
            <button
              onClick={() => alert('Dispatching telemetry packet to Bengaluru Cyber Police Control Room...')}
              className="h-[44px] px-5 bg-error text-on-error rounded-xl font-label-md text-xs font-bold flex items-center gap-2 hover:bg-error/90 transition-colors shadow-sm"
            >
              <span className="material-symbols-outlined text-[18px]">local_police</span>
              Emergency Cyber Police Dispatch
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
