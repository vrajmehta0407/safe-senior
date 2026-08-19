import { useState } from 'react'
import {
  Heart,
  Search,
  CheckCircle,
  Phone,
  ShieldCheck,
  UserPlus,
  Mail
} from 'lucide-react'
import { mockUsers } from '../mockData'

export default function Guardians() {
  const [search, setSearch] = useState('')

  // Flatten guardians from mock users
  const allGuardians = mockUsers.flatMap(u =>
    u.guardians.map((g, idx) => ({
      id: `${u.id}-g-${idx}`,
      name: g.name,
      phone: g.phone,
      relation: g.relation,
      role: g.role,
      seniorName: u.name,
      seniorLocation: u.location,
      addedDate: 'Jan 15, 2026'
    }))
  )

  const filtered = allGuardians.filter(g =>
    g.name.toLowerCase().includes(search.toLowerCase()) ||
    g.seniorName.toLowerCase().includes(search.toLowerCase()) ||
    g.phone.includes(search)
  )

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      <div className="stitch-card-header">
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800 }}>Guardian Network Directory</h1>
          <p style={{ fontSize: 14, color: 'var(--on-surface-variant)' }}>
            All verified family guardians with authorized dual-authentication permissions
          </p>
        </div>
      </div>

      <div className="stitch-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
          <div className="search-input-wrapper" style={{ width: 320 }}>
            <Search size={16} />
            <input
              type="text"
              placeholder="Search by guardian or senior name..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="stitch-input"
              style={{ padding: '8px 12px 8px 38px' }}
            />
          </div>
          <span className="stitch-badge badge-safe">
            <ShieldCheck size={12} /> {filtered.length} Active Guardians
          </span>
        </div>

        <div className="stitch-table-container">
          <table className="stitch-table">
            <thead>
              <tr>
                <th>Guardian Contact</th>
                <th>Relationship</th>
                <th>Monitored Senior</th>
                <th>Authorization Role</th>
                <th>Joined</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(g => (
                <tr key={g.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <div style={{
                        width: 36,
                        height: 36,
                        borderRadius: '50%',
                        background: 'var(--primary-light)',
                        color: 'var(--primary)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontWeight: 700
                      }}>
                        <Heart size={16} fill="var(--primary)" />
                      </div>
                      <div>
                        <strong style={{ fontSize: 14 }}>{g.name}</strong>
                        <div style={{ fontSize: 12, color: 'var(--on-surface-variant)' }}>{g.phone}</div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className="stitch-badge badge-neutral">{g.relation}</span>
                  </td>
                  <td>
                    <div style={{ fontWeight: 600, fontSize: 14 }}>{g.seniorName}</div>
                    <div style={{ fontSize: 12, color: 'var(--on-surface-variant)' }}>{g.seniorLocation}</div>
                  </td>
                  <td>
                    <span className="stitch-badge badge-safe">{g.role} Guardian</span>
                  </td>
                  <td>
                    <span style={{ fontSize: 13, color: 'var(--on-surface-variant)' }}>{g.addedDate}</span>
                  </td>
                  <td>
                    <span className="stitch-badge badge-safe">Verified Active</span>
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
