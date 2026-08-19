import { useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { mockUsers } from '../mockData'
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts'

const riskHistory = [
  { day: 'Day 1', score: 42 },
  { day: 'Day 5', score: 45 },
  { day: 'Day 10', score: 51 },
  { day: 'Day 15', score: 68 },
  { day: 'Day 20', score: 62 },
  { day: 'Day 25', score: 74 },
  { day: 'Day 30', score: 78 }
]

export default function UserProtectionDetail() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const userId = searchParams.get('id') || 'u1'
  const user = mockUsers.find(u => u.id === userId) || mockUsers[0]

  const [txMonitoring, setTxMonitoring] = useState(true)
  const [filterLevel, setFilterLevel] = useState('High')
  const [historyRange, setHistoryRange] = useState('Last 30 Days')

  return (
    <div className="space-y-8">
      {/* ── Profile Header (Stitch Screen 73) ── */}
      <div className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <img
              src={user.avatar}
              alt={user.name}
              className="w-16 h-16 rounded-full object-cover border-2 border-primary/20"
            />
            <div>
              <h1 className="font-headline-lg text-2xl md:text-3xl font-bold text-on-surface">{user.name}</h1>
              <p className="font-body-lg text-sm text-on-surface-variant mt-0.5">
                User ID: #{user.id.toUpperCase()}-8842 • Age: {user.age} • Device: {user.device}
              </p>
            </div>
          </div>
          <div className="flex gap-3">
            <button
              onClick={() => alert(`Suspending active sessions for ${user.name}...`)}
              className="h-[44px] px-5 rounded-xl border border-outline text-on-surface font-label-md text-sm hover:bg-surface-container-high transition-colors flex items-center gap-2 font-bold"
            >
              <span className="material-symbols-outlined text-[18px]">pause</span> Suspend
            </button>
            <button
              onClick={() => navigate(`/geofencing?id=${user.id}`)}
              className="h-[44px] px-5 rounded-xl bg-primary text-on-primary font-label-md text-sm hover:bg-primary-container transition-colors flex items-center gap-2 font-bold shadow-sm"
            >
              <span className="material-symbols-outlined text-[18px]">pin_drop</span> Safe Zones
            </button>
          </div>
        </div>

        <div className="flex flex-wrap gap-3 mt-6">
          <div className="bg-surface-container-low px-4 py-2 rounded-xl flex items-center gap-2 text-xs font-bold text-on-surface border border-surface-container-high">
            <span className="material-symbols-outlined text-primary text-[16px]">home</span>
            <span>{user.location}</span>
          </div>
          <div className="bg-surface-container-low px-4 py-2 rounded-xl flex items-center gap-2 text-xs font-bold text-on-surface border border-surface-container-high">
            <span className="material-symbols-outlined text-primary text-[16px]">phone</span>
            <span>{user.phone || '+91 98250 14820'}</span>
          </div>
          <div className="bg-error-container text-on-error-container px-4 py-2 rounded-xl flex items-center gap-2 text-xs font-bold border border-error/20">
            <span className="material-symbols-outlined text-[16px]">health_and_safety</span>
            <span>Risk Score: {user.riskScore}/100 ({user.riskScore > 70 ? 'High' : 'Protected'})</span>
          </div>
        </div>
      </div>

      {/* ── Bento Grid Layout (8 cols left / 4 cols right) ── */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Left Column: Risk & Protection (8 cols) */}
        <div className="lg:col-span-8 flex flex-col gap-8">
          {/* Risk Score History (Chart Area) */}
          <section className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high">
            <div className="flex justify-between items-center mb-6">
              <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold flex items-center gap-2">
                <span className="material-symbols-outlined text-primary">monitoring</span>
                Risk Score History
              </h3>
              <select
                value={historyRange}
                onChange={(e) => setHistoryRange(e.target.value)}
                className="h-[40px] bg-surface-container-low border border-outline-variant rounded-xl font-label-md text-xs text-on-surface-variant focus:ring-2 focus:ring-primary px-3 pr-8 outline-none"
              >
                <option>Last 30 Days</option>
                <option>Last 3 Months</option>
                <option>Last Year</option>
              </select>
            </div>

            <div className="h-64 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={riskHistory} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="riskScoreGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#aa361f" stopOpacity={0.6}/>
                      <stop offset="95%" stopColor="#aa361f" stopOpacity={0.02}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#efeded" />
                  <XAxis dataKey="day" stroke="#6e7979" fontSize={11} />
                  <YAxis domain={[0, 100]} stroke="#6e7979" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#ffffff', borderRadius: 12, border: '1px solid #bdc9c8', fontSize: 12 }} />
                  <Area type="monotone" dataKey="score" name="Risk Score (0-100)" stroke="#aa361f" strokeWidth={2.5} fillOpacity={1} fill="url(#riskScoreGrad)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </section>

          {/* Protection Sensitivity Controls */}
          <section className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high">
            <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold mb-6 flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">tune</span>
              Protection Sensitivity
            </h3>
            <div className="space-y-4">
              <div className="bg-surface-container-low p-4 rounded-2xl flex items-center justify-between border border-surface-container-high">
                <div>
                  <h4 className="font-label-lg font-bold text-sm text-on-surface">Financial Transaction Monitoring</h4>
                  <p className="font-body-md text-xs text-on-surface-variant mt-0.5">Alerts guardians immediately for unusual wire or gift card charges.</p>
                </div>
                <button
                  onClick={() => setTxMonitoring(!txMonitoring)}
                  className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
                    txMonitoring ? 'bg-primary' : 'bg-outline-variant'
                  }`}
                >
                  <div
                    className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform ${
                      txMonitoring ? 'translate-x-6' : 'translate-x-0'
                    }`}
                  />
                </button>
              </div>

              <div className="bg-surface-container-low p-4 rounded-2xl border border-surface-container-high">
                <h4 className="font-label-lg font-bold text-sm text-on-surface">Communication Filter Level</h4>
                <p className="font-body-md text-xs text-on-surface-variant mt-0.5 mb-3">Determines strictness of unknown caller and link screening.</p>
                <div className="flex gap-2">
                  {['Low', 'Medium', 'High (Strict)'].map((lvl) => {
                    const active = (filterLevel === 'High' && lvl.startsWith('High')) || filterLevel === lvl
                    return (
                      <button
                        key={lvl}
                        onClick={() => setFilterLevel(lvl.startsWith('High') ? 'High' : lvl)}
                        className={`flex-1 py-2.5 rounded-xl font-label-md text-xs font-bold transition-all ${
                          active
                            ? 'bg-primary text-on-primary shadow-sm'
                            : 'bg-surface text-on-surface border border-outline hover:bg-surface-container-high'
                        }`}
                      >
                        {lvl}
                      </button>
                    )
                  })}
                </div>
              </div>
            </div>
          </section>
        </div>

        {/* Right Column: People & Alerts (4 cols) */}
        <div className="lg:col-span-4 flex flex-col gap-8">
          {/* Connected Guardians */}
          <section className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high">
            <div className="flex justify-between items-center mb-6">
              <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold flex items-center gap-2">
                <span className="material-symbols-outlined text-primary">family_restroom</span>
                Connected Guardians
              </h3>
              <button
                onClick={() => navigate('/guardian-dashboard')}
                className="text-primary hover:bg-primary-container/20 p-2 rounded-full transition-colors"
                title="Add Guardian"
              >
                <span className="material-symbols-outlined text-[20px]">add_circle</span>
              </button>
            </div>
            <div className="space-y-3">
              {user.guardians.map((g, idx) => (
                <div key={idx} className="flex items-center gap-3 p-3 bg-surface-container-low rounded-2xl border border-surface-container-high">
                  <div className="w-10 h-10 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center font-bold text-xs">
                    {g.name.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div className="flex-1">
                    <h4 className="font-label-lg font-bold text-sm text-on-surface">{g.name}</h4>
                    <p className="font-body-md text-xs text-on-surface-variant">{g.relation} • {g.phone}</p>
                  </div>
                  <button className="text-on-surface-variant hover:text-primary transition-colors p-1">
                    <span className="material-symbols-outlined text-[18px]">phone</span>
                  </button>
                </div>
              ))}
            </div>
          </section>

          {/* Recent Alerts Timeline */}
          <section className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high flex-1">
            <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold mb-6 flex items-center gap-2">
              <span className="material-symbols-outlined text-secondary">warning</span>
              Recent Threat Timeline
            </h3>
            <div className="space-y-4 relative before:absolute before:inset-y-0 before:left-[19px] before:w-px before:bg-outline-variant">
              <div className="relative pl-12">
                <div className="absolute left-0 top-1 w-10 h-10 rounded-full bg-secondary-container text-on-secondary-container flex items-center justify-center border-4 border-surface shadow-sm z-10">
                  <span className="material-symbols-outlined text-sm">credit_card_off</span>
                </div>
                <div className="bg-surface-container-low p-4 rounded-2xl border border-secondary-container/30">
                  <span className="text-[11px] font-bold text-secondary mb-1 block">2 hours ago</span>
                  <h4 className="font-label-md font-bold text-xs text-on-surface">Blocked UPI Transfer Attempt</h4>
                  <p className="font-body-md text-xs text-on-surface-variant mt-1">₹15,000 unverified transfer to "Quick-Tech-Support" blocked by SafeSenior Shield.</p>
                </div>
              </div>

              <div className="relative pl-12">
                <div className="absolute left-0 top-1 w-10 h-10 rounded-full bg-tertiary-container text-on-tertiary-container flex items-center justify-center border-4 border-surface shadow-sm z-10">
                  <span className="material-symbols-outlined text-sm">phone_missed</span>
                </div>
                <div className="bg-surface-container-low p-4 rounded-2xl border border-surface-container-high">
                  <span className="text-[11px] font-bold text-on-surface-variant mb-1 block">Yesterday, 4:30 PM</span>
                  <h4 className="font-label-md font-bold text-xs text-on-surface">MSEDCL Electricity Spoof Blocked</h4>
                  <p className="font-body-md text-xs text-on-surface-variant mt-1">Number flagged as power cut phishing SMS by community database.</p>
                </div>
              </div>
            </div>

            <button
              onClick={() => navigate('/alerts')}
              className="w-full mt-6 py-2.5 text-primary font-label-md text-xs font-bold hover:bg-primary-container/10 rounded-xl transition-colors border border-primary/20"
            >
              View Full Incident History
            </button>
          </section>
        </div>
      </div>
    </div>
  )
}
