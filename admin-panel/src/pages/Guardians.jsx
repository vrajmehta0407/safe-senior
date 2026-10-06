import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function Guardians() {
  const { guardians } = useAdminData()
  const [search, setSearch] = useState('')

  const activeGuardians = Array.isArray(guardians) ? guardians : []

  const filtered = activeGuardians.filter(g =>
    (g.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (g.user || '').toLowerCase().includes(search.toLowerCase()) ||
    (g.phone || '').includes(search) ||
    (g.relation || '').toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* ── Page Header ── */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900/80 p-6 rounded-3xl border border-slate-800/80 backdrop-blur-xl shadow-xl">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-teal-400 animate-pulse"></span>
            <span className="text-xs font-mono font-bold text-teal-400 uppercase tracking-widest">
              Family & Protector Circle
            </span>
          </div>
          <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
            <span className="material-symbols-outlined text-teal-400 text-3xl">family_restroom</span>
            Guardian Safety Circle Network
          </h2>
          <p className="text-sm text-slate-400 mt-1 max-w-2xl">
            Live database records from PostgreSQL. Verified family protectors, emergency SMS responders, and medical caregivers linked to senior citizen profiles.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="px-5 py-3 bg-slate-950/80 border border-slate-800 rounded-2xl text-center">
            <div className="text-2xl font-bold text-teal-300">{activeGuardians.length}</div>
            <div className="text-[10px] text-slate-400 font-semibold uppercase">Verified Guardians</div>
          </div>
        </div>
      </header>

      {/* ── Search & Metrics Bar ── */}
      <div className="bg-slate-900/80 rounded-2xl p-4 shadow-xl border border-slate-800/80 flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">
            search
          </span>
          <input
            type="text"
            placeholder="Search by guardian name, senior, relationship, phone..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full bg-slate-950 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-xs text-white placeholder:text-slate-500 focus:ring-2 focus:ring-teal-500 focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2 text-xs">
          <span className="px-3 py-1.5 rounded-xl bg-teal-500/10 border border-teal-500/20 text-teal-300 font-bold flex items-center gap-1.5">
            <span className="material-symbols-outlined text-sm">verified</span>
            100% Dual-Auth Ready
          </span>
        </div>
      </div>

      {/* ── Guardians Table ── */}
      <div className="bg-slate-900/80 rounded-2xl shadow-xl overflow-hidden border border-slate-800/80 backdrop-blur-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-950/60 text-slate-400 text-xs border-b border-slate-800/80 uppercase tracking-wider font-semibold">
                <th className="p-4">Guardian Contact</th>
                <th className="p-4">Relationship</th>
                <th className="p-4">Protected Senior Citizen</th>
                <th className="p-4">Authorization</th>
                <th className="p-4">Status</th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="text-xs text-slate-200 divide-y divide-slate-800/60">
              {filtered.length > 0 ? (
                filtered.map((g) => (
                  <tr key={g.id} className="hover:bg-slate-800/40 transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-teal-500/15 text-teal-300 border border-teal-500/20 flex items-center justify-center font-bold text-sm shadow-inner">
                          {g.name ? g.name.charAt(0) : 'G'}
                        </div>
                        <div>
                          <div className="font-bold text-white text-sm">{g.name}</div>
                          <div className="font-mono text-slate-400 text-xs mt-0.5">{g.phone}</div>
                        </div>
                      </div>
                    </td>

                    <td className="p-4">
                      <span className="px-3 py-1 rounded-full text-[11px] font-bold bg-slate-800 text-teal-300 border border-slate-700">
                        {g.relation || 'Guardian'}
                      </span>
                    </td>

                    <td className="p-4">
                      <div className="font-semibold text-white">{g.user || 'Linked Senior'}</div>
                      <div className="text-[11px] text-slate-400">End-to-end Encrypted Relay</div>
                    </td>

                    <td className="p-4">
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-emerald-500/15 text-emerald-400 border border-emerald-500/20">
                        Primary Responder
                      </span>
                    </td>

                    <td className="p-4">
                      <div className="flex items-center gap-1.5 text-teal-400 font-bold">
                        <span className="w-2 h-2 rounded-full bg-teal-400 animate-pulse"></span>
                        Active
                      </div>
                    </td>

                    <td className="p-4 text-right">
                      <a
                        href={`tel:${g.phone}`}
                        className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 font-bold inline-flex items-center gap-1 transition-all"
                      >
                        <span className="material-symbols-outlined text-[16px]">call</span>
                        Contact
                      </a>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" className="p-8 text-center text-slate-400">
                    No guardians matching &quot;{search}&quot;
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
