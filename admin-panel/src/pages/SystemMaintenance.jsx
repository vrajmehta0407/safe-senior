import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function SystemMaintenance() {
  const { addAuditLog } = useAdminData()
  const [runningAction, setRunningAction] = useState(null)
  const [actionOutput, setActionOutput] = useState(null)

  const executeAction = (name, detail) => {
    setRunningAction(name)
    setTimeout(() => {
      setRunningAction(null)
      setActionOutput({ name, message: `Completed successfully. ${detail}` })
      addAuditLog(`Maintenance: ${name}`, detail)
    }, 800)
  }

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* ── Header (Stitch Screen 94) ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">System Maintenance & Health</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Routine diagnostics, neural classifier cache flushes, and database index vacuuming.
          </p>
        </div>
      </div>

      {actionOutput && (
        <div className="bg-primary text-on-primary p-4 rounded-2xl flex items-center gap-3 shadow-md text-xs font-bold animate-fade-in">
          <span className="material-symbols-outlined text-[20px]">check_circle</span>
          {actionOutput.message}
        </div>
      )}

      <div className="space-y-4">
        {[
          {
            id: 'flush-cache',
            name: 'Flush Threat Pattern Edge Cache',
            desc: 'Invalidates in-memory classification weights across edge relays to force latest rule download.',
            buttonText: 'Flush Edge Cache',
            detail: 'Purged 1,420 cached signatures from Redis ring.'
          },
          {
            id: 'vacuum-db',
            name: 'PostgreSQL Database Vacuum & Reindex',
            desc: 'Reclaims unallocated disk storage on high-volume scam report audit tables.',
            buttonText: 'Run DB Vacuum',
            detail: 'Vacuum completed on scam_reports and audit_log tables. 42MB reclaimed.'
          },
          {
            id: 'carrier-ping',
            name: 'Carrier Gateway Diagnostics',
            desc: 'Simulates 50 test call intercepts through Twilio/Knox secure relay to benchmark latency.',
            buttonText: 'Run Gateway Benchmark',
            detail: 'Average carrier screening latency measured at 34ms (Target: <50ms).'
          }
        ].map((item) => (
          <div
            key={item.id}
            className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
          >
            <div>
              <h3 className="font-bold text-sm text-on-surface">{item.name}</h3>
              <p className="text-xs text-on-surface-variant mt-0.5">{item.desc}</p>
            </div>
            <button
              onClick={() => executeAction(item.name, item.detail)}
              disabled={runningAction === item.name}
              className="px-5 py-2.5 bg-surface-container-high hover:bg-surface-container-highest rounded-xl text-xs font-bold text-on-surface transition-colors shrink-0 flex items-center gap-2"
            >
              {runningAction === item.name ? (
                <>
                  <span className="material-symbols-outlined text-[16px] animate-spin">refresh</span>
                  Processing...
                </>
              ) : (
                item.buttonText
              )}
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}
