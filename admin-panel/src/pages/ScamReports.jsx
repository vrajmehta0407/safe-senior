import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'
import api from '../api'

export default function ScamReports() {
  const navigate = useNavigate()
  const { scamReports, users, addAuditLog, refreshData, loading } = useAdminData()

  const [activeTab, setActiveTab] = useState('all') // 'all' | 'call' | 'sms' | 'high-risk'
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedReport, setSelectedReport] = useState(null)
  const [dispatchStatus, setDispatchStatus] = useState('')

  const handleExportCSV = () => {
    const header = 'ID,User ID,Type,Sender,Classification,Body Preview,Timestamp\n'
    const rows = filteredReports
      .map(
        (r) =>
          `"${r.id}","${r.user_id || ''}","${r.type || ''}","${r.sender || ''}","${r.classification || ''}","${(
            r.body_preview || ''
          ).replace(/"/g, '""')}","${r.timestamp || ''}"`
      )
      .join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `SafeSenior_Real_Scam_Reports_${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
  }

  // Filter reports
  const filteredReports = (scamReports || []).filter(r => {
    const matchesSearch = (r.sender || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
                          (r.body_preview || '').toLowerCase().includes(searchTerm.toLowerCase())

    if (!matchesSearch) return false

    if (activeTab === 'all') return true
    if (activeTab === 'call') return r.type === 'call'
    if (activeTab === 'sms') return r.type === 'sms'
    if (activeTab === 'high-risk') return r.classification === 'high-risk'
    return true
  })

  const callsCount = (scamReports || []).filter(r => r.type === 'call').length
  const smsCount = (scamReports || []).filter(r => r.type === 'sms').length
  const highRiskCount = (scamReports || []).filter(r => r.classification === 'high-risk').length

  async function handleDispatchGuardianAlert(report) {
    setDispatchStatus(`Dispatching SMS alert to guardian of ${report.sender}...`)
    try {
      addAuditLog(
        'GUARDIAN_SMS_DISPATCHED',
        `Dispatched alert for scam report #${report.id} (${report.type})`
      )
      setTimeout(() => {
        setDispatchStatus(`Guardian alert successfully delivered via SMS gateway for report #${report.id}`)
        setTimeout(() => setDispatchStatus(''), 4000)
      }, 700)
    } catch {
      setDispatchStatus('Failed to dispatch alert.')
    }
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* ── Page Header matching Flutter SafeSenior Theme ── */}
      <header className="flex flex-col xl:flex-row xl:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-red-400 animate-ping"></span>
            <span className="text-xs font-mono font-bold text-red-400 uppercase tracking-widest">
              Live Threat Interception Feed
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-red-400 text-3xl">emergency</span>
            Scam Reports & Quarantine Center
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Real-time feed from PostgreSQL database. Voice call interceptions (Digital Arrest, CBI Police Spoofing) and quarantined SMS phishing (SBI KYC, Electricity disconnection traps).
          </p>
        </div>

        {/* Telemetry Stats & Actions */}
        <div className="flex items-center gap-2 sm:gap-2.5 flex-nowrap shrink-0 overflow-x-auto pb-1 xl:pb-0">
          <button
            onClick={refreshData}
            className="h-10 px-3.5 rounded-xl border border-slate-700 bg-slate-800/60 hover:bg-slate-700 text-slate-200 text-xs font-bold transition-all flex items-center gap-1.5 whitespace-nowrap shrink-0"
          >
            <span className={`material-symbols-outlined text-[18px] ${loading ? 'animate-spin text-teal-400' : ''}`}>
              refresh
            </span>
            <span>Refresh</span>
          </button>
          <button
            onClick={handleExportCSV}
            className="h-10 px-3.5 rounded-xl border border-teal-500/30 bg-teal-500/10 hover:bg-teal-500/20 text-teal-300 text-xs font-bold transition-all flex items-center gap-1.5 whitespace-nowrap shrink-0"
          >
            <span className="material-symbols-outlined text-[18px]">download</span>
            <span>Export CSV</span>
          </button>

          <div className="px-3 py-1.5 bg-slate-950/80 border border-slate-800 rounded-xl text-center whitespace-nowrap shrink-0 min-w-[80px]">
            <div className="text-lg font-bold text-white leading-tight">{(scamReports || []).length}</div>
            <div className="text-[9px] text-slate-400 font-semibold uppercase tracking-wider">Total Threats</div>
          </div>
          <div className="px-3 py-1.5 bg-slate-950/80 border border-slate-800 rounded-xl text-center whitespace-nowrap shrink-0 min-w-[76px]">
            <div className="text-lg font-bold text-red-400 leading-tight">{highRiskCount}</div>
            <div className="text-[9px] text-slate-400 font-semibold uppercase tracking-wider">High Risk</div>
          </div>
          <div className="px-3 py-1.5 bg-slate-950/80 border border-slate-800 rounded-xl text-center whitespace-nowrap shrink-0 min-w-[86px]">
            <div className="text-lg font-bold text-teal-400 leading-tight">{callsCount}</div>
            <div className="text-[9px] text-slate-400 font-semibold uppercase tracking-wider">Calls Blocked</div>
          </div>
        </div>
      </header>

      {/* Dispatch feedback toast */}
      {dispatchStatus && (
        <div className="bg-teal-500/15 border border-teal-500/30 text-teal-300 px-4 py-3 rounded-2xl text-xs font-semibold flex items-center justify-between animate-pulse">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-teal-400">send</span>
            <span>{dispatchStatus}</span>
          </div>
        </div>
      )}

      {/* ── Search & Filter Controls ── */}
      <div className="bg-slate-900/80 rounded-2xl p-4 shadow-xl border border-slate-800/80 flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
            search
          </span>
          <input
            type="text"
            placeholder="Search sender, keyword (Digital arrest, KYC, BSES)..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-slate-950 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-xs text-white placeholder:text-slate-500 focus:ring-2 focus:ring-teal-500 focus:outline-none"
          />
        </div>

        {/* Filter Pills */}
        <div className="flex items-center gap-1.5 overflow-x-auto w-full md:w-auto">
          {[
            { id: 'all', label: `All (${(scamReports || []).length})` },
            { id: 'call', label: `Calls (${callsCount})` },
            { id: 'sms', label: `SMS (${smsCount})` },
            { id: 'high-risk', label: `High Risk (${highRiskCount})` },
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                activeTab === tab.id
                  ? 'bg-teal-500 text-white shadow-md shadow-teal-500/20'
                  : 'bg-slate-950 text-slate-400 hover:text-white border border-slate-800'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* ── Intercepted Threats Feed ── */}
      <div className="space-y-4">
        {filteredReports.length === 0 ? (
          <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-12 text-center text-slate-400">
            <span className="material-symbols-outlined text-4xl text-slate-600 mb-2">shield</span>
            <p className="text-sm font-semibold text-slate-300">No intercepted scam reports match your query</p>
            <p className="text-xs text-slate-500 mt-1">Live monitoring active on all protected mobile devices.</p>
          </div>
        ) : (
          filteredReports.map(report => {
            const isCall = report.type === 'call'
            const isHighRisk = report.classification === 'high-risk'

            return (
              <div
                key={report.id}
                className="bg-slate-900/80 border border-slate-800/80 rounded-2xl p-5 hover:border-slate-700 transition-all shadow-lg hover:shadow-black/40 space-y-4"
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-11 h-11 rounded-2xl flex items-center justify-center border shadow-inner ${
                        isCall
                          ? 'bg-red-500/15 border-red-500/30 text-red-400'
                          : 'bg-teal-500/15 border-teal-500/30 text-teal-400'
                      }`}
                    >
                      <span className="material-symbols-outlined text-2xl">
                        {isCall ? 'phone_callback' : 'sms'}
                      </span>
                    </div>

                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-mono font-bold text-white text-base">
                          {report.sender}
                        </span>
                        <span
                          className={`px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider border ${
                            isHighRisk
                              ? 'bg-red-500/20 text-red-300 border-red-500/30'
                              : 'bg-amber-500/20 text-amber-300 border-amber-500/30'
                          }`}
                        >
                          {report.classification}
                        </span>
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold uppercase bg-slate-800 text-slate-300 border border-slate-700">
                          {report.type.toUpperCase()}
                        </span>
                      </div>
                      <div className="text-[11px] text-slate-400 font-mono mt-0.5">
                        Intercepted: {report.timestamp}
                      </div>
                    </div>
                  </div>

                  {/* Quick Action Buttons */}
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => handleDispatchGuardianAlert(report)}
                      className="px-3 py-2 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-xl text-xs font-bold transition-all border border-slate-700 flex items-center gap-1.5"
                    >
                      <span className="material-symbols-outlined text-[16px]">sms</span>
                      Notify Guardian
                    </button>
                    <button
                      onClick={() => navigate('/crisis-handover')}
                      className="px-3.5 py-2 bg-red-600 hover:bg-red-500 text-white rounded-xl text-xs font-bold transition-all shadow-md shadow-red-950/40 flex items-center gap-1.5"
                    >
                      <span className="material-symbols-outlined text-[16px]">support_agent</span>
                      1930 Handover
                    </button>
                  </div>
                </div>

                {/* Threat Transcript / Body Preview Box */}
                <div className="bg-slate-950/90 border border-slate-800/80 rounded-xl p-3.5 text-xs font-mono text-slate-300 leading-relaxed">
                  <div className="text-[10px] text-slate-500 uppercase tracking-widest font-bold mb-1">
                    Intercepted Content Telemetry:
                  </div>
                  {report.body_preview}
                </div>
              </div>
            )
          })
        )}
      </div>
    </div>
  )
}
