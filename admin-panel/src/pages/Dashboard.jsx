import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { mockAlerts, mockStats } from '../mockData'

const latencySamples = [
  { time: '12 AM', ms: 45, height: '40%' },
  { time: '3 AM', ms: 38, height: '35%' },
  { time: '6 AM', ms: 62, height: '60%' },
  { time: '9 AM', ms: 48, height: '45%' },
  { time: '12 PM', ms: 85, height: '80%' },
  { time: '3 PM', ms: 32, height: '30%' },
  { time: 'Now', ms: 28, height: '25%', active: true },
]

export default function Dashboard() {
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState('overview')

  return (
    <div className="space-y-8">
      {/* ── Page Header ── */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="font-headline-lg text-headline-lg text-on-background mb-1">
            System Health Overview
          </h2>
          <p className="font-body-lg text-body-lg text-on-surface-variant">
            Real-time monitoring, live latency telemetry, and threat prevention metrics.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/rules-wizard')}
            className="h-[44px] px-5 bg-primary text-on-primary rounded-xl font-label-md flex items-center gap-2 hover:bg-primary-container transition-colors shadow-sm"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            New System Rule
          </button>
        </div>
      </header>

      {/* ── Masonry Grid of Metric Cards (Stitch Exact Layout) ── */}
      <div className="masonry-grid">
        {/* Metric Card 1: System Status */}
        <div className="masonry-item bg-surface-container-lowest rounded-xl p-6 soft-shadow flex flex-col items-start relative overflow-hidden border border-surface-container-high">
          <div className="absolute top-0 right-0 w-32 h-32 bg-primary-fixed/20 rounded-bl-full -mr-16 -mt-16 pointer-events-none"></div>
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center">
              <span className="material-symbols-outlined icon-fill">check_circle</span>
            </div>
            <h3 className="font-headline-sm text-headline-sm text-on-surface">System Status</h3>
          </div>
          <div className="mb-2">
            <span className="font-headline-lg text-headline-lg text-primary font-bold">Operational</span>
          </div>
          <p className="font-body-md text-body-md text-on-surface-variant">
            All core services and edge classifiers are running normally with 0% degraded performance.
          </p>
        </div>

        {/* Metric Card 2: Threats Blocked */}
        <div className="masonry-item bg-surface-container-lowest rounded-xl p-6 soft-shadow flex flex-col items-start relative overflow-hidden border border-surface-container-high">
          <div className="absolute top-0 right-0 w-32 h-32 bg-error-container/30 rounded-bl-full -mr-16 -mt-16 pointer-events-none"></div>
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 rounded-full bg-error-container text-on-error-container flex items-center justify-center">
              <span className="material-symbols-outlined icon-fill">shield</span>
            </div>
            <h3 className="font-headline-sm text-headline-sm text-on-surface">Total Threats Blocked</h3>
          </div>
          <div className="mb-2 flex items-baseline gap-2">
            <span className="font-headline-lg text-headline-lg text-on-surface font-bold">1,248</span>
            <span className="font-label-md text-label-md text-secondary font-bold">+12% this week</span>
          </div>
          <div className="w-full h-2 bg-surface-variant rounded-full mt-2 overflow-hidden">
            <div className="h-full bg-secondary w-[75%] rounded-full"></div>
          </div>
          <p className="font-body-md text-body-md text-on-surface-variant mt-4">
            Phishing attempts and suspicious VoIP endpoints successfully intercepted in the last 24 hours.
          </p>
        </div>

        {/* Metric Card 3: Active Sessions */}
        <div className="masonry-item bg-surface-container-lowest rounded-xl p-6 soft-shadow flex flex-col items-start relative overflow-hidden border border-surface-container-high">
          <div className="absolute top-0 right-0 w-32 h-32 bg-tertiary-fixed/30 rounded-bl-full -mr-16 -mt-16 pointer-events-none"></div>
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 rounded-full bg-tertiary-container text-on-tertiary-container flex items-center justify-center">
              <span className="material-symbols-outlined icon-fill">verified_user</span>
            </div>
            <h3 className="font-headline-sm text-headline-sm text-on-surface">Active Protection</h3>
          </div>
          <div className="mb-2">
            <span className="font-headline-lg text-headline-lg text-on-surface font-bold">45,920</span>
          </div>
          <p className="font-body-md text-body-md text-on-surface-variant">
            Active user sessions currently monitored under safe browsing and call screening protocols.
          </p>
        </div>

        {/* Chart Widget: System Latency (ms) */}
        <div className="masonry-item bg-surface-container-lowest rounded-xl p-6 soft-shadow border border-surface-container-high">
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-headline-sm text-headline-sm text-on-surface">System Latency (ms)</h3>
            <span className="material-symbols-outlined text-outline">speed</span>
          </div>
          <div className="h-48 w-full flex items-end justify-between gap-2 pb-2 border-b border-surface-variant">
            {latencySamples.map((sample, idx) => (
              <div
                key={idx}
                className={`w-full ${sample.active ? 'bg-primary' : 'bg-primary-fixed-dim/60'} rounded-t-sm hover:bg-primary transition-colors cursor-pointer relative group`}
                style={{ height: sample.height }}
              >
                <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-inverse-surface text-inverse-on-surface text-xs py-1 px-2 rounded opacity-0 group-hover:opacity-100 transition-opacity z-20 pointer-events-none whitespace-nowrap">
                  {sample.ms}ms
                </div>
              </div>
            ))}
          </div>
          <div className="flex justify-between mt-2 font-label-md text-label-md text-outline text-xs">
            <span>12AM</span>
            <span>6AM</span>
            <span>12PM</span>
            <span>Now (28ms)</span>
          </div>
        </div>

        {/* Recent Critical Alerts Table Widget */}
        <div className="masonry-item bg-surface-container-lowest rounded-xl soft-shadow overflow-hidden border border-surface-container-high md:col-span-2 lg:col-span-2">
          <div className="p-6 border-b border-surface-variant flex justify-between items-center bg-surface-bright">
            <div>
              <h3 className="font-headline-sm text-headline-sm text-on-surface">Recent Critical Alerts</h3>
              <p className="text-xs text-on-surface-variant mt-0.5">Live interception feed across all senior devices</p>
            </div>
            <button
              onClick={() => navigate('/alerts')}
              className="font-label-md text-label-md text-primary hover:text-surface-tint transition-colors flex items-center gap-1 text-sm font-bold"
            >
              View All <span className="material-symbols-outlined text-[16px]">arrow_forward</span>
            </button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-surface text-outline font-label-md text-label-md border-b border-surface-variant text-xs">
                  <th className="p-4 font-semibold">Time</th>
                  <th className="p-4 font-semibold">Alert Type</th>
                  <th className="p-4 font-semibold">Senior & Group</th>
                  <th className="p-4 font-semibold">Status</th>
                  <th className="p-4 font-semibold text-right">Action</th>
                </tr>
              </thead>
              <tbody className="font-body-md text-body-md text-on-surface text-sm divide-y divide-surface-container-low">
                <tr className="hover:bg-surface-container-low transition-colors">
                  <td className="p-4 text-on-surface-variant">10:42 AM</td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-error text-[18px]">warning</span>
                      <span className="font-semibold">Suspicious Login Location</span>
                    </div>
                  </td>
                  <td className="p-4">Martha Jenkins (Beta Testers)</td>
                  <td className="p-4">
                    <span className="inline-flex items-center px-2.5 py-1 rounded-full bg-error-container text-on-error-container text-xs font-bold font-label-md">
                      Investigating
                    </span>
                  </td>
                  <td className="p-4 text-right">
                    <button
                      onClick={() => navigate('/alerts')}
                      className="text-primary hover:underline font-bold text-sm"
                    >
                      Review
                    </button>
                  </td>
                </tr>

                <tr className="hover:bg-surface-container-low transition-colors">
                  <td className="p-4 text-on-surface-variant">09:15 AM</td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-secondary text-[18px]">phishing</span>
                      <span className="font-semibold">Pattern Match: Phishing SMS</span>
                    </div>
                  </td>
                  <td className="p-4">Robert Chen (General Access)</td>
                  <td className="p-4">
                    <span className="inline-flex items-center px-2.5 py-1 rounded-full bg-surface-variant text-on-surface-variant text-xs font-bold font-label-md">
                      Auto-Blocked
                    </span>
                  </td>
                  <td className="p-4 text-right">
                    <button
                      onClick={() => navigate('/alerts')}
                      className="text-primary hover:underline font-bold text-sm"
                    >
                      Details
                    </button>
                  </td>
                </tr>

                <tr className="hover:bg-surface-container-low transition-colors">
                  <td className="p-4 text-on-surface-variant">Yesterday</td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-tertiary text-[18px]">data_usage</span>
                      <span className="font-semibold">Unusual Data Spike (Wire App)</span>
                    </div>
                  </td>
                  <td className="p-4">Dorothy Miller (Caregivers)</td>
                  <td className="p-4">
                    <span className="inline-flex items-center px-2.5 py-1 rounded-full bg-primary-container/20 text-primary text-xs font-bold font-label-md">
                      Resolved
                    </span>
                  </td>
                  <td className="p-4 text-right">
                    <button
                      onClick={() => navigate('/audit-log')}
                      className="text-primary hover:underline font-bold text-sm"
                    >
                      Log
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
