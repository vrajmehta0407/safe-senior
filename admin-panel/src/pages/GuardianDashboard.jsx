import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { mockUsers } from '../mockData'

export default function GuardianDashboard() {
  const navigate = useNavigate()
  const [selectedUserIndex, setSelectedUserIndex] = useState(0)
  const user = mockUsers[selectedUserIndex] || mockUsers[0]

  return (
    <div className="space-y-8">
      {/* ── Header & Senior Switcher (Stitch Screen 71) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <img
            src={user.avatar}
            alt={user.name}
            className="w-14 h-14 rounded-full object-cover border-2 border-primary"
          />
          <div>
            <div className="flex items-center gap-2">
              <h1 className="font-headline-lg text-2xl font-bold text-on-surface">{user.name} (Mom)</h1>
              <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-primary-container/20 text-primary">
                Protected
              </span>
            </div>
            <p className="font-body-md text-xs text-on-surface-variant mt-0.5">
              Caregiver View • Last sync 2 mins ago • Safe Haven Guardian Network
            </p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => setSelectedUserIndex((selectedUserIndex + 1) % mockUsers.length)}
            className="h-[44px] px-4 rounded-xl border border-outline text-on-surface font-label-md text-xs font-bold hover:bg-surface-container-high transition-colors flex items-center gap-1.5"
          >
            <span className="material-symbols-outlined text-[18px]">swap_horiz</span>
            Switch Family Member
          </button>
          <button
            onClick={() => navigate('/crisis-handover')}
            className="h-[44px] px-5 bg-error text-on-error rounded-xl font-label-md text-xs font-bold hover:bg-error/90 transition-colors shadow-sm flex items-center gap-1.5"
          >
            <span className="material-symbols-outlined text-[18px]">emergency</span>
            Emergency SOS
          </button>
        </div>
      </div>

      {/* ── Masonry Grid Layout (Stitch Exact Screen 71 Layout) ── */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 auto-rows-min">
        {/* Status Summary Card (Hero / Spans 2 columns on lg) */}
        <div className="col-span-1 lg:col-span-2 bg-surface rounded-[24px] shadow-sm border border-surface-container-high p-6 flex flex-col justify-between overflow-hidden relative">
          <div className="absolute top-0 right-0 w-64 h-64 bg-primary-container/10 rounded-bl-[100px] pointer-events-none"></div>
          <div className="relative z-10 flex justify-between items-start mb-6">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-primary-container/20 flex items-center justify-center">
                <span className="material-symbols-outlined icon-fill text-primary text-2xl">verified_user</span>
              </div>
              <div>
                <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold">Overall Status</h3>
                <p className="font-body-md text-sm text-primary font-bold">All Clear - Safe & Active</p>
              </div>
            </div>
            <span className="px-4 py-1.5 bg-surface-container-low text-on-surface-variant rounded-full font-label-md text-xs font-bold border border-surface-container-high">
              Today
            </span>
          </div>

          <div className="relative z-10 grid grid-cols-1 sm:grid-cols-2 gap-4 mt-2">
            <div className="bg-surface-bright border border-surface-container-high rounded-xl p-4 flex items-center gap-4">
              <span className="material-symbols-outlined text-outline text-3xl">home</span>
              <div>
                <p className="font-label-md text-xs text-outline uppercase tracking-wider font-bold">Current Location</p>
                <p className="font-body-lg text-sm text-on-surface font-bold mt-0.5">Living Room (Safe Zone)</p>
              </div>
            </div>
            <div className="bg-surface-bright border border-surface-container-high rounded-xl p-4 flex items-center gap-4">
              <span className="material-symbols-outlined text-outline text-3xl">schedule</span>
              <div>
                <p className="font-label-md text-xs text-outline uppercase tracking-wider font-bold">Last Movement</p>
                <p className="font-body-lg text-sm text-on-surface font-bold mt-0.5">10 mins ago</p>
              </div>
            </div>
          </div>
        </div>

        {/* Health Metrics Card */}
        <div className="bg-surface rounded-[24px] shadow-sm border border-surface-container-high p-6 flex flex-col gap-6">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold text-base">Vitals Summary</h3>
            <button
              onClick={() => navigate(`/protection-details?id=${user.id}`)}
              className="text-primary hover:bg-primary-container/10 p-1.5 rounded-full transition-colors"
            >
              <span className="material-symbols-outlined text-[20px]">chevron_right</span>
            </button>
          </div>
          <div className="flex flex-col gap-3">
            {/* Heart Rate */}
            <div className="flex items-center justify-between p-3 rounded-xl bg-surface-container-low border border-surface-container-high">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-secondary-container/20 flex items-center justify-center text-secondary">
                  <span className="material-symbols-outlined icon-fill">favorite</span>
                </div>
                <div>
                  <p className="font-body-md text-xs text-on-surface font-bold">Heart Rate</p>
                  <p className="font-label-md text-[11px] text-outline">Resting</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-headline-sm text-base text-on-surface font-bold">72 <span className="text-xs font-normal text-outline">bpm</span></p>
              </div>
            </div>

            {/* Steps */}
            <div className="flex items-center justify-between p-3 rounded-xl bg-surface-container-low border border-surface-container-high">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-primary-container/20 flex items-center justify-center text-primary">
                  <span className="material-symbols-outlined icon-fill">directions_walk</span>
                </div>
                <div>
                  <p className="font-body-md text-xs text-on-surface font-bold">Daily Activity</p>
                  <p className="font-label-md text-[11px] text-outline">Goal: 3,000</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-headline-sm text-base text-on-surface font-bold">2,450 <span className="text-xs font-normal text-outline">steps</span></p>
              </div>
            </div>
          </div>
        </div>

        {/* Map Card (Spans 2 columns on lg) */}
        <div className="col-span-1 lg:col-span-2 bg-surface rounded-[24px] shadow-sm border border-surface-container-high overflow-hidden h-[260px] relative">
          <div className="w-full h-full bg-[#eef5f5] flex items-center justify-center relative">
            <svg viewBox="0 0 600 300" className="w-full h-full text-[#c8dede]">
              <line x1="50" y1="50" x2="550" y2="50" stroke="currentColor" strokeWidth="6" />
              <line x1="50" y1="150" x2="550" y2="150" stroke="currentColor" strokeWidth="10" />
              <line x1="50" y1="250" x2="550" y2="250" stroke="currentColor" strokeWidth="6" />
              <line x1="150" y1="20" x2="150" y2="280" stroke="currentColor" strokeWidth="8" />
              <line x1="380" y1="20" x2="380" y2="280" stroke="currentColor" strokeWidth="12" />
              <circle cx="380" cy="150" r="45" fill="#006565" fillOpacity="0.15" stroke="#006565" strokeWidth="2" strokeDasharray="4 4" />
            </svg>
            <div className="absolute top-[48%] left-[62%] -translate-x-1/2 -translate-y-1/2 flex flex-col items-center">
              <div className="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center shadow-lg border-2 border-white">
                <span className="material-symbols-outlined text-[16px]">person_pin_circle</span>
              </div>
              <span className="text-[11px] font-bold bg-white/90 px-2 py-0.5 rounded shadow mt-1 text-primary">
                {user.name.split(' ')[0]} (Ghar)
              </span>
            </div>
          </div>

          <div className="absolute top-4 left-4 bg-white/90 backdrop-blur-sm px-3.5 py-1.5 rounded-xl shadow-sm border border-surface-container-high flex items-center gap-2">
            <span className="material-symbols-outlined text-primary text-[18px]">location_on</span>
            <span className="font-label-lg text-xs text-on-surface font-bold">Home Safe Zone Active</span>
          </div>

          <button
            onClick={() => navigate(`/geofencing?id=${user.id}`)}
            className="absolute bottom-4 right-4 bg-surface text-primary px-3 py-1.5 rounded-xl text-xs font-bold shadow-sm border border-surface-container-high hover:bg-surface-container-high transition-colors"
          >
            Adjust Safe Perimeter →
          </button>
        </div>

        {/* Activity Log Feed */}
        <div className="bg-surface rounded-[24px] shadow-sm border border-surface-container-high p-6 flex flex-col h-[260px]">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold text-base">Activity Log</h3>
            <button
              onClick={() => navigate('/guardian-activity')}
              className="text-xs text-primary font-bold hover:underline"
            >
              Full Feed
            </button>
          </div>
          <div className="flex-grow overflow-y-auto pr-2 space-y-4 text-xs">
            <div className="flex gap-3 items-start relative pb-3">
              <div className="w-7 h-7 rounded-full bg-surface-container-high flex items-center justify-center z-10 shrink-0">
                <span className="material-symbols-outlined text-outline text-xs">local_fire_department</span>
              </div>
              <div>
                <p className="font-body-md text-on-surface font-bold">Rasoi / Kitchen activity detected</p>
                <p className="font-label-md text-[11px] text-outline">8:15 AM · Morning chai prepared</p>
              </div>
            </div>

            <div className="flex gap-3 items-start relative pb-3">
              <div className="w-7 h-7 rounded-full bg-surface-container-high flex items-center justify-center z-10 shrink-0">
                <span className="material-symbols-outlined text-outline text-xs">sensor_door</span>
              </div>
              <div>
                <p className="font-body-md text-on-surface font-bold">Main door opened / closed</p>
                <p className="font-label-md text-[11px] text-outline">7:50 AM · Newspaper & milk retrieval</p>
              </div>
            </div>

            <div className="flex gap-3 items-start relative">
              <div className="w-7 h-7 rounded-full bg-primary-container/20 flex items-center justify-center z-10 shrink-0">
                <span className="material-symbols-outlined text-primary text-xs">bed</span>
              </div>
              <div>
                <p className="font-body-md text-on-surface font-bold">Awake and out of bed</p>
                <p className="font-label-md text-[11px] text-outline">7:05 AM · Morning namaz / prayer detected</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
