import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend
} from 'recharts'

const scamTrendData = [
  { day: 'Day 1', blocked: 320, variants: 45, falsePos: 4 },
  { day: 'Day 5', blocked: 450, variants: 78, falsePos: 6 },
  { day: 'Day 10', blocked: 380, variants: 60, falsePos: 2 },
  { day: 'Day 15', blocked: 620, variants: 120, falsePos: 8 },
  { day: 'Day 20', blocked: 510, variants: 90, falsePos: 5 },
  { day: 'Day 25', blocked: 740, variants: 140, falsePos: 9 },
  { day: 'Day 30', blocked: 890, variants: 165, falsePos: 7 },
]

const userGrowthData = [
  { month: 'Jan', guardians: 1800, seniors: 1200 },
  { month: 'Feb', guardians: 2400, seniors: 1600 },
  { month: 'Mar', guardians: 3200, seniors: 2200 },
  { month: 'Apr', guardians: 4500, seniors: 3100 },
  { month: 'May', guardians: 5900, seniors: 4200 },
  { month: 'Jun', guardians: 7800, seniors: 5600 },
]

const ageDistribution = [
  { name: '65-74 yrs', value: 45, count: '1.89k', color: '#006565' },
  { name: '75-84 yrs', value: 35, count: '1.47k', color: '#aa361f' },
  { name: '85+ yrs', value: 20, count: '0.84k', color: '#cca830' },
]

const topRegions = [
  { name: 'Maharashtra', users: 4800, percentage: '82%' },
  { name: 'Gujarat', users: 3900, percentage: '68%' },
  { name: 'Delhi NCR', users: 3400, percentage: '58%' },
  { name: 'Karnataka', users: 2950, percentage: '49%' },
  { name: 'Tamil Nadu', users: 2100, percentage: '36%' },
]

export default function SystemAnalytics() {
  const navigate = useNavigate()
  const [activeView, setActiveView] = useState('report') // 'report' | 'growth'
  const [timeRange, setTimeRange] = useState('Last 30 Days')
  const [regionFilter, setRegionFilter] = useState('All Regions')

  return (
    <div className="space-y-8">
      {/* ── View Switcher & Header (Stitch Screen 85 & 86) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-3 mb-2">
            <button
              onClick={() => setActiveView('report')}
              className={`px-4 py-2 rounded-xl text-sm font-label-md font-bold transition-all ${
                activeView === 'report'
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest'
              }`}
            >
              Analytics Report (Screen 85)
            </button>
            <button
              onClick={() => setActiveView('growth')}
              className={`px-4 py-2 rounded-xl text-sm font-label-md font-bold transition-all ${
                activeView === 'growth'
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest'
              }`}
            >
              User Growth & Demographics (Screen 86)
            </button>
          </div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">
            {activeView === 'report' ? 'Analytics Report' : 'User Growth & Demographics'}
          </h1>
          <p className="text-on-surface-variant font-body-lg text-body-lg mt-1">
            {activeView === 'report'
              ? 'Comprehensive overview of system health and threat detection.'
              : 'Cohort acquisition, demographic breakdown, and family network ratio.'}
          </p>
        </div>

        {/* Filters */}
        <div className="flex flex-wrap items-center gap-3">
          <div className="relative">
            <select
              value={timeRange}
              onChange={(e) => setTimeRange(e.target.value)}
              className="appearance-none bg-surface-container-low w-44 h-[44px] px-4 rounded-xl border border-outline-variant text-on-surface font-body-md text-sm focus:ring-2 focus:ring-primary focus:border-primary outline-none pr-10"
            >
              <option>Last 30 Days</option>
              <option>Last 7 Days</option>
              <option>This Month</option>
              <option>Year to Date</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-on-surface-variant text-[18px]">
              calendar_today
            </span>
          </div>

          <div className="relative">
            <select
              value={regionFilter}
              onChange={(e) => setRegionFilter(e.target.value)}
              className="appearance-none bg-surface-container-low w-44 h-[44px] px-4 rounded-xl border border-outline-variant text-on-surface font-body-md text-sm focus:ring-2 focus:ring-primary focus:border-primary outline-none pr-10"
            >
              <option>All Regions</option>
              <option>North America</option>
              <option>Europe</option>
              <option>Asia Pacific</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-on-surface-variant text-[18px]">
              location_on
            </span>
          </div>

          <button
            onClick={() => alert('Exporting Analytics Dossier (PDF)...')}
            className="h-[44px] px-5 bg-primary text-on-primary rounded-xl font-label-md text-sm hover:bg-primary-container transition-colors shadow-sm flex items-center gap-2 font-bold"
          >
            <span className="material-symbols-outlined text-[18px]">picture_as_pdf</span>
            Export PDF
          </button>
        </div>
      </div>

      {activeView === 'report' ? (
        <>
          {/* ── Key Metrics Grid (Screen 85) ── */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Metric 1 */}
            <div className="bg-surface rounded-2xl p-6 shadow-sm border border-surface-container-high relative overflow-hidden">
              <div className="absolute -right-4 -top-4 w-24 h-24 bg-primary/5 rounded-full blur-2xl"></div>
              <div className="flex items-center justify-between mb-4 relative z-10">
                <h3 className="font-label-lg text-label-lg text-on-surface-variant text-sm font-bold">Total Scams Blocked</h3>
                <div className="w-10 h-10 rounded-full bg-primary-container/20 flex items-center justify-center text-primary">
                  <span className="material-symbols-outlined icon-fill">shield</span>
                </div>
              </div>
              <div className="relative z-10">
                <p className="font-headline-lg text-headline-lg text-on-surface font-bold mb-1">12,458</p>
                <p className="text-sm font-label-md text-primary flex items-center gap-1 font-bold">
                  <span className="material-symbols-outlined text-[16px]">trending_up</span> +14% vs last period
                </p>
              </div>
            </div>

            {/* Metric 2 */}
            <div className="bg-surface rounded-2xl p-6 shadow-sm border border-surface-container-high relative overflow-hidden">
              <div className="absolute -right-4 -top-4 w-24 h-24 bg-secondary-container/5 rounded-full blur-2xl"></div>
              <div className="flex items-center justify-between mb-4 relative z-10">
                <h3 className="font-label-lg text-label-lg text-on-surface-variant text-sm font-bold">Active Threats</h3>
                <div className="w-10 h-10 rounded-full bg-error-container/20 flex items-center justify-center text-error">
                  <span className="material-symbols-outlined icon-fill">warning</span>
                </div>
              </div>
              <div className="relative z-10">
                <p className="font-headline-lg text-headline-lg text-on-surface font-bold mb-1">342</p>
                <p className="text-sm font-label-md text-error flex items-center gap-1 font-bold">
                  <span className="material-symbols-outlined text-[16px]">trending_up</span> +5% vs last period
                </p>
              </div>
            </div>

            {/* Metric 3 */}
            <div className="bg-surface rounded-2xl p-6 shadow-sm border border-surface-container-high relative overflow-hidden">
              <div className="absolute -right-4 -top-4 w-24 h-24 bg-tertiary-container/5 rounded-full blur-2xl"></div>
              <div className="flex items-center justify-between mb-4 relative z-10">
                <h3 className="font-label-lg text-label-lg text-on-surface-variant text-sm font-bold">System Uptime</h3>
                <div className="w-10 h-10 rounded-full bg-tertiary-container/20 flex items-center justify-center text-tertiary">
                  <span className="material-symbols-outlined icon-fill">network_check</span>
                </div>
              </div>
              <div className="relative z-10">
                <p className="font-headline-lg text-headline-lg text-on-surface font-bold mb-1">99.98%</p>
                <p className="text-sm font-label-md text-on-surface-variant flex items-center gap-1">
                  <span className="material-symbols-outlined text-[16px]">horizontal_rule</span> No change
                </p>
              </div>
            </div>

            {/* Metric 4 */}
            <div className="bg-surface rounded-2xl p-6 shadow-sm border border-surface-container-high relative overflow-hidden">
              <div className="absolute -right-4 -top-4 w-24 h-24 bg-primary/5 rounded-full blur-2xl"></div>
              <div className="flex items-center justify-between mb-4 relative z-10">
                <h3 className="font-label-lg text-label-lg text-on-surface-variant text-sm font-bold">Protected Users</h3>
                <div className="w-10 h-10 rounded-full bg-primary-container/20 flex items-center justify-center text-primary">
                  <span className="material-symbols-outlined icon-fill">group</span>
                </div>
              </div>
              <div className="relative z-10">
                <p className="font-headline-lg text-headline-lg text-on-surface font-bold mb-1">1.2M</p>
                <p className="text-sm font-label-md text-primary flex items-center gap-1 font-bold">
                  <span className="material-symbols-outlined text-[16px]">trending_up</span> +2% vs last period
                </p>
              </div>
            </div>
          </div>

          {/* ── Chart Section (Bento Grid Style) ── */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Main Graph Card */}
            <div className="lg:col-span-2 bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high">
              <div className="flex justify-between items-center mb-6">
                <div>
                  <h2 className="font-headline-md text-headline-md text-on-surface font-bold">Scam Detection Trends</h2>
                  <p className="text-xs text-on-surface-variant mt-0.5">30-day chronological pattern interception velocity</p>
                </div>
                <button
                  onClick={() => alert('Downloading CSV dataset...')}
                  className="h-9 px-3 rounded-lg bg-surface-container-high hover:bg-surface-container-highest transition-colors text-on-surface-variant text-xs font-label-lg flex items-center gap-1.5 font-bold"
                >
                  <span className="material-symbols-outlined text-[18px]">download</span> CSV
                </button>
              </div>

              {/* Recharts Area + Bar Multi-layer Chart */}
              <div className="w-full h-72">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={scamTrendData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                    <defs>
                      <linearGradient id="scamBlockedGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#006565" stopOpacity={0.7}/>
                        <stop offset="95%" stopColor="#006565" stopOpacity={0.05}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#efeded" />
                    <XAxis dataKey="day" stroke="#6e7979" fontSize={12} />
                    <YAxis stroke="#6e7979" fontSize={12} />
                    <Tooltip contentStyle={{ background: '#ffffff', borderRadius: 12, border: '1px solid #bdc9c8', fontSize: 12 }} />
                    <Area type="monotone" dataKey="blocked" name="Blocked Attempts" stroke="#006565" strokeWidth={2.5} fillOpacity={1} fill="url(#scamBlockedGrad)" />
                    <Line type="monotone" dataKey="variants" name="New Variants" stroke="#ba1a1a" strokeWidth={2} dot={{ r: 4 }} />
                    <Line type="monotone" dataKey="falsePos" name="False Positives" stroke="#cca830" strokeWidth={1.5} strokeDasharray="4 4" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>

              <div className="flex justify-center gap-6 mt-4 text-xs font-label-md text-on-surface-variant font-bold">
                <span className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-primary"></div> Blocked Attempts</span>
                <span className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-error"></div> New Variants</span>
                <span className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-tertiary-container"></div> False Positives</span>
              </div>
            </div>

            {/* AI Insight Side Card (Stitch Exact Layout) */}
            <div className="bg-primary text-on-primary rounded-3xl p-6 shadow-sm flex flex-col justify-between relative overflow-hidden">
              <div className="absolute -right-12 -top-12 w-48 h-48 bg-white/10 rounded-full blur-2xl pointer-events-none"></div>
              <div>
                <div className="w-12 h-12 bg-white/15 rounded-2xl flex items-center justify-center mb-6 text-on-primary">
                  <span className="material-symbols-outlined text-[28px] icon-fill">lightbulb</span>
                </div>
                <h2 className="font-headline-sm text-headline-sm font-bold mb-4 text-white">AI Real-time Intelligence</h2>
                <p className="font-body-md text-body-md opacity-90 leading-relaxed text-[#e3fffe]">
                  There is a sharp surge in "Digital Arrest & CBI Customs" spoof calls targeting retired central govt pensioners across Delhi NCR, Mumbai, and Bengaluru between 11 AM and 4 PM. Telecom carrier screening rules have been tightened.
                </p>
              </div>
              <button
                onClick={() => navigate('/patterns')}
                className="mt-8 w-full bg-white text-primary h-[48px] rounded-xl font-label-md font-bold hover:bg-[#e3fffe] transition-colors shadow-sm"
              >
                Review Threat Patterns
              </button>
            </div>
          </div>

          {/* ── Table Section: Top 5 Active Scam Patterns ── */}
          <div className="bg-surface rounded-3xl shadow-sm border border-surface-container-high overflow-hidden">
            <div className="p-6 border-b border-surface-container-low flex justify-between items-center">
              <div>
                <h2 className="font-headline-md text-headline-md text-on-surface font-bold">Top 5 Active Indian Scam Patterns</h2>
                <p className="text-xs font-body-md text-on-surface-variant mt-1">Based on frequency and severity across monitored Indian telecom networks.</p>
              </div>
              <button
                onClick={() => navigate('/patterns')}
                className="h-10 px-4 rounded-xl bg-surface-container hover:bg-surface-container-high transition-colors text-primary text-xs font-label-md font-bold flex items-center gap-1"
              >
                Full Taxonomy <span className="material-symbols-outlined text-[16px]">arrow_forward</span>
              </button>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-surface-container-low text-on-surface-variant font-label-lg text-xs border-b border-surface-container">
                    <th className="p-4 pl-6 font-semibold w-1/3">Pattern Name</th>
                    <th className="p-4 font-semibold">Severity</th>
                    <th className="p-4 font-semibold">Incidents (30d)</th>
                    <th className="p-4 font-semibold">Trend</th>
                    <th className="p-4 pr-6 font-semibold text-right">Action</th>
                  </tr>
                </thead>
                <tbody className="font-body-md text-on-surface text-sm divide-y divide-surface-container-low">
                  <tr className="hover:bg-surface-container-lowest transition-colors">
                    <td className="p-4 pl-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-error-container/30 flex items-center justify-center text-error">
                          <span className="material-symbols-outlined text-[20px]">local_police</span>
                        </div>
                        <div>
                          <span className="font-bold block">Digital Arrest (CBI / Customs)</span>
                          <span className="text-xs text-on-surface-variant">WhatsApp Video / Police Uniform</span>
                        </div>
                      </div>
                    </td>
                    <td className="p-4">
                      <span className="px-3 py-1 bg-error-container text-on-error-container rounded-full text-xs font-bold font-label-md">
                        CRITICAL
                      </span>
                    </td>
                    <td className="p-4 font-semibold">4,521</td>
                    <td className="p-4">
                      <div className="flex items-center gap-1 text-error font-bold text-xs">
                        <span className="material-symbols-outlined text-[16px]">trending_up</span> +28%
                      </div>
                    </td>
                    <td className="p-4 pr-6 text-right">
                      <button onClick={() => navigate('/rules-sandbox')} className="text-primary hover:underline font-bold text-sm">
                        Analyze
                      </button>
                    </td>
                  </tr>

                  <tr className="hover:bg-surface-container-lowest transition-colors">
                    <td className="p-4 pl-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-tertiary-container/30 flex items-center justify-center text-tertiary">
                          <span className="material-symbols-outlined text-[20px]">bolt</span>
                        </div>
                        <div>
                          <span className="font-bold block">Electricity Power Cut SMS</span>
                          <span className="text-xs text-on-surface-variant">MSEDCL / BSES / Malicious APK</span>
                        </div>
                      </div>
                    </td>
                    <td className="p-4">
                      <span className="px-3 py-1 bg-tertiary-container text-on-tertiary-container rounded-full text-xs font-bold font-label-md">
                        HIGH
                      </span>
                    </td>
                    <td className="p-4 font-semibold">3,890</td>
                    <td className="p-4">
                      <div className="flex items-center gap-1 text-error font-bold text-xs">
                        <span className="material-symbols-outlined text-[16px]">trending_up</span> +14%
                      </div>
                    </td>
                    <td className="p-4 pr-6 text-right">
                      <button onClick={() => navigate('/rules-sandbox')} className="text-primary hover:underline font-bold text-sm">
                        Analyze
                      </button>
                    </td>
                  </tr>

                  <tr className="hover:bg-surface-container-lowest transition-colors">
                    <td className="p-4 pl-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-primary-container/20 flex items-center justify-center text-primary">
                          <span className="material-symbols-outlined text-[20px]">account_balance</span>
                        </div>
                        <div>
                          <span className="font-bold block">SBI / HDFC YONO KYC Block</span>
                          <span className="text-xs text-on-surface-variant">PAN Verification Phishing</span>
                        </div>
                      </div>
                    </td>
                    <td className="p-4">
                      <span className="px-3 py-1 bg-surface-container-high text-on-surface rounded-full text-xs font-bold font-label-md">
                        MEDIUM
                      </span>
                    </td>
                    <td className="p-4 font-semibold">2,105</td>
                    <td className="p-4">
                      <div className="flex items-center gap-1 text-primary font-bold text-xs">
                        <span className="material-symbols-outlined text-[16px]">trending_down</span> -6%
                      </div>
                    </td>
                    <td className="p-4 pr-6 text-right">
                      <button onClick={() => navigate('/rules-sandbox')} className="text-primary hover:underline font-bold text-sm">
                        Analyze
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </>
      ) : (
        <>
          {/* ── User Growth & Demographics View (Screen 86) ── */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-surface-container-lowest rounded-xl p-6 shadow-sm border border-surface-container-high flex flex-col relative overflow-hidden">
              <div className="absolute top-0 right-0 w-24 h-24 bg-primary-container/10 rounded-bl-full -z-10"></div>
              <div className="flex items-center justify-between mb-4">
                <span className="font-label-lg text-sm font-bold text-on-surface-variant">Total Active Users</span>
                <span className="material-symbols-outlined text-primary bg-primary-container/20 p-2 rounded-full">group</span>
              </div>
              <div className="flex items-baseline gap-2">
                <h3 className="font-headline-lg text-headline-lg text-on-background font-bold">14,285</h3>
                <span className="font-label-md text-xs font-bold text-primary flex items-center">
                  <span className="material-symbols-outlined text-[16px]">trending_up</span> +12%
                </span>
              </div>
            </div>

            <div className="bg-surface-container-lowest rounded-xl p-6 shadow-sm border border-surface-container-high flex flex-col relative overflow-hidden">
              <div className="absolute top-0 right-0 w-24 h-24 bg-secondary-container/10 rounded-bl-full -z-10"></div>
              <div className="flex items-center justify-between mb-4">
                <span className="font-label-lg text-sm font-bold text-on-surface-variant">New Seniors</span>
                <span className="material-symbols-outlined text-secondary bg-secondary-container/20 p-2 rounded-full">elderly</span>
              </div>
              <div className="flex items-baseline gap-2">
                <h3 className="font-headline-lg text-headline-lg text-on-background font-bold">842</h3>
                <span className="font-label-md text-xs font-bold text-primary flex items-center">
                  <span className="material-symbols-outlined text-[16px]">trending_up</span> +5%
                </span>
              </div>
            </div>

            <div className="bg-surface-container-lowest rounded-xl p-6 shadow-sm border border-surface-container-high flex flex-col relative overflow-hidden">
              <div className="absolute top-0 right-0 w-24 h-24 bg-tertiary-container/10 rounded-bl-full -z-10"></div>
              <div className="flex items-center justify-between mb-4">
                <span className="font-label-lg text-sm font-bold text-on-surface-variant">Guardian Ratio</span>
                <span className="material-symbols-outlined text-tertiary bg-tertiary-container/20 p-2 rounded-full">family_restroom</span>
              </div>
              <div className="flex items-baseline gap-2">
                <h3 className="font-headline-lg text-headline-lg text-on-background font-bold">1 : 2.4</h3>
                <span className="font-label-md text-xs text-outline-variant flex items-center">
                  <span className="material-symbols-outlined text-[16px]">trending_flat</span> 0%
                </span>
              </div>
            </div>
          </div>

          {/* Charts Bento Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Active Users Trend Line Chart */}
            <div className="lg:col-span-2 bg-surface-container-lowest rounded-xl p-6 shadow-sm border border-surface-container-high">
              <div className="flex justify-between items-center mb-6">
                <div>
                  <h3 className="font-headline-sm text-headline-sm text-on-background font-bold">Active Users Trend</h3>
                  <p className="text-xs text-on-surface-variant mt-0.5">Monthly trajectory of Guardians vs Protected Seniors</p>
                </div>
                <div className="flex items-center gap-4 text-xs font-bold">
                  <div className="flex items-center gap-2">
                    <span className="w-3 h-3 rounded-full bg-primary"></span>
                    <span className="text-on-surface-variant">Guardians</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="w-3 h-3 rounded-full bg-secondary"></span>
                    <span className="text-on-surface-variant">Seniors</span>
                  </div>
                </div>
              </div>

              <div className="w-full h-[280px]">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={userGrowthData} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                    <defs>
                      <linearGradient id="guardiansGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#006565" stopOpacity={0.6}/>
                        <stop offset="95%" stopColor="#006565" stopOpacity={0.02}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#efeded" />
                    <XAxis dataKey="month" stroke="#6e7979" fontSize={12} />
                    <YAxis stroke="#6e7979" fontSize={12} />
                    <Tooltip contentStyle={{ background: '#ffffff', borderRadius: 12, border: '1px solid #bdc9c8', fontSize: 12 }} />
                    <Area type="monotone" dataKey="guardians" name="Family Guardians" stroke="#006565" strokeWidth={2.5} fillOpacity={1} fill="url(#guardiansGrad)" />
                    <Line type="monotone" dataKey="seniors" name="Protected Seniors" stroke="#aa361f" strokeWidth={2.5} strokeDasharray="4 4" dot={{ r: 4 }} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Senior Age Distribution Donut Chart */}
            <div className="bg-surface-container-lowest rounded-xl p-6 shadow-sm border border-surface-container-high flex flex-col">
              <h3 className="font-headline-sm text-headline-sm text-on-background font-bold mb-4">Senior Age Distribution</h3>
              <div className="flex-1 flex flex-col items-center justify-center relative">
                <div style={{ width: '100%', height: 200 }}>
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={ageDistribution}
                        cx="50%"
                        cy="50%"
                        innerRadius={55}
                        outerRadius={80}
                        paddingAngle={5}
                        dataKey="value"
                      >
                        {ageDistribution.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip contentStyle={{ background: '#ffffff', borderRadius: 12, border: '1px solid #bdc9c8', fontSize: 12 }} />
                    </PieChart>
                  </ResponsiveContainer>
                </div>

                <div className="w-full space-y-2 mt-4 text-xs font-bold">
                  {ageDistribution.map((item, idx) => (
                    <div key={idx} className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full" style={{ background: item.color }}></span>
                        <span className="text-on-surface">{item.name}</span>
                      </div>
                      <span className="text-on-background">{item.value}% ({item.count})</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Geographical Demographics List */}
            <div className="lg:col-span-3 bg-surface-container-lowest rounded-xl p-6 shadow-sm border border-surface-container-high">
              <div className="flex justify-between items-center mb-6">
                <div>
                  <h3 className="font-headline-sm text-headline-sm text-on-background font-bold">Top Regions by Adoption</h3>
                  <p className="text-xs text-on-surface-variant mt-0.5">High-density senior jurisdictions</p>
                </div>
                <button onClick={() => navigate('/heatmap')} className="text-primary font-label-md text-xs font-bold hover:underline">
                  View Heatmap
                </button>
              </div>
              <div className="space-y-4">
                {topRegions.map((r, idx) => (
                  <div key={idx} className="flex items-center gap-4">
                    <span className="font-label-lg text-sm font-bold w-32 text-on-surface">{r.name}</span>
                    <div className="flex-1 bg-surface-container-highest h-3.5 rounded-full overflow-hidden">
                      <div className="bg-primary h-full rounded-full" style={{ width: r.percentage }}></div>
                    </div>
                    <span className="font-label-md text-xs font-bold w-20 text-right text-on-surface-variant">{r.users.toLocaleString()} users</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
