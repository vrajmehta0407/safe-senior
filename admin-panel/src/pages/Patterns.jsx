import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

const patternCards = [
  {
    id: 'PTN-001',
    title: 'Grandparent Scam: Voice Cloning',
    category: 'Deepfake Audio',
    desc: 'Detects urgent requests for money using distressed vocal patterns matching known family contacts.',
    accuracy: '94.2%',
    blocked: '1,248',
    status: 'Active',
    statusClass: 'text-primary bg-surface/90',
    icon: 'verified_user',
    bgGradient: 'from-[#006565]/20 to-[#008080]/30',
    primaryAction: 'Modify Rule'
  },
  {
    id: 'PTN-002',
    title: 'IRDAI / PMJJBY Insurance Phishing (SMS)',
    category: 'Phishing Vectors',
    desc: 'Identifies SMS messages falsely claiming IRDAI or PMJJBY policy lapse with suspicious APK download or OTP phish links.',
    accuracy: '88.5%',
    blocked: '5,902',
    status: 'Review Needed',
    statusClass: 'text-secondary bg-surface/90',
    icon: 'warning',
    bgGradient: 'from-[#aa361f]/20 to-[#fe7356]/30',
    primaryAction: 'Refine Detection'
  },
  {
    id: 'PTN-003',
    title: 'UPI QR Code Cashback Coercion',
    category: 'Financial Coercion',
    desc: 'Flags conversations demanding payment via PhonePe / GPay QR codes for fabricated cashback schemes or utility bills.',
    accuracy: '98.1%',
    blocked: '341',
    status: 'Active',
    statusClass: 'text-primary bg-surface/90',
    icon: 'verified_user',
    bgGradient: 'from-[#735c00]/20 to-[#cca830]/30',
    primaryAction: 'Modify Rule'
  },
  {
    id: 'PTN-004',
    title: 'Romance Scam: Isolation Tactics',
    category: 'Social Engineering',
    desc: 'Experimental model detecting language designed to isolate the user from family members over extended messaging periods.',
    accuracy: '72.4%',
    blocked: '89',
    status: 'Learning Mode',
    statusClass: 'text-on-surface-variant bg-surface-variant',
    icon: 'sync',
    bgGradient: 'from-surface-container-high to-surface-container-highest',
    primaryAction: 'Review Cases'
  }
]

export default function Patterns() {
  const navigate = useNavigate()
  const [selectedFilter, setSelectedFilter] = useState('All Patterns')

  const filterCategories = [
    'All Patterns',
    'Phishing Vectors',
    'Social Engineering',
    'Deepfake Audio',
    'Financial Coercion'
  ]

  const filtered = selectedFilter === 'All Patterns'
    ? patternCards
    : patternCards.filter(p => p.category === selectedFilter)

  return (
    <div className="space-y-8">
      {/* ── Page Header (Stitch Screen 79) ── */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h2 className="font-headline-lg text-headline-lg text-on-surface font-bold">Pattern Management Library</h2>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-1 max-w-2xl">
            Monitor, refine, and deploy detection rules to protect users against emerging scam vectors.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => navigate('/rules-wizard')}
            className="px-5 py-2.5 rounded-full bg-primary text-on-primary font-label-md text-sm hover:bg-primary-container transition-colors shadow-sm border border-primary-fixed-dim flex items-center gap-2 font-bold"
          >
            <span className="material-symbols-outlined text-[18px]">add</span> New System Rule
          </button>
        </div>
      </div>

      {/* ── Filter Chips ── */}
      <div className="flex overflow-x-auto gap-2.5 pb-2">
        {filterCategories.map((cat) => {
          const active = selectedFilter === cat
          return (
            <button
              key={cat}
              onClick={() => setSelectedFilter(cat)}
              className={`px-5 py-2 rounded-full font-label-md text-xs font-bold whitespace-nowrap transition-colors ${
                active
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'bg-surface-container-low text-primary hover:bg-primary-container/20 border border-surface-container-high'
              }`}
            >
              {cat}
            </button>
          )
        })}
      </div>

      {/* ── Masonry Grid of Pattern Cards (Stitch Exact Layout) ── */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filtered.map((pattern) => (
          <div
            key={pattern.id}
            className="bg-surface-container-lowest rounded-2xl overflow-hidden shadow-sm border border-surface-container-high flex flex-col"
          >
            <div className={`relative h-44 w-full bg-gradient-to-br ${pattern.bgGradient} flex items-center justify-center p-6`}>
              <div className="absolute top-4 right-4 bg-surface/90 backdrop-blur-sm rounded-full p-2 text-primary shadow-sm">
                <span className="material-symbols-outlined text-[18px]">{pattern.icon}</span>
              </div>
              <div className="absolute bottom-4 left-4">
                <span className={`px-3 py-1 backdrop-blur-sm rounded-full font-label-md text-xs font-bold ${pattern.statusClass}`}>
                  {pattern.status}
                </span>
              </div>
              <div className="text-center font-bold text-on-surface opacity-30 text-3xl select-none">
                {pattern.category}
              </div>
            </div>

            <div className="p-6 flex flex-col flex-1 justify-between">
              <div>
                <h3 className="font-headline-sm text-base font-bold text-on-surface mb-2">{pattern.title}</h3>
                <p className="font-body-md text-xs text-on-surface-variant mb-6 leading-relaxed">
                  {pattern.desc}
                </p>

                <div className="grid grid-cols-2 gap-3 mb-6">
                  <div className="bg-surface-container-low p-3 rounded-xl border border-surface-container-high">
                    <p className="font-label-md text-[11px] text-on-surface-variant font-bold">Accuracy</p>
                    <p className="font-headline-md text-xl font-bold text-primary">{pattern.accuracy}</p>
                  </div>
                  <div className="bg-surface-container-low p-3 rounded-xl border border-surface-container-high">
                    <p className="font-label-md text-[11px] text-on-surface-variant font-bold">Blocked (30d)</p>
                    <p className="font-headline-md text-xl font-bold text-on-surface">{pattern.blocked}</p>
                  </div>
                </div>
              </div>

              <div className="flex gap-2">
                <button
                  onClick={() => navigate('/rules-sandbox')}
                  className="flex-1 bg-surface-container-low text-on-surface font-label-lg text-xs font-bold py-2.5 rounded-xl hover:bg-surface-container-high transition-colors flex items-center justify-center gap-1.5 border border-outline-variant"
                >
                  <span className="material-symbols-outlined text-[16px]">science</span>
                  Sandbox
                </button>
                <button
                  onClick={() => navigate('/rules-wizard')}
                  className="flex-1 bg-primary text-on-primary font-label-lg text-xs font-bold py-2.5 rounded-xl hover:bg-primary-container transition-colors flex items-center justify-center gap-1.5 shadow-sm"
                >
                  <span className="material-symbols-outlined text-[16px]">edit</span>
                  {pattern.primaryAction}
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
