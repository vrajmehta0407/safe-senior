import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

const targetedAreas = [
  {
    id: 1,
    name: 'Delhi NCR (South Delhi / Dwarka)',
    users: '14,820 seniors protected',
    severity: 'CRITICAL',
    vector: 'Digital Arrest & CBI Cyber Impersonation',
    icon: 'local_police',
    badgeClass: 'bg-error-container text-on-error-container'
  },
  {
    id: 2,
    name: 'Mumbai Metro (Bandra / Dadar / Thane)',
    users: '11,290 seniors protected',
    severity: 'HIGH',
    vector: 'MSEDCL Electricity Power Cut SMS',
    icon: 'bolt',
    badgeClass: 'bg-tertiary-container text-on-tertiary-container'
  },
  {
    id: 3,
    name: 'Bengaluru Urban (Jayanagar / Indiranagar)',
    users: '9,450 seniors protected',
    severity: 'HIGH',
    vector: 'UPI QR Code Refund / Cashback Traps',
    icon: 'qr_code_scanner',
    badgeClass: 'bg-tertiary-container text-on-tertiary-container'
  },
  {
    id: 4,
    name: 'Ahmedabad (Navrangpura / Satellite)',
    users: '6,830 seniors protected',
    severity: 'ELEVATED',
    vector: 'SBI YONO & PAN Card KYC Expiry Phishing',
    icon: 'account_balance',
    badgeClass: 'bg-surface-container-highest text-on-surface'
  }
]

export default function HeatmapView() {
  const navigate = useNavigate()
  const [zoomLevel, setZoomLevel] = useState(1)
  const [selectedHotspot, setSelectedHotspot] = useState(null)

  return (
    <div className="space-y-8">
      {/* ── Page Header (Stitch Screen 84) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">Regional Scam Heatmap</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-1">
            Real-time geographical analysis of reported fraudulent communications and interactions across India.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/crisis-handover')}
            className="h-[44px] px-5 bg-error text-on-error rounded-xl font-label-md text-sm hover:bg-error/90 transition-colors shadow-sm flex items-center gap-2 font-bold"
          >
            <span className="material-symbols-outlined text-[18px]">local_police</span>
            1930 Cybercrime Portal Handover
          </button>
        </div>
      </div>

      {/* ── Dashboard Grid Layout (8 cols map / 4 cols side panel) ── */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Main Map Section */}
        <section className="lg:col-span-8 flex flex-col gap-6">
          {/* Map Card */}
          <div className="bg-surface rounded-2xl shadow-sm flex flex-col overflow-hidden border border-surface-container-high">
            {/* Card Header */}
            <div className="px-6 py-4 border-b border-surface-container-high flex justify-between items-center bg-surface-bright">
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-primary text-[22px]">map</span>
                <h2 className="font-headline-sm text-headline-sm text-on-surface font-bold">Live Threat Heatmap: India</h2>
              </div>
              <div className="flex gap-2">
                <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-error-container text-on-error-container rounded-full font-label-md text-xs font-bold">
                  <span className="w-2 h-2 rounded-full bg-error animate-ping"></span> Live Telecom Feed
                </span>
              </div>
            </div>

            {/* Map Container (Interactive Visual with India stylized outline) */}
            <div className="relative w-full aspect-[4/3] md:aspect-[16/9] bg-surface-container-low overflow-hidden flex items-center justify-center">
              <div className="absolute inset-0 bg-[#eef5f5] flex items-center justify-center p-6">
                <svg viewBox="0 0 800 600" className="w-full h-full text-[#c8dede] filter drop-shadow-sm">
                  {/* Stylized India Geography Outline */}
                  <path
                    d="M 400 60 Q 420 90 450 110 T 500 160 T 540 180 T 580 220 T 520 280 T 560 340 T 480 440 T 400 560 T 360 480 T 300 380 T 260 280 T 240 200 T 280 140 T 340 100 Z"
                    fill="currentColor"
                    stroke="#a4c4c4"
                    strokeWidth="2"
                  />
                  {/* Gujarat peninsula bump */}
                  <path
                    d="M 260 250 Q 200 270 210 310 Q 250 330 280 290 Z"
                    fill="currentColor"
                    stroke="#a4c4c4"
                    strokeWidth="2"
                  />
                </svg>
              </div>

              {/* Hotspot 1: Delhi NCR */}
              <div
                className="absolute top-[26%] left-[46%] cursor-pointer group"
                onClick={() => setSelectedHotspot('Delhi NCR Metro (14,820 threats)')}
              >
                <div className="w-9 h-9 bg-error/40 rounded-full hotspot-pulse absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"></div>
                <div className="w-4 h-4 bg-error rounded-full absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 shadow-lg"></div>
                <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-inverse-surface text-inverse-on-surface text-xs py-1 px-2.5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-20 font-bold">
                  Delhi NCR: CRITICAL (&gt;500/hr - Digital Arrest)
                </div>
              </div>

              {/* Hotspot 2: Mumbai / Pune */}
              <div
                className="absolute top-[52%] left-[34%] cursor-pointer group"
                onClick={() => setSelectedHotspot('Mumbai Metro (11,290 threats)')}
              >
                <div className="w-8 h-8 bg-error/40 rounded-full hotspot-pulse absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"></div>
                <div className="w-3.5 h-3.5 bg-error rounded-full absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 shadow-lg"></div>
                <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-inverse-surface text-inverse-on-surface text-xs py-1 px-2.5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-20 font-bold">
                  Mumbai: CRITICAL (410/hr - Electricity SMS)
                </div>
              </div>

              {/* Hotspot 3: Bengaluru */}
              <div
                className="absolute top-[68%] left-[44%] cursor-pointer group"
                onClick={() => setSelectedHotspot('Bengaluru Urban (9,450 threats)')}
              >
                <div className="w-7 h-7 bg-tertiary-container/40 rounded-full hotspot-pulse absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"></div>
                <div className="w-3.5 h-3.5 bg-tertiary rounded-full absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 shadow-lg"></div>
                <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-inverse-surface text-inverse-on-surface text-xs py-1 px-2.5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-20 font-bold">
                  Bengaluru: ELEVATED (310/hr - UPI Fraud)
                </div>
              </div>

              {/* Hotspot 4: Ahmedabad */}
              <div
                className="absolute top-[44%] left-[28%] cursor-pointer group"
                onClick={() => setSelectedHotspot('Ahmedabad (6,830 threats)')}
              >
                <div className="w-6 h-6 bg-tertiary-container/40 rounded-full hotspot-pulse absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"></div>
                <div className="w-3 h-3 bg-tertiary rounded-full absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 shadow-lg"></div>
                <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-inverse-surface text-inverse-on-surface text-xs py-1 px-2.5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-20 font-bold">
                  Gujarat: ELEVATED (240/hr - Banking KYC)
                </div>
              </div>

              {/* Map Controls */}
              <div className="absolute right-4 bottom-4 flex flex-col gap-2">
                <button
                  onClick={() => setZoomLevel(z => Math.min(z + 0.2, 2))}
                  className="w-10 h-10 bg-surface text-on-surface rounded-full shadow-sm flex items-center justify-center hover:bg-surface-container transition-colors font-bold"
                >
                  <span className="material-symbols-outlined text-[20px]">add</span>
                </button>
                <button
                  onClick={() => setZoomLevel(z => Math.max(z - 0.2, 0.8))}
                  className="w-10 h-10 bg-surface text-on-surface rounded-full shadow-sm flex items-center justify-center hover:bg-surface-container transition-colors font-bold"
                >
                  <span className="material-symbols-outlined text-[20px]">remove</span>
                </button>
              </div>
            </div>

            {/* Map Legend */}
            <div className="p-4 px-6 bg-surface flex flex-wrap gap-6 items-center border-t border-surface-container-high">
              <span className="font-label-md text-label-md text-on-surface-variant uppercase tracking-wider text-xs font-bold">
                Threat Density:
              </span>
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-error"></div>
                <span className="font-body-md text-sm text-on-surface">Critical (&gt;400 incidents/hr)</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-tertiary"></div>
                <span className="font-body-md text-sm text-on-surface">Elevated (100-400/hr)</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-primary"></div>
                <span className="font-body-md text-sm text-on-surface">Normal (&lt;100/hr)</span>
              </div>
            </div>
          </div>

          {/* Trending Vectors Card (Bento Style) */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-surface p-6 rounded-2xl shadow-sm border border-surface-container-high">
              <h3 className="font-label-lg text-label-lg text-on-surface mb-4 flex items-center gap-2 font-bold text-sm">
                <span className="material-symbols-outlined text-outline">call</span> Top Indian Threat Vectors
              </h3>
              <div className="space-y-4">
                <div>
                  <div className="flex justify-between font-body-md text-sm text-on-surface mb-1 font-bold">
                    <span>Digital Arrest & Police Extortion</span>
                    <span className="text-error">44%</span>
                  </div>
                  <div className="w-full bg-surface-container h-2 rounded-full overflow-hidden">
                    <div className="bg-error h-full rounded-full" style={{ width: '44%' }}></div>
                  </div>
                </div>

                <div>
                  <div className="flex justify-between font-body-md text-sm text-on-surface mb-1 font-bold">
                    <span>Electricity Disconnection (MSEDCL/BSES)</span>
                    <span className="text-tertiary">28%</span>
                  </div>
                  <div className="w-full bg-surface-container h-2 rounded-full overflow-hidden">
                    <div className="bg-tertiary h-full rounded-full" style={{ width: '28%' }}></div>
                  </div>
                </div>

                <div>
                  <div className="flex justify-between font-body-md text-sm text-on-surface mb-1 font-bold">
                    <span>SBI/HDFC KYC & UPI QR Traps</span>
                    <span className="text-primary">18%</span>
                  </div>
                  <div className="w-full bg-surface-container h-2 rounded-full overflow-hidden">
                    <div className="bg-primary h-full rounded-full" style={{ width: '18%' }}></div>
                  </div>
                </div>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="bg-primary text-on-primary p-6 rounded-2xl shadow-sm flex flex-col justify-between">
              <div>
                <h3 className="font-headline-sm text-headline-sm mb-2 text-white font-bold">Automated Isolation Shield</h3>
                <p className="font-body-md text-body-md opacity-90 mb-4 text-[#e3fffe] text-sm">
                  SafeSenior Indian telecom edge relays are actively quarantining illegal VoIP virtual numbers across Jio, Airtel, and Vi networks.
                </p>
              </div>
              <button
                onClick={() => navigate('/alerts')}
                className="w-full bg-white text-primary font-label-lg text-sm py-3 rounded-xl hover:bg-[#e3fffe] transition-colors text-center font-bold"
              >
                Review Quarantined Numbers
              </button>
            </div>
          </div>
        </section>

        {/* Right Side Panels (Spans 4 columns) */}
        <aside className="lg:col-span-4 flex flex-col gap-6">
          {/* Regional Risk Level Indicator */}
          <div className="bg-surface rounded-2xl shadow-sm p-6 border border-error-container relative overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-error/5 rounded-bl-full pointer-events-none"></div>
            <h2 className="font-headline-sm text-headline-sm text-on-surface flex items-center gap-2 mb-4 relative z-10 font-bold">
              <span className="material-symbols-outlined text-error">warning</span>
              National Threat Level (India)
            </h2>
            <div className="flex items-end gap-4 mb-2 relative z-10">
              <span className="text-4xl font-headline-lg text-error font-bold tracking-tight">ELEVATED</span>
            </div>
            <div className="flex items-center gap-1.5 text-error mt-2 relative z-10 font-bold text-xs">
              <span className="material-symbols-outlined text-sm">trending_up</span>
              <span>+18.4% surge in Digital Arrest attempts</span>
            </div>
            <div className="mt-6 pt-4 border-t border-surface-container-high relative z-10">
              <p className="font-body-md text-xs text-on-surface-variant leading-relaxed">
                Concentration in metro retirement hubs targeting senior pensioners via WhatsApp video calls and fake police identities.
              </p>
            </div>
          </div>

          {/* Top Targeted Areas List */}
          <div className="bg-surface rounded-2xl shadow-sm flex flex-col overflow-hidden border border-surface-container-high flex-1">
            <div className="px-6 py-4 border-b border-surface-container-high bg-surface-bright">
              <h2 className="font-headline-sm text-headline-sm text-on-surface font-bold text-base">Top Targeted Urban Hubs</h2>
            </div>
            <div className="flex flex-col divide-y divide-surface-container-high">
              {targetedAreas.map((area) => (
                <div
                  key={area.id}
                  onClick={() => navigate('/alerts')}
                  className="p-5 hover:bg-surface-container-low transition-colors cursor-pointer group"
                >
                  <div className="flex justify-between items-start mb-1.5">
                    <div>
                      <h4 className="font-label-lg text-sm text-on-surface group-hover:text-primary transition-colors font-bold">
                        {area.name}
                      </h4>
                      <span className="font-body-md text-xs text-on-surface-variant">
                        Targeted: {area.users}
                      </span>
                    </div>
                    <span className={`px-2 py-0.5 rounded text-[11px] font-bold ${area.badgeClass}`}>
                      {area.severity}
                    </span>
                  </div>
                  <div className="flex items-center gap-1.5 text-on-surface-variant text-xs mt-2">
                    <span className="material-symbols-outlined text-[16px]">{area.icon}</span>
                    <span>Primary vector: {area.vector}</span>
                  </div>
                </div>
              ))}
            </div>
            <div className="p-4 border-t border-surface-container-high bg-surface-bright mt-auto">
              <button
                onClick={() => navigate('/alerts')}
                className="font-label-md text-xs text-primary font-bold hover:underline flex items-center justify-center gap-1 w-full py-2"
              >
                View Comprehensive Indian Threat Map
                <span className="material-symbols-outlined text-[16px]">arrow_forward</span>
              </button>
            </div>
          </div>
        </aside>
      </div>
    </div>
  )
}
