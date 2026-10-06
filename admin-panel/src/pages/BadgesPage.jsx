import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export const flutterDefenseBadges = [
  {
    id: 'phishing_sentinel',
    title: 'Phishing Sentinel (Level 2)',
    description: '10+ spoofed bank SMS and malicious links inspected and avoided without clicking.',
    category: 'SMS & Web Defense',
    icon: 'shield',
    primaryColor: '#006565',
    bgTint: 'rgba(0, 101, 101, 0.15)',
    targetProgress: 10,
    unlockedCount: 8,
    totalSeniors: 10,
  },
  {
    id: 'spam_neutralizer',
    title: 'Spam Neutralizer (Level 3)',
    description: '15+ scam robocalls, spoofed police numbers and fake CBI calls screened and auto-blocked.',
    category: 'Call Protection',
    icon: 'phone_callback',
    primaryColor: '#FE7356',
    bgTint: 'rgba(254, 115, 86, 0.15)',
    targetProgress: 15,
    unlockedCount: 7,
    totalSeniors: 10,
  },
  {
    id: 'quiz_champion',
    title: 'Quiz Champion (Level 1)',
    description: 'Achieved 100% accuracy on interactive senior fraud scenario drills in the Quiz Hub.',
    category: 'Knowledge',
    icon: 'school',
    primaryColor: '#CCA830',
    bgTint: 'rgba(204, 168, 48, 0.15)',
    targetProgress: 5,
    unlockedCount: 9,
    totalSeniors: 10,
  },
  {
    id: 'family_protector',
    title: 'Family Protector (Level 1)',
    description: 'Primary guardian linked, emergency contacts verified, and 1-tap SOS connection established.',
    category: 'Family Care',
    icon: 'people',
    primaryColor: '#006565',
    bgTint: 'rgba(0, 101, 101, 0.15)',
    targetProgress: 1,
    unlockedCount: 10,
    totalSeniors: 10,
  },
  {
    id: 'shield_bearer',
    title: 'Shield Bearer',
    description: 'Maintained continuous 24/7 AI background protection for over 14 consecutive days.',
    category: 'Protection',
    icon: 'verified_user',
    primaryColor: '#006565',
    bgTint: 'rgba(0, 101, 101, 0.15)',
    targetProgress: 14,
    unlockedCount: 8,
    totalSeniors: 10,
  },
  {
    id: 'voice_shield',
    title: 'Voice Shield',
    description: 'Enabled microphone scanning, voice alerts, and verified AI deepfake voice protection.',
    category: 'AI Defense',
    icon: 'record_voice_over',
    primaryColor: '#735C00',
    bgTint: 'rgba(204, 168, 48, 0.15)',
    targetProgress: 1,
    unlockedCount: 6,
    totalSeniors: 10,
  },
  {
    id: 'zero_leak',
    title: 'Zero Leak Master',
    description: 'Kept OTP credentials secure for 30 consecutive days without any unauthorized exposure.',
    category: 'Privacy',
    icon: 'lock',
    primaryColor: '#006565',
    bgTint: 'rgba(0, 101, 101, 0.15)',
    targetProgress: 30,
    unlockedCount: 5,
    totalSeniors: 10,
  },
  {
    id: 'cyber_scholar',
    title: 'Cyber Scholar',
    description: 'Complete 5 comprehensive interactive fraud scenario drills to master cyber safety.',
    category: 'Knowledge',
    icon: 'psychology',
    primaryColor: '#735C00',
    bgTint: 'rgba(204, 168, 48, 0.15)',
    targetProgress: 5,
    unlockedCount: 4,
    totalSeniors: 10,
  },
  {
    id: 'safe_surfer',
    title: 'Safe Surfer',
    description: 'Inspect and verify 20+ URLs without visiting any blacklisted or fraudulent domains.',
    category: 'Threat Radar',
    icon: 'language',
    primaryColor: '#006565',
    bgTint: 'rgba(0, 101, 101, 0.15)',
    targetProgress: 20,
    unlockedCount: 6,
    totalSeniors: 10,
  },
  {
    id: 'emergency_ready',
    title: 'Emergency Ready',
    description: 'Configure emergency contacts, blood group, medical notes, and speed dials in emergency profile.',
    category: 'Emergency',
    icon: 'emergency',
    primaryColor: '#AA361F',
    bgTint: 'rgba(170, 54, 31, 0.15)',
    targetProgress: 3,
    unlockedCount: 7,
    totalSeniors: 10,
  },
  {
    id: 'app_armor',
    title: 'App Armor',
    description: 'Complete device security audit and ensure camera, microphone, and SMS permissions are secured.',
    category: 'Device Security',
    icon: 'security',
    primaryColor: '#006565',
    bgTint: 'rgba(0, 101, 101, 0.15)',
    targetProgress: 4,
    unlockedCount: 9,
    totalSeniors: 10,
  },
  {
    id: 'century_sentinel',
    title: 'Century Sentinel',
    description: 'Maintain uninterrupted senior cyber protection and threat monitoring for 100 consecutive days.',
    category: 'Milestone',
    icon: 'emoji_events',
    primaryColor: '#CCA830',
    bgTint: 'rgba(204, 168, 48, 0.15)',
    targetProgress: 100,
    unlockedCount: 3,
    totalSeniors: 10,
  },
]

export default function BadgesPage() {
  const { users } = useAdminData()
  const totalUsersCount = (users && users.length) ? users.length : 10
  const [filterCategory, setFilterCategory] = useState('All')

  const categories = ['All', 'SMS & Web Defense', 'Call Protection', 'Knowledge', 'Family Care', 'Protection', 'AI Defense', 'Privacy', 'Threat Radar', 'Emergency', 'Device Security', 'Milestone']

  const filteredBadges = filterCategory === 'All'
    ? flutterDefenseBadges
    : flutterDefenseBadges.filter(b => b.category === filterCategory)

  const totalBadgesEarned = flutterDefenseBadges.reduce((acc, b) => acc + b.unlockedCount, 0)
  const averageBadgesPerSenior = (totalBadgesEarned / totalUsersCount).toFixed(1)

  return (
    <div className="space-y-8 animate-fadeIn">
      {/* Header with Flutter Theme Styling */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-teal-400 animate-pulse"></span>
            <span className="text-xs font-mono font-bold text-teal-400 uppercase tracking-widest">
              SafeSenior Mobile Synchronized
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">military_tech</span>
            12 Elder Defense Badges Engine
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Real-time cohort gamification telemetry mapped 1:1 with the Flutter mobile app. Tracks senior defense readiness, quiz completions, and active fraud shield milestones.
          </p>
        </div>

        {/* Telemetry Stats */}
        <div className="flex items-center gap-3">
          <div className="px-4 py-2.5 bg-slate-950/80 border border-slate-800 rounded-2xl text-center">
            <div className="text-xl font-bold text-teal-300">{flutterDefenseBadges.length}</div>
            <div className="text-[10px] text-slate-400 font-semibold uppercase">Total Badges</div>
          </div>
          <div className="px-4 py-2.5 bg-slate-950/80 border border-slate-800 rounded-2xl text-center">
            <div className="text-xl font-bold text-amber-400">{averageBadgesPerSenior}</div>
            <div className="text-[10px] text-slate-400 font-semibold uppercase">Avg / Senior</div>
          </div>
          <div className="px-4 py-2.5 bg-slate-950/80 border border-slate-800 rounded-2xl text-center">
            <div className="text-xl font-bold text-emerald-400">{totalBadgesEarned}</div>
            <div className="text-[10px] text-slate-400 font-semibold uppercase">Total Unlocked</div>
          </div>
        </div>
      </header>

      {/* Category Filter Chips */}
      <div className="flex items-center gap-2 overflow-x-auto pb-2 custom-scrollbar">
        {categories.map(cat => (
          <button
            key={cat}
            onClick={() => setFilterCategory(cat)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition-all ${
              filterCategory === cat
                ? 'bg-teal-500 text-white shadow-md shadow-teal-500/20'
                : 'bg-slate-900/60 text-slate-400 hover:text-white border border-slate-800 hover:border-slate-700'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Badges Grid (Same visual hierarchy as Flutter AchievementsScreen) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filteredBadges.map((badge, idx) => {
          const unlockRate = Math.round((badge.unlockedCount / totalUsersCount) * 100)

          return (
            <div
              key={badge.id}
              className="bg-slate-900/70 border border-slate-800/80 rounded-2xl p-5 hover:border-teal-500/40 transition-all hover:shadow-xl hover:shadow-teal-950/20 relative overflow-hidden group"
            >
              <div className="flex items-start justify-between gap-3 mb-3">
                <div
                  className="w-12 h-12 rounded-2xl flex items-center justify-center border shadow-inner transition-transform group-hover:scale-105"
                  style={{
                    backgroundColor: badge.bgTint,
                    borderColor: badge.primaryColor,
                    color: badge.primaryColor
                  }}
                >
                  <span className="material-symbols-outlined text-2xl icon-fill">
                    {badge.icon}
                  </span>
                </div>
                <div className="text-right">
                  <span className="text-[11px] font-mono px-2 py-0.5 rounded-full bg-slate-800/80 text-teal-300 font-bold border border-slate-700/60">
                    {badge.category}
                  </span>
                  <div className="text-[10px] text-slate-500 mt-1 font-mono">
                    Badge #{idx + 1}
                  </div>
                </div>
              </div>

              <h3 className="font-bold text-white text-base leading-snug mb-1">
                {badge.title}
              </h3>
              <p className="text-xs text-slate-400 leading-relaxed mb-4 min-h-[38px]">
                {badge.description}
              </p>

              {/* Progress Bar & Cohort Telemetry */}
              <div className="space-y-1.5 pt-3 border-t border-slate-800/80">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-slate-400 font-medium">Network Adoption</span>
                  <span className="font-bold font-mono text-teal-400">
                    {badge.unlockedCount} / {totalUsersCount} Seniors ({unlockRate}%)
                  </span>
                </div>
                <div className="w-full h-2 rounded-full bg-slate-800 overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all duration-500"
                    style={{
                      width: `${unlockRate}%`,
                      backgroundColor: badge.primaryColor
                    }}
                  />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Gamification Synchronization Banner */}
      <div className="p-6 rounded-3xl bg-gradient-to-r from-teal-950/40 via-slate-900 to-slate-900 border border-teal-500/30 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 rounded-2xl bg-teal-500/20 text-teal-400 flex items-center justify-center border border-teal-500/30">
            <span className="material-symbols-outlined text-2xl">sync</span>
          </div>
          <div>
            <h4 className="font-bold text-white text-base">Mobile App Sync Active</h4>
            <p className="text-xs text-slate-400 mt-0.5">
              Badges unlocked on senior Android devices via local incident neutralizations sync to the central audit log on every heartbeat.
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span className="px-3 py-1.5 rounded-xl bg-teal-500/10 border border-teal-500/30 text-teal-300 text-xs font-bold">
            100% Synchronized
          </span>
        </div>
      </div>
    </div>
  )
}
