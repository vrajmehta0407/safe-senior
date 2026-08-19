import { useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { mockUsers } from '../mockData'

export default function GeofencingConfig() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const userId = searchParams.get('id') || 'u1'
  const user = mockUsers.find(u => u.id === userId) || mockUsers[0]

  const [zones, setZones] = useState([
    { id: 'z1', name: 'Home Safe Perimeter', condition: 'Alert on Leave (Night)', enabled: true, icon: 'home', radius: 150 },
    { id: 'z2', name: 'Corner Grocery Store', condition: 'Alert on Arrive', enabled: false, icon: 'local_mall', radius: 100 },
    { id: 'z3', name: 'Senior Community Center', condition: 'Alert on Delay (>2h)', enabled: true, icon: 'diversity_3', radius: 250 }
  ])

  const [selectedZone, setSelectedZone] = useState(zones[0])
  const [radius, setRadius] = useState(150)
  const [alertType, setAlertType] = useState('On Leave')
  const [startTime, setStartTime] = useState('22:00')
  const [endTime, setEndTime] = useState('06:00')
  const [savedSuccess, setSavedSuccess] = useState(false)

  const handleSave = () => {
    setSavedSuccess(true)
    setTimeout(() => setSavedSuccess(false), 3000)
  }

  return (
    <div className="space-y-6">
      {/* ── Header (Stitch Screen 81) ── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="font-headline-lg text-headline-lg text-on-surface font-bold">Safe Zones Configuration</h2>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Define and manage autonomous boundary geofences for {user.name} ({user.location}).
          </p>
        </div>
        <button
          onClick={() => navigate(`/protection-details?id=${user.id}`)}
          className="h-[44px] px-5 rounded-xl border border-outline text-on-surface font-label-md text-xs font-bold hover:bg-surface-container-high transition-colors flex items-center gap-2"
        >
          <span className="material-symbols-outlined text-[18px]">person</span>
          User Protection Profile
        </button>
      </div>

      {savedSuccess && (
        <div className="bg-primary text-on-primary p-3 px-4 rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm animate-pulse">
          <span className="material-symbols-outlined text-[18px]">check_circle</span>
          Geofence perimeter and night-wandering alerts updated on endpoint.
        </div>
      )}

      {/* ── Main Canvas Layout (Map on Left / Control Panel on Right) ── */}
      <div className="flex flex-col lg:flex-row gap-6 min-h-[600px]">
        {/* Map Area */}
        <div className="flex-1 bg-surface-container-lowest rounded-2xl shadow-sm border border-surface-container-high overflow-hidden relative flex flex-col min-h-[400px]">
          {/* Overlay Buttons */}
          <div className="absolute top-4 left-4 z-10 flex gap-2">
            <button className="bg-surface text-on-surface px-4 py-2 rounded-full shadow-sm border border-surface-container-high font-label-md text-xs font-bold flex items-center gap-2 hover:bg-surface-container transition-colors">
              <span className="material-symbols-outlined text-[18px]">draw</span>
              Draw Polygon
            </button>
            <button className="bg-surface text-on-surface px-4 py-2 rounded-full shadow-sm border border-surface-container-high font-label-md text-xs font-bold flex items-center gap-2 hover:bg-surface-container transition-colors">
              <span className="material-symbols-outlined text-[18px]">radio_button_unchecked</span>
              Draw Circle
            </button>
          </div>

          {/* Stylized Map View with Geofence Circle */}
          <div className="flex-1 bg-[#eef5f5] relative w-full h-full flex items-center justify-center p-8">
            <svg viewBox="0 0 800 500" className="w-full h-full text-[#c8dede]">
              <path d="M 0 100 Q 200 80 400 120 T 800 100" fill="none" stroke="currentColor" strokeWidth="12" />
              <path d="M 0 250 Q 200 240 400 260 T 800 240" fill="none" stroke="currentColor" strokeWidth="16" />
              <path d="M 0 400 Q 200 380 400 420 T 800 400" fill="none" stroke="currentColor" strokeWidth="12" />
              <line x1="200" y1="0" x2="200" y2="500" stroke="currentColor" strokeWidth="10" />
              <line x1="450" y1="0" x2="450" y2="500" stroke="currentColor" strokeWidth="16" />
              <line x1="650" y1="0" x2="650" y2="500" stroke="currentColor" strokeWidth="10" />
            </svg>

            {/* Geofence Boundary Pulse Overlay */}
            <div
              className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full border-4 border-primary/60 bg-primary/10 flex items-center justify-center pointer-events-none transition-all duration-300"
              style={{ width: radius * 1.6, height: radius * 1.6 }}
            >
              <div className="bg-surface text-primary p-3 rounded-full shadow-md flex items-center justify-center border-2 border-white">
                <span className="material-symbols-outlined text-[24px]">home</span>
              </div>
            </div>

            <div className="absolute bottom-4 left-4 bg-surface/90 backdrop-blur-sm px-3.5 py-1.5 rounded-xl border border-surface-container-high text-xs font-bold text-on-surface flex items-center gap-1.5 shadow-sm">
              <span className="w-2 h-2 rounded-full bg-primary animate-ping"></span>
              Radius: {radius}m • Coordinates: 45.5152° N, 122.6784° W
            </div>
          </div>
        </div>

        {/* Control Panel (List & Config) */}
        <div className="w-full lg:w-96 flex flex-col gap-6">
          {/* Active Zones List */}
          <div className="bg-surface-container-lowest rounded-2xl p-5 shadow-sm border border-surface-container-high">
            <h3 className="font-headline-sm text-sm font-bold text-on-surface mb-3">Active Safe Zones</h3>
            <div className="space-y-3">
              {zones.map((z) => (
                <div
                  key={z.id}
                  onClick={() => { setSelectedZone(z); setRadius(z.radius); }}
                  className={`flex items-center justify-between p-3.5 rounded-xl border transition-all cursor-pointer ${
                    selectedZone.id === z.id
                      ? 'bg-primary-container/10 border-primary shadow-sm'
                      : 'bg-surface-container-low border-surface-container-high hover:bg-surface-container'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-primary-container/20 flex items-center justify-center text-primary">
                      <span className="material-symbols-outlined text-[18px]">{z.icon}</span>
                    </div>
                    <div>
                      <p className="font-label-lg text-xs font-bold text-on-surface">{z.name}</p>
                      <p className="font-body-md text-[11px] text-on-surface-variant">{z.condition}</p>
                    </div>
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation()
                      setZones(zones.map(item => item.id === z.id ? { ...item, enabled: !item.enabled } : item))
                    }}
                    className={`w-10 h-5 flex items-center rounded-full p-0.5 transition-colors ${
                      z.enabled ? 'bg-primary' : 'bg-outline-variant'
                    }`}
                  >
                    <div
                      className={`bg-white w-4 h-4 rounded-full shadow transform transition-transform ${
                        z.enabled ? 'translate-x-5' : 'translate-x-0'
                      }`}
                    />
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Selected Zone Configuration */}
          <div className="bg-surface-container-lowest rounded-2xl p-5 shadow-sm border border-surface-container-high">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-headline-sm text-sm font-bold text-on-surface">Edit '{selectedZone.name}'</h3>
              <button
                onClick={() => alert(`Reset zone ${selectedZone.name}`)}
                className="text-error hover:bg-error-container/20 p-1.5 rounded-full transition-colors"
                title="Delete Zone"
              >
                <span className="material-symbols-outlined text-[18px]">delete</span>
              </button>
            </div>

            <div className="space-y-4 text-xs">
              <div>
                <label className="block font-label-md text-on-surface-variant mb-1 font-bold">Zone Name</label>
                <input
                  type="text"
                  value={selectedZone.name}
                  onChange={(e) => setSelectedZone({ ...selectedZone, name: e.target.value })}
                  className="w-full h-[42px] px-3 bg-surface rounded-xl border border-outline focus:border-primary focus:outline-none text-xs text-on-surface font-bold"
                />
              </div>

              <div>
                <div className="flex justify-between items-center mb-1">
                  <label className="font-label-md text-on-surface-variant font-bold">Radius (meters)</label>
                  <span className="font-bold text-primary">{radius}m</span>
                </div>
                <input
                  type="range"
                  min={50}
                  max={500}
                  value={radius}
                  onChange={(e) => setRadius(Number(e.target.value))}
                  className="w-full accent-primary"
                />
              </div>

              <div className="pt-2 border-t border-surface-container-high">
                <label className="block font-label-md text-on-surface-variant mb-2 font-bold">Alert Trigger Condition</label>
                <div className="flex gap-2 mb-3">
                  {['On Leave', 'On Arrive'].map((cond) => (
                    <button
                      key={cond}
                      onClick={() => setAlertType(cond)}
                      className={`flex-1 py-2 rounded-xl font-label-md text-xs font-bold transition-all ${
                        alertType === cond
                          ? 'bg-primary text-on-primary shadow-sm'
                          : 'bg-surface text-on-surface border border-outline hover:bg-surface-container'
                      }`}
                    >
                      {cond}
                    </button>
                  ))}
                </div>

                <div>
                  <label className="block font-label-md text-on-surface-variant mb-1.5 font-bold">Active Enforcement Hours</label>
                  <div className="flex gap-2 items-center">
                    <input
                      type="time"
                      value={startTime}
                      onChange={(e) => setStartTime(e.target.value)}
                      className="flex-1 h-[40px] px-2.5 bg-surface rounded-xl border border-outline text-xs text-on-surface font-bold focus:border-primary focus:outline-none"
                    />
                    <span className="text-on-surface-variant font-bold">to</span>
                    <input
                      type="time"
                      value={endTime}
                      onChange={(e) => setEndTime(e.target.value)}
                      className="flex-1 h-[40px] px-2.5 bg-surface rounded-xl border border-outline text-xs text-on-surface font-bold focus:border-primary focus:outline-none"
                    />
                  </div>
                  <p className="font-body-md text-[11px] text-on-surface-variant mt-1.5">
                    Wandering alerts dispatch to Family Guardians if departure occurs in this window.
                  </p>
                </div>
              </div>

              <button
                onClick={handleSave}
                className="w-full bg-primary text-on-primary h-[44px] rounded-xl font-label-lg text-xs font-bold flex items-center justify-center gap-2 hover:bg-primary-container transition-colors shadow-sm mt-4"
              >
                Save Geofence Perimeter
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
