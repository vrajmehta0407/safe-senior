import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  AreaChart,
  Area,
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend
} from 'recharts'

const efficiencyTrendData = Array.from({ length: 30 }, (_, i) => ({
  day: `Day ${i + 1}`,
  detectionRate: 90 + Math.floor((i % 7) * 1.2 + (i % 3) * 0.5),
  falsePositiveRate: Math.max(1.2, Number((4.5 - (i * 0.08) + (i % 4) * 0.4).toFixed(1))),
  alertsTriggered: 35 + (i % 6) * 8
}))

const activeRules = [
  {
    id: 'PTN-001',
    name: 'Wandering Detection (Night)',
    icon: 'night_shelter',
    status: 'Active',
    statusClass: 'bg-primary-container/10 text-primary border-primary/20',
    detectionRate: '98.5%',
    fpRate: '1.2%',
    fpClass: 'text-primary',
    alerts: 342
  },
  {
    id: 'PTN-042',
    name: 'Sudden Fall & Impact Detection',
    icon: 'personal_injury',
    status: 'Active',
    statusClass: 'bg-primary-container/10 text-primary border-primary/20',
    detectionRate: '95.1%',
    fpRate: '8.4%',
    fpClass: 'text-secondary',
    needsTuning: true,
    alerts: 518
  },
  {
    id: 'PTN-012',
    name: 'Exterior Door Opening (Daytime)',
    icon: 'door_open',
    status: 'Paused',
    statusClass: 'bg-surface-variant text-on-surface-variant border-outline/20',
    detectionRate: '--',
    fpRate: '--',
    fpClass: 'text-on-surface-variant',
    alerts: 0
  },
  {
    id: 'PTN-088',
    name: 'Cabinet Access (Anomalous Hours)',
    icon: 'medication',
    status: 'Active',
    statusClass: 'bg-primary-container/10 text-primary border-primary/20',
    detectionRate: '89.0%',
    fpRate: '4.1%',
    fpClass: 'text-on-surface',
    alerts: 112
  }
]

export default function RuleAnalytics() {
  const navigate = useNavigate()
  const [chartType, setChartType] = useState('line') // 'line' | 'bar'
  const [timeRange, setTimeRange] = useState('Last 30 Days')

  return (
    <div className="space-y-8">
      {/* ── Page Header (Stitch Screen 80) ── */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h2 className="font-headline-lg text-headline-lg text-on-surface font-bold">Rule Performance Analytics</h2>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-1">
            Monitoring detection efficiency, false positive rates, and alert accuracy across the edge network.
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setTimeRange(t => t === 'Last 30 Days' ? 'Last 7 Days' : 'Last 30 Days')}
            className="flex items-center gap-2 px-4 py-2 bg-surface-container-low rounded-full border border-outline-variant text-on-surface font-label-md text-sm hover:bg-surface-container-high transition-colors font-bold"
          >
            <span className="material-symbols-outlined text-[18px]">calendar_today</span>
            {timeRange}
            <span className="material-symbols-outlined text-[18px]">arrow_drop_down</span>
          </button>
          <button
            onClick={() => navigate('/patterns')}
            className="flex items-center gap-2 px-4 py-2 bg-surface-container-low rounded-full border border-outline-variant text-on-surface font-label-md text-sm hover:bg-surface-container-high transition-colors font-bold"
          >
            <span className="material-symbols-outlined text-[18px]">filter_list</span>
            Pattern Rules
          </button>
        </div>
      </div>

      {/* ── High-level KPIs (Bento Grid Style) ── */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* KPI 1 */}
        <div className="bg-surface-container-lowest rounded-xl p-6 ambient-shadow flex flex-col gap-4 relative overflow-hidden border border-surface-container-high">
          <div className="absolute -right-6 -top-6 w-32 h-32 bg-primary-container/10 rounded-full blur-2xl pointer-events-none"></div>
          <div className="flex items-center justify-between z-10">
            <span className="font-label-lg text-sm font-bold text-on-surface-variant">Avg. Detection Rate</span>
            <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary">
              <span className="material-symbols-outlined">radar</span>
            </div>
          </div>
          <div className="z-10">
            <div className="flex items-baseline gap-2">
              <span className="font-headline-lg text-4xl text-on-surface font-bold">94.2%</span>
              <span className="text-primary font-label-md text-sm font-bold flex items-center">
                <span className="material-symbols-outlined text-[16px]">trending_up</span> +2.1%
              </span>
            </div>
            <p className="font-body-md text-xs text-outline mt-1 font-semibold">Across all 24 active detection rules</p>
          </div>
        </div>

        {/* KPI 2 */}
        <div className="bg-surface-container-lowest rounded-xl p-6 ambient-shadow flex flex-col gap-4 relative overflow-hidden border border-surface-container-high">
          <div className="absolute -right-6 -top-6 w-32 h-32 bg-secondary-container/10 rounded-full blur-2xl pointer-events-none"></div>
          <div className="flex items-center justify-between z-10">
            <span className="font-label-lg text-sm font-bold text-on-surface-variant">False Positive Rate</span>
            <div className="w-10 h-10 rounded-full bg-secondary-container/20 flex items-center justify-center text-secondary">
              <span className="material-symbols-outlined">warning</span>
            </div>
          </div>
          <div className="z-10">
            <div className="flex items-baseline gap-2">
              <span className="font-headline-lg text-4xl text-on-surface font-bold">3.8%</span>
              <span className="text-secondary font-label-md text-sm font-bold flex items-center">
                <span className="material-symbols-outlined text-[16px]">trending_down</span> -0.5%
              </span>
            </div>
            <p className="font-body-md text-xs text-outline mt-1 font-semibold">Target threshold: &lt; 5.0%</p>
          </div>
        </div>

        {/* KPI 3 */}
        <div className="bg-surface-container-lowest rounded-xl p-6 ambient-shadow flex flex-col gap-4 relative overflow-hidden border border-surface-container-high">
          <div className="absolute -right-6 -top-6 w-32 h-32 bg-tertiary-container/10 rounded-full blur-2xl pointer-events-none"></div>
          <div className="flex items-center justify-between z-10">
            <span className="font-label-lg text-sm font-bold text-on-surface-variant">Total Alerts Triggered</span>
            <div className="w-10 h-10 rounded-full bg-tertiary-container/20 flex items-center justify-center text-tertiary">
              <span className="material-symbols-outlined">notifications_active</span>
            </div>
          </div>
          <div className="z-10">
            <div className="flex items-baseline gap-2">
              <span className="font-headline-lg text-4xl text-on-surface font-bold">1,284</span>
              <span className="text-on-surface-variant font-label-md text-xs font-bold flex items-center">vs last month</span>
            </div>
            <div className="w-full bg-surface-variant h-2 rounded-full mt-3 overflow-hidden">
              <div className="bg-tertiary-container h-full w-[65%] rounded-full"></div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Main Chart Area: Efficiency Trend (Stitch Exact Layout) ── */}
      <div className="bg-surface-container-lowest rounded-xl p-6 ambient-shadow border border-surface-container-high flex flex-col gap-6">
        <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-4">
          <div>
            <h3 className="font-headline-md text-headline-md text-on-surface font-bold">Efficiency Trend (Last 30 Days)</h3>
            <p className="font-body-md text-sm text-on-surface-variant">Comparing Detection Rate (%) vs False Positives (%) over time.</p>
          </div>
          <div className="flex gap-1 bg-surface-container-low p-1 rounded-lg self-start">
            <button
              onClick={() => setChartType('line')}
              className={`px-3 py-1.5 rounded text-xs font-label-md font-bold transition-all ${
                chartType === 'line' ? 'bg-surface shadow-sm text-on-surface' : 'text-on-surface-variant hover:text-on-surface'
              }`}
            >
              Line
            </button>
            <button
              onClick={() => setChartType('bar')}
              className={`px-3 py-1.5 rounded text-xs font-label-md font-bold transition-all ${
                chartType === 'bar' ? 'bg-surface shadow-sm text-on-surface' : 'text-on-surface-variant hover:text-on-surface'
              }`}
            >
              Bar
            </button>
          </div>
        </div>

        <div className="w-full h-[320px]">
          <ResponsiveContainer width="100%" height="100%">
            {chartType === 'line' ? (
              <LineChart data={efficiencyTrendData} margin={{ top: 10, right: 20, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#efeded" />
                <XAxis dataKey="day" stroke="#6e7979" fontSize={11} interval={4} />
                <YAxis yAxisId="left" domain={[80, 100]} stroke="#006565" fontSize={11} />
                <YAxis yAxisId="right" orientation="right" domain={[0, 15]} stroke="#aa361f" fontSize={11} />
                <Tooltip contentStyle={{ background: '#ffffff', borderRadius: 12, border: '1px solid #bdc9c8', fontSize: 12 }} />
                <Legend iconType="circle" wrapperStyle={{ fontSize: 12, paddingTop: 10 }} />
                <Line yAxisId="left" type="monotone" dataKey="detectionRate" name="Detection Rate (%)" stroke="#006565" strokeWidth={2.5} dot={false} />
                <Line yAxisId="right" type="monotone" dataKey="falsePositiveRate" name="False Positive Rate (%)" stroke="#fe7356" strokeWidth={2} strokeDasharray="3 3" dot={false} />
              </LineChart>
            ) : (
              <BarChart data={efficiencyTrendData.slice(-10)} margin={{ top: 10, right: 20, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#efeded" />
                <XAxis dataKey="day" stroke="#6e7979" fontSize={11} />
                <YAxis stroke="#6e7979" fontSize={11} />
                <Tooltip contentStyle={{ background: '#ffffff', borderRadius: 12, border: '1px solid #bdc9c8', fontSize: 12 }} />
                <Legend iconType="circle" wrapperStyle={{ fontSize: 12, paddingTop: 10 }} />
                <Bar dataKey="detectionRate" name="Detection Rate (%)" fill="#006565" radius={[4, 4, 0, 0]} />
                <Bar dataKey="falsePositiveRate" name="False Positive (%)" fill="#fe7356" radius={[4, 4, 0, 0]} />
              </BarChart>
            )}
          </ResponsiveContainer>
        </div>
      </div>

      {/* ── Detailed Rule List (Stitch Exact Layout) ── */}
      <div className="bg-surface-container-lowest rounded-xl ambient-shadow border border-surface-container-high overflow-hidden flex flex-col">
        <div className="p-6 border-b border-surface-container-high flex justify-between items-center bg-surface-bright">
          <h3 className="font-headline-md text-headline-md text-on-surface font-bold text-base">Active Rules Performance</h3>
          <button
            onClick={() => alert('Exporting Rule Telemetry CSV...')}
            className="text-primary hover:underline font-label-md text-xs font-bold flex items-center gap-1 transition-colors"
          >
            Export CSV <span className="material-symbols-outlined text-[16px]">download</span>
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-surface-container-low border-b border-surface-container-high text-xs text-on-surface-variant font-bold">
                <th className="p-4 pl-6 font-label-lg whitespace-nowrap">Rule Name</th>
                <th className="p-4 font-label-lg whitespace-nowrap">Status</th>
                <th className="p-4 font-label-lg whitespace-nowrap text-right">Detection Rate</th>
                <th className="p-4 font-label-lg whitespace-nowrap text-right">False Positive Rate</th>
                <th className="p-4 font-label-lg whitespace-nowrap text-right">Alerts (30d)</th>
                <th className="p-4 font-label-lg whitespace-nowrap text-center">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-surface-container-low font-body-md text-sm text-on-surface">
              {activeRules.map((rule) => (
                <tr key={rule.id} className="hover:bg-surface-container-low transition-colors">
                  <td className="p-4 pl-6">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-primary-container/10 flex items-center justify-center text-primary">
                        <span className="material-symbols-outlined text-[18px]">{rule.icon}</span>
                      </div>
                      <div>
                        <div className="font-label-md font-bold text-on-surface text-sm">{rule.name}</div>
                        <div className="text-xs text-on-surface-variant">ID: {rule.id}</div>
                      </div>
                    </div>
                  </td>
                  <td className="p-4">
                    <span className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-bold border ${rule.statusClass}`}>
                      <span className="w-1.5 h-1.5 rounded-full bg-current"></span> {rule.status}
                    </span>
                  </td>
                  <td className="p-4 text-right font-bold text-sm">{rule.detectionRate}</td>
                  <td className={`p-4 text-right font-bold text-sm ${rule.fpClass}`}>
                    {rule.fpRate}
                    {rule.needsTuning && (
                      <span className="material-symbols-outlined text-secondary text-[14px] align-middle ml-1" title="Needs tuning">
                        warning
                      </span>
                    )}
                  </td>
                  <td className="p-4 text-right font-bold text-sm">{rule.alerts}</td>
                  <td className="p-4 text-center">
                    <button
                      onClick={() => navigate('/rules-sandbox')}
                      className="p-1.5 text-on-surface-variant hover:text-primary transition-colors rounded-lg hover:bg-surface-container-high inline-flex items-center justify-center"
                      title="Calibrate Rule"
                    >
                      <span className="material-symbols-outlined text-[20px]">tune</span>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
