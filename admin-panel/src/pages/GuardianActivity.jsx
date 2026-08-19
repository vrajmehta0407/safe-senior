import { useState } from 'react'
import {
  Activity,
  Filter,
  Search,
  CheckCircle,
  AlertTriangle,
  ShieldCheck,
  PhoneCall,
  MessageSquare,
  Globe,
  Clock,
  Download
} from 'lucide-react'
import { mockUsers, mockAlerts } from '../mockData'

export default function GuardianActivity() {
  const [filterChannel, setFilterChannel] = useState('ALL')
  const [search, setSearch] = useState('')

  const activityFeed = [
    { id: 'act-01', user: 'Shanti Patel', event: 'Voice Call Screened - Clean', channel: 'Voice', timestamp: '10 mins ago', status: 'Safe', details: 'Caller verified as Dr. Anjali Mehta Clinic, Ahmedabad.' },
    { id: 'act-02', user: 'Harish Verma', event: 'Deepfake Voice Warning Alert', channel: 'Voice', timestamp: '25 mins ago', status: 'Blocked', details: 'CBI officer voice clone probability 98.4% detected and silenced.' },
    { id: 'act-03', user: 'Ramesh Sharma', event: 'SMS Phishing Link Blocked', channel: 'SMS', timestamp: '1 hour ago', status: 'Quarantined', details: 'Spoofed MSEDCL electricity disconnection APK link intercepted.' },
    { id: 'act-04', user: 'Anandi Deshmukh', event: 'Safety Quiz Completed: Digital Arrest Scams', channel: 'Education', timestamp: '3 hours ago', status: 'Completed', details: 'Score: 100% (Earned Cyber Suraksha Gold Badge).' },
    { id: 'act-05', user: 'K. Narayanaswamy', event: 'Geofence Safe Zone Departure', channel: 'Location', timestamp: '5 hours ago', status: 'Warning', details: 'Exited Home Safe Zone towards Adyar Market, Chennai.' },
    { id: 'act-06', user: 'Shanti Patel', event: 'Daily UPI Spending Limit Verified', channel: 'Financial', timestamp: '8 hours ago', status: 'Verified', details: '₹850 kirana store UPI payment approved under ₹5,000 daily limit.' }
  ]

  const filtered = activityFeed.filter(item => {
    const matchChannel = filterChannel === 'ALL' || item.channel.toUpperCase() === filterChannel.toUpperCase()
    const matchSearch = item.user.toLowerCase().includes(search.toLowerCase()) || item.details.toLowerCase().includes(search.toLowerCase())
    return matchChannel && matchSearch
  })

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      <div className="stitch-card-header">
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800 }}>Guardian Activity & Security History</h1>
          <p style={{ fontSize: 14, color: 'var(--on-surface-variant)' }}>
            Comprehensive immutable audit trail of all senior safety events, calls, and intercepted threats
          </p>
        </div>
        <button className="stitch-btn stitch-btn-outline stitch-btn-sm" onClick={() => alert('Exporting CSV activity report...')}>
          <Download size={14} /> Export Activity Audit
        </button>
      </div>

      {/* Filter Bar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 12 }}>
        <div className="filter-chips-bar" style={{ marginBottom: 0 }}>
          {['ALL', 'Voice', 'SMS', 'Education', 'Location', 'Financial'].map(cat => (
            <button
              key={cat}
              className={`chip-btn ${filterChannel === cat ? 'active' : ''}`}
              onClick={() => setFilterChannel(cat)}
            >
              {cat}
            </button>
          ))}
        </div>

        <div className="search-input-wrapper" style={{ width: 280 }}>
          <Search size={16} />
          <input
            type="text"
            placeholder="Search activity events..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="stitch-input"
            style={{ padding: '8px 12px 8px 38px', fontSize: 13 }}
          />
        </div>
      </div>

      {/* Activity Table */}
      <div className="stitch-table-container">
        <table className="stitch-table">
          <thead>
            <tr>
              <th>Senior User</th>
              <th>Security Event</th>
              <th>Channel</th>
              <th>Status</th>
              <th>Timestamp</th>
              <th>Forensic Details</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map(row => (
              <tr key={row.id}>
                <td>
                  <strong style={{ fontSize: 14 }}>{row.user}</strong>
                </td>
                <td>
                  <div style={{ fontWeight: 600 }}>{row.event}</div>
                </td>
                <td>
                  <span className="stitch-badge badge-neutral">{row.channel}</span>
                </td>
                <td>
                  <span className={`stitch-badge ${row.status === 'Safe' || row.status === 'Completed' || row.status === 'Verified' ? 'badge-safe' : row.status === 'Blocked' || row.status === 'Quarantined' ? 'badge-danger' : 'badge-warning'}`}>
                    {row.status}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--on-surface-variant)' }}>
                    <Clock size={12} /> {row.timestamp}
                  </div>
                </td>
                <td>
                  <div style={{ fontSize: 13, color: 'var(--on-surface-variant)', maxWidth: 360 }}>
                    {row.details}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
