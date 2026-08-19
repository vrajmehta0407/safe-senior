import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Layers,
  ShieldAlert,
  Search,
  CheckCircle,
  ArrowRight,
  Send,
  PhoneCall,
  UserCheck,
  AlertTriangle,
  FileCheck
} from 'lucide-react'
import { mockAlerts, mockUsers } from '../mockData'

export default function ScamReports() {
  const nav = useNavigate()
  const [escalations, setEscalations] = useState([
    {
      id: 'esc-001',
      senior: 'Harish Verma',
      threat: 'Digital Arrest (CBI Deepfake Video Call) — RTGS Coercion',
      tier: 'Level 3 (Crisis Lead & Bengaluru Cyber Police Handover)',
      status: 'In Escalation',
      assignedTo: 'Vraj Mehta (SecOps Lead)',
      notes: 'Caller recorded. Voice spectral fingerprint flagged as ElevenLabs Hindi model clone. Bengaluru Cyber Police case # BCP-2026-0817 filed.'
    },
    {
      id: 'esc-002',
      senior: 'Ramesh Sharma',
      threat: 'SBI YONO KYC PAN Card Phish — Account Takeover Attempt',
      tier: 'Level 2 (Primary Guardian & SBI Account Lock)',
      status: 'Guardian Contacted',
      assignedTo: 'Kiran Malhotra (Analyst)',
      notes: 'Guardian confirmed senior entered partial OTP. SBI YONO account locked via API integration. 1930 complaint filed.'
    }
  ])

  const [newEscalationModal, setNewEscalationModal] = useState(false)
  const [selectedSenior, setSelectedSenior] = useState(mockUsers[0].id)
  const [threatDesc, setThreatDesc] = useState('')
  const [tierLevel, setTierLevel] = useState('Level 2 (Primary Guardian & Bank Lock)')

  function handleCreateEscalation(e) {
    e.preventDefault()
    const userObj = mockUsers.find(u => u.id === selectedSenior)
    const newEntry = {
      id: `esc-00${escalations.length + 1}`,
      senior: userObj?.name || 'Senior',
      threat: threatDesc || 'Coerced Transfer Attempt',
      tier: tierLevel,
      status: 'In Escalation',
      assignedTo: 'Vraj Mehta',
      notes: 'Escalation initiated via Admin Console.'
    }
    setEscalations([newEntry, ...escalations])
    setNewEscalationModal(false)
    setThreatDesc('')
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      <div className="stitch-card-header">
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800 }}>Incident Escalation Workflow</h1>
          <p style={{ fontSize: 14, color: 'var(--on-surface-variant)' }}>
            Structured multi-tier escalation protocols for high-stakes financial and voice scams
          </p>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <button className="stitch-btn stitch-btn-primary stitch-btn-sm" onClick={() => setNewEscalationModal(true)}>
            <Send size={14} /> New Incident Escalation
          </button>
        </div>
      </div>

      {/* Escalation Matrix Explanation */}
      <div className="stitch-card" style={{ background: 'var(--surface-container-low)' }}>
        <h3 style={{ fontSize: 16, marginBottom: 12 }}>Standard Escalation Tiers</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: 16 }}>
          <div style={{ padding: 14, background: 'var(--surface)', borderRadius: 'var(--radius-md)', border: '1px solid var(--outline)' }}>
            <div style={{ fontWeight: 700, color: 'var(--primary)', fontSize: 14 }}>Tier 1: Senior Interactive Guard</div>
            <p style={{ fontSize: 13, color: 'var(--on-surface-variant)', marginTop: 4 }}>
              In-app audio whisper warnings, quarantined SMS, and educational safety quiz prompts.
            </p>
          </div>

          <div style={{ padding: 14, background: 'var(--surface)', borderRadius: 'var(--radius-md)', border: '1px solid var(--outline)' }}>
            <div style={{ fontWeight: 700, color: 'var(--warning)', fontSize: 14 }}>Tier 2: Guardian Dual-Auth</div>
            <p style={{ fontSize: 13, color: 'var(--on-surface-variant)', marginTop: 4 }}>
              High-priority push alert to verified family guardians with one-tap transfer blocking.
            </p>
          </div>

          <div style={{ padding: 14, background: 'var(--surface)', borderRadius: 'var(--radius-md)', border: '1px solid var(--outline)' }}>
            <div style={{ fontWeight: 700, color: 'var(--secondary)', fontSize: 14 }}>Tier 3: Crisis Counselor & Police</div>
            <p style={{ fontSize: 13, color: 'var(--on-surface-variant)', marginTop: 4 }}>
              Direct telephonic warm handover to trained adult protective advocates & IC3 law enforcement.
            </p>
          </div>
        </div>
      </div>

      {/* Active Escalation Pipeline */}
      <div className="stitch-card">
        <div className="stitch-card-header">
          <div className="stitch-card-title">
            <Layers size={20} color="var(--secondary)" /> Active Incident Escalations
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          {escalations.map(item => (
            <div key={item.id} style={{
              padding: 18,
              borderRadius: 'var(--radius-lg)',
              border: '1px solid var(--outline)',
              background: 'var(--surface)',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              flexWrap: 'wrap',
              gap: 16
            }}>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span className="stitch-badge badge-danger">{item.tier}</span>
                  <span style={{ fontSize: 12, color: 'var(--on-surface-variant)' }}>ID: {item.id}</span>
                </div>
                <h3 style={{ fontSize: 17, marginTop: 6 }}>{item.senior} — {item.threat}</h3>
                <div style={{ fontSize: 13, color: 'var(--on-surface-variant)', marginTop: 4 }}>
                  Assigned Officer: <strong>{item.assignedTo}</strong> • Note: {item.notes}
                </div>
              </div>

              <div style={{ display: 'flex', gap: 10 }}>
                <button
                  className="stitch-btn stitch-btn-outline stitch-btn-sm"
                  onClick={() => nav(`/post-incident-reports?id=${item.id}`)}
                >
                  <FileCheck size={14} /> Report
                </button>
                <button
                  className="stitch-btn stitch-btn-secondary stitch-btn-sm"
                  onClick={() => nav('/crisis-handover')}
                >
                  <PhoneCall size={14} /> Crisis Handover
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* New Escalation Modal */}
      {newEscalationModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <div className="modal-title">Initiate Urgent Incident Escalation</div>
              <button className="modal-close" onClick={() => setNewEscalationModal(false)}>✕</button>
            </div>

            <form onSubmit={handleCreateEscalation} style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              <div className="form-group">
                <label className="form-label">Select Senior Target</label>
                <select
                  value={selectedSenior}
                  onChange={e => setSelectedSenior(e.target.value)}
                  className="stitch-select"
                >
                  {mockUsers.map(u => (
                    <option key={u.id} value={u.id}>{u.name} ({u.location})</option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Escalation Tier</label>
                <select
                  value={tierLevel}
                  onChange={e => setTierLevel(e.target.value)}
                  className="stitch-select"
                >
                  <option value="Level 1 (In-App Warning & Guard)">Tier 1: Senior Interactive Guard</option>
                  <option value="Level 2 (Primary Guardian & Bank Lock)">Tier 2: Primary Guardian & Bank Dual-Auth</option>
                  <option value="Level 3 (Crisis Lead & Police Handover)">Tier 3: Crisis Counselor & Police Handover</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Threat Description & Live Intel</label>
                <textarea
                  required
                  rows={3}
                  value={threatDesc}
                  onChange={e => setThreatDesc(e.target.value)}
                  placeholder="Detail intercepted voice deepfake, fraudulent wire instructions, or extortion notes..."
                  className="stitch-textarea"
                />
              </div>

              <button type="submit" className="stitch-btn stitch-btn-primary" style={{ marginTop: 8 }}>
                Deploy Incident Escalation
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
