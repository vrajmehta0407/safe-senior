import { useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

export default function AlertsCenter() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const { alerts, users, resolveAlert } = useAdminData()

  const [activeFilter, setActiveFilter] = useState('action') // 'action' | 'monitoring' | 'resolved'
  const initialAlertId = searchParams.get('id') || alerts[0]?.id || 'alt-901'
  const [selectedAlertId, setSelectedAlertId] = useState(initialAlertId)
  const [actionDoneMessage, setActionDoneMessage] = useState('')

  const activeAlert = alerts.find(a => a.id === selectedAlertId) || alerts[0] || {}
  const protectedUser = users.find(u => u.id === activeAlert.seniorId) || users[0] || {
    name: activeAlert.seniorName || 'Shanti Patel',
    age: 76,
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80'
  }

  const filteredAlerts = alerts.filter(a => {
    if (activeFilter === 'resolved') return a.status === 'Resolved'
    if (activeFilter === 'monitoring') return a.severity === 'Medium' && a.status !== 'Resolved'
    return a.status !== 'Resolved' // 'action'
  })

  const handleAction = (msg, resolution) => {
    setActionDoneMessage(msg)
    if (activeAlert.id && resolution) {
      resolveAlert(activeAlert.id, resolution)
    }
    setTimeout(() => setActionDoneMessage(''), 4000)
  }

  return (
    <div className="space-y-6">
      {actionDoneMessage && (
        <div className="bg-primary text-on-primary px-4 py-3 rounded-2xl flex items-center justify-between shadow-md text-sm font-bold animate-pulse">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[20px]">check_circle</span>
            <span>{actionDoneMessage}</span>
          </div>
          <button onClick={() => setActionDoneMessage('')} className="text-white/80 hover:text-white">
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>
      )}

      {/* ── Two-Pane Investigation Layout (Stitch Screen 74) ── */}
      <div className="flex flex-col lg:flex-row gap-6 bg-surface-container-lowest rounded-3xl border border-surface-container-high shadow-sm overflow-hidden min-h-[750px]">
        {/* Left Pane: Alerts List (w-full lg:w-[420px]) */}
        <div className="w-full lg:w-[420px] flex flex-col border-r border-surface-container-high bg-surface flex-shrink-0">
          <div className="p-4 border-b border-surface-container-high flex gap-2 overflow-x-auto">
            <button
              onClick={() => setActiveFilter('action')}
              className={`px-3.5 py-1.5 rounded-full font-label-md text-xs font-bold whitespace-nowrap transition-colors ${
                activeFilter === 'action'
                  ? 'bg-primary text-on-primary border border-primary'
                  : 'bg-surface-container-low text-primary hover:bg-primary-container/20'
              }`}
            >
              Requires Action ({alerts.filter(a => a.status !== 'Resolved').length})
            </button>
            <button
              onClick={() => setActiveFilter('monitoring')}
              className={`px-3.5 py-1.5 rounded-full font-label-md text-xs font-bold whitespace-nowrap transition-colors ${
                activeFilter === 'monitoring'
                  ? 'bg-primary text-on-primary border border-primary'
                  : 'bg-surface-container-low text-primary hover:bg-primary-container/20'
              }`}
            >
              Monitoring ({alerts.filter(a => a.severity === 'Medium' && a.status !== 'Resolved').length})
            </button>
            <button
              onClick={() => setActiveFilter('resolved')}
              className={`px-3.5 py-1.5 rounded-full font-label-md text-xs font-bold whitespace-nowrap transition-colors ${
                activeFilter === 'resolved'
                  ? 'bg-primary text-on-primary border border-primary'
                  : 'bg-surface-container-low text-primary hover:bg-primary-container/20'
              }`}
            >
              Resolved ({alerts.filter(a => a.status === 'Resolved').length})
            </button>
          </div>

          <div className="flex-1 overflow-y-auto p-4 flex flex-col gap-3 max-h-[700px]">
            {filteredAlerts.map((alert) => {
              const isSelected = alert.id === selectedAlertId
              const isCritical = alert.severity === 'Critical'
              return (
                <div
                  key={alert.id}
                  onClick={() => setSelectedAlertId(alert.id)}
                  className={`bg-surface-container-lowest rounded-2xl p-4 shadow-sm transition-all cursor-pointer border-l-4 ${
                    isCritical ? 'border-error' : 'border-secondary'
                  } ${
                    isSelected
                      ? 'ring-2 ring-primary bg-primary-container/5 shadow-md'
                      : 'hover:bg-surface-container-low'
                  }`}
                >
                  <div className="flex justify-between items-start mb-1.5">
                    <div className="flex items-center gap-1.5">
                      <span className={`material-symbols-outlined text-[16px] ${isCritical ? 'text-error' : 'text-secondary'}`}>
                        {isCritical ? 'warning' : 'info'}
                      </span>
                      <span className={`font-label-md text-xs font-bold ${isCritical ? 'text-error' : 'text-secondary'}`}>
                        {alert.severity} Risk ({alert.confidence})
                      </span>
                    </div>
                    <span className="font-label-md text-[11px] text-outline">{alert.timestamp}</span>
                  </div>

                  <h3 className="font-headline-sm text-sm font-bold mb-1 text-on-surface">{alert.type}</h3>
                  <p className="font-body-md text-xs text-on-surface-variant line-clamp-2 leading-relaxed">
                    {alert.summary}
                  </p>

                  <div className="mt-3 flex items-center gap-2">
                    <span className="px-2 py-0.5 bg-surface-container-high rounded-md text-[11px] font-bold text-on-surface-variant flex items-center gap-1">
                      <span className="material-symbols-outlined text-[12px]">sms</span> {alert.channel}
                    </span>
                    <span className="px-2 py-0.5 bg-error-container text-on-error-container rounded-md text-[11px] font-bold flex items-center gap-1">
                      <span className="material-symbols-outlined text-[12px]">person_alert</span> Unverified Sender
                    </span>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Right Pane: Detail Review (Stitch Screen 74 Exact Layout) */}
        <div className="flex-1 p-6 lg:p-8 overflow-y-auto bg-surface-container-lowest">
          <div className="max-w-4xl mx-auto space-y-6">
            {/* Header Actions */}
            <div className="flex items-center justify-between border-b border-surface-container-high pb-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-2xl bg-error-container text-on-error-container flex items-center justify-center">
                  <span className="material-symbols-outlined text-[24px]">priority_high</span>
                </div>
                <div>
                  <h2 className="font-headline-md text-xl font-bold text-on-surface">Investigation #{activeAlert.id || 'INV-8492'}</h2>
                  <p className="font-label-md text-xs text-outline font-semibold">Assigned to SecOps Lead • Opened {activeAlert.timestamp || 'recently'}</p>
                </div>
              </div>
              <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                activeAlert.status === 'Resolved' ? 'bg-primary-container text-on-primary' : 'bg-error-container text-on-error-container'
              }`}>
                {activeAlert.status || 'Active'}
              </span>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Left Column: Context & Evidence (2 cols) */}
              <div className="lg:col-span-2 flex flex-col gap-6">
                {/* Evidence Card: Transcript */}
                <div className="bg-surface rounded-2xl shadow-sm border border-surface-container-high p-5">
                  <h3 className="font-headline-sm text-sm font-bold text-on-surface mb-3 flex items-center gap-2">
                    <span className="material-symbols-outlined text-outline">sms</span> Live Intercepted Transcript
                  </h3>
                  <div className="flex flex-col gap-3 bg-surface-container-low p-4 rounded-xl border border-surface-container-high text-xs">
                    {/* Message 1 */}
                    <div className="flex flex-col items-start gap-1 max-w-[88%]">
                      <span className="font-label-md text-[11px] text-outline ml-2">CBI Officer — Spoofed Landline (+91 11 2309 XXXX) - 10:14 AM</span>
                      <div className="bg-surface-container-highest text-on-surface p-3 rounded-2xl rounded-tl-sm relative border border-error">
                        <p className="font-body-md text-xs leading-relaxed">
                          {activeAlert.seniorName || 'Shanti Patel'} ji, mein CBI DCP Raghav Kumar bol raha hoon. Aapke Aadhaar par money laundering case darz hua hai. Turant ₹3,50,000 RTGS transfer karein warna giraftaari hogi.
                        </p>
                        <div className="absolute -right-2 -top-2 w-5 h-5 bg-error rounded-full flex items-center justify-center text-on-error shadow">
                          <span className="material-symbols-outlined text-[12px]">warning</span>
                        </div>
                      </div>
                    </div>

                    {/* Message 2 */}
                    <div className="flex flex-col items-end gap-1 max-w-[88%] self-end">
                      <span className="font-label-md text-[11px] text-outline mr-2">{activeAlert.seniorName || 'Shanti Patel'} (Protected User) - 10:16 AM</span>
                      <div className="bg-primary text-on-primary p-3 rounded-2xl rounded-tr-sm shadow-sm">
                        <p className="font-body-md text-xs leading-relaxed">
                          Oh no! Is this John? Where do I send it?
                        </p>
                      </div>
                    </div>

                    {/* Message 3 */}
                    <div className="flex flex-col items-start gap-1 max-w-[88%]">
                      <span className="font-label-md text-[11px] text-outline ml-2">CBI Officer — Spoofed Landline (+91 11 2309 XXXX) - 10:17 AM</span>
                      <div className="bg-surface-container-highest text-on-surface p-3 rounded-2xl rounded-tl-sm relative border border-error">
                        <p className="font-body-md text-xs leading-relaxed">
                          Seedha cybercrime.gov.in portal par jaiye aur chalaan bhariye. Aaj raat tak nahi kiya toh warrant execute hoga. Kisi ko mat batana — yeh confidential investigation hai.
                        </p>
                        <div className="absolute -right-2 -top-2 w-5 h-5 bg-error rounded-full flex items-center justify-center text-on-error shadow">
                          <span className="material-symbols-outlined text-[12px]">warning</span>
                        </div>
                      </div>
                    </div>

                    <div className="w-full text-center mt-2">
                      <span className="px-3 py-1 bg-surface-variant text-on-surface-variant rounded-full text-[11px] font-bold inline-flex items-center gap-1">
                        <span className="material-symbols-outlined text-[14px] text-primary">verified_user</span>
                        Conversation quarantined & phone dialer locked by SafeSenior Shield
                      </span>
                    </div>
                  </div>
                </div>

                {/* User Context */}
                <div className="bg-surface rounded-2xl shadow-sm border border-surface-container-high p-5">
                  <h3 className="font-headline-sm text-sm font-bold text-on-surface mb-3 flex items-center gap-2">
                    <span className="material-symbols-outlined text-outline">person</span> Protected Senior Profile
                  </h3>
                  <div className="flex items-center gap-4 mb-4">
                    <img
                      src={protectedUser.avatar}
                      alt={protectedUser.name}
                      className="w-14 h-14 rounded-full object-cover border-2 border-primary"
                    />
                    <div>
                      <p className="font-headline-sm text-base font-bold text-on-surface">{protectedUser.name} ({protectedUser.age})</p>
                      <p className="font-body-md text-xs text-on-surface-variant">Vulnerability Profile: High (Mild Cognitive Impairment flagged)</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="bg-surface-container-low p-3 rounded-xl border border-surface-container-high">
                      <span className="block font-label-md text-xs text-outline font-bold">Recent Alerts</span>
                      <span className="block font-headline-sm text-secondary font-bold text-sm mt-0.5">3 in last 30 days</span>
                    </div>
                    <div className="bg-surface-container-low p-3 rounded-xl border border-surface-container-high">
                      <span className="block font-label-md text-xs text-outline font-bold">Emergency Contact</span>
                      <span className="block font-headline-sm text-primary font-bold text-sm mt-0.5">Amit Patel (Son / Guardian)</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Right Column: AI Analysis & Actions (1 col) */}
              <div className="lg:col-span-1 flex flex-col gap-6">
                {/* AI Score Breakdown */}
                <div className="bg-surface rounded-2xl shadow-sm border border-surface-container-high p-5">
                  <div className="flex items-end gap-2 mb-4">
                    <span className="font-headline-lg text-error text-4xl font-bold leading-none">{activeAlert.confidence || '98%'}</span>
                    <span className="font-label-lg text-outline text-xs mb-1 font-bold">Risk Confidence</span>
                  </div>
                  <div className="space-y-3 text-xs">
                    <div>
                      <div className="flex justify-between font-label-md mb-1 font-bold">
                        <span className="text-on-surface">Urgency Language</span>
                        <span className="text-error">High (95%)</span>
                      </div>
                      <div className="w-full h-2 bg-surface-container-highest rounded-full overflow-hidden">
                        <div className="w-[95%] h-full bg-error rounded-full"></div>
                      </div>
                    </div>
                    <div>
                      <div className="flex justify-between font-label-md mb-1 font-bold">
                        <span className="text-on-surface">Financial Request</span>
                        <span className="text-error">High (90%)</span>
                      </div>
                      <div className="w-full h-2 bg-surface-container-highest rounded-full overflow-hidden">
                        <div className="w-[90%] h-full bg-error rounded-full"></div>
                      </div>
                    </div>
                    <div>
                      <div className="flex justify-between font-label-md mb-1 font-bold">
                        <span className="text-on-surface">Sender Reputation</span>
                        <span className="text-secondary">Suspicious (75%)</span>
                      </div>
                      <div className="w-full h-2 bg-surface-container-highest rounded-full overflow-hidden">
                        <div className="w-[75%] h-full bg-secondary rounded-full"></div>
                      </div>
                    </div>
                  </div>
                  <div className="mt-4 p-3 bg-error-container text-on-error-container rounded-xl font-body-md text-xs leading-relaxed font-semibold">
                    <strong>AI Conclusion:</strong> High probability of "Grandparent/Romance Scam". Immediate intervention recommended to prevent financial loss.
                  </div>
                </div>

                {/* Resolution Actions Panel */}
                <div className="bg-surface rounded-2xl shadow-sm border-t-4 border-primary p-5 flex flex-col gap-3">
                  <h3 className="font-headline-sm text-sm font-bold text-on-surface">Resolution Actions</h3>
                  <button
                    onClick={() => handleAction('Caller +91 11 2309 XXXX Blocked & Reported to cybercrime.gov.in (1930 Portal)', 'Blocked & Quarantined')}
                    className="w-full h-[48px] rounded-xl bg-error text-on-error font-label-md text-xs font-bold flex items-center justify-center gap-2 shadow-sm hover:opacity-90 transition-opacity"
                  >
                    <span className="material-symbols-outlined text-[18px]">block</span>
                    Block & Report Number
                  </button>
                  <button
                    onClick={() => handleAction('Urgent SMS & Push dispatched to Amit Patel (Son / Guardian)', 'Notified Guardian')}
                    className="w-full h-[48px] rounded-xl bg-primary text-on-primary font-label-md text-xs font-bold flex items-center justify-center gap-2 shadow-sm hover:bg-primary-container transition-colors"
                  >
                    <span className="material-symbols-outlined text-[18px]">contact_phone</span>
                    Alert Emergency Contact
                  </button>
                  <button
                    onClick={() => navigate('/crisis-handover')}
                    className="w-full h-[44px] rounded-xl bg-secondary text-on-secondary font-label-md text-xs font-bold flex items-center justify-center gap-2 hover:opacity-90 transition-opacity"
                  >
                    <span className="material-symbols-outlined text-[18px]">support_agent</span>
                    Escalate to Crisis Counselor
                  </button>
                  <div className="h-px w-full bg-surface-variant my-1"></div>
                  <button
                    onClick={() => handleAction(`Investigation #${activeAlert.id} marked as Safe / False Positive`, 'False Positive')}
                    className="w-full h-[40px] rounded-xl bg-surface-container-high text-on-surface font-label-md text-xs font-bold flex items-center justify-center gap-2 hover:bg-surface-container-highest transition-colors"
                  >
                    <span className="material-symbols-outlined text-[16px]">check_circle</span>
                    Mark as Safe (False Positive)
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
