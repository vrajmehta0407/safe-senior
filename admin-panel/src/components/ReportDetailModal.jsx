import { useState } from 'react'
import { X, ShieldAlert, AlertTriangle, Ban, CheckCircle, User, Phone, Calendar, Radio } from 'lucide-react'

export default function ReportDetailModal({ report, onClose, onResolve }) {
  const [notes, setNotes] = useState('')

  if (!report) return null

  const reportId = report.id ? `SR-${report.id}` : 'SR-88231'
  const userName = report.user_name || 'Arthur P.'
  const userId = report.user_id ? `GA-${report.user_id}` : 'GA-99281'
  const userEmail = report.user_email || 'arthur.p@example.com'
  const channel = report.type ? report.type.toUpperCase() : 'SMS'
  const timestamp = report.timestamp || 'Oct 24, 2023 • 14:22'
  const source = report.sender || '+91 98765 43210'
  const transcript = report.body_preview || '"ALERT: Aapka SBI YONO account 24 ghante mein band ho jayega. PAN card verify karne ke liye abhi yahan click karein: http://sbi-kyc-verify-secure-882.com — SBI Customer Care"'

  return (
    <div className="modal-backdrop" onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{
        background: 'white', borderRadius: 28, padding: 32, width: '100%', maxWidth: 640,
        boxShadow: '0 20px 60px rgba(0,0,0,0.15)', position: 'relative'
      }}>
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'between', marginBottom: 24 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <h2 style={{ fontSize: 24, fontWeight: 900, color: '#0F2A4C', margin: 0 }}>
              Report #{reportId}
            </h2>
            <span style={{
              padding: '4px 12px', borderRadius: 12, fontSize: 11.5, fontWeight: 800,
              background: '#FDE8E8', color: '#D32F2F'
            }}>
              HIGH RISK
            </span>
          </div>
          <button
            onClick={onClose}
            style={{ border: 'none', background: 'transparent', cursor: 'pointer', color: '#5A6E85' }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Section 1 & 2: User & Metadata Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginBottom: 24 }}>
          {/* User Info */}
          <div>
            <div style={{ fontSize: 11, fontWeight: 800, color: '#8AA0BC', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 10 }}>
              REPORTING USER
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 44, height: 44, borderRadius: '50%', background: '#4A89DC', color: 'white',
                display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 16
              }}>
                {userName.charAt(0)}
              </div>
              <div>
                <div style={{ fontWeight: 800, color: '#0F2A4C', fontSize: 15 }}>{userName}</div>
                <div style={{ fontSize: 12, color: '#5A6E85' }}>User ID: {userId}</div>
                <div style={{ fontSize: 12, color: '#5A6E85' }}>{userEmail}</div>
              </div>
            </div>
          </div>

          {/* Incident Metadata */}
          <div>
            <div style={{ fontSize: 11, fontWeight: 800, color: '#8AA0BC', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 10 }}>
              INCIDENT METADATA
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6, fontSize: 13 }}>
              <div style={{ display: 'flex', justifyContent: 'between' }}>
                <span style={{ color: '#5A6E85' }}>Channel:</span>
                <span style={{ fontWeight: 800, color: '#0F2A4C' }}>{channel}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'between' }}>
                <span style={{ color: '#5A6E85' }}>Timestamp:</span>
                <span style={{ fontWeight: 800, color: '#0F2A4C' }}>{timestamp}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'between' }}>
                <span style={{ color: '#5A6E85' }}>Source:</span>
                <span style={{ fontWeight: 800, color: '#0F2A4C' }}>{source}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Section 3: Message Transcript */}
        <div style={{ marginBottom: 24 }}>
          <div style={{ fontSize: 11, fontWeight: 800, color: '#8AA0BC', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8 }}>
            MESSAGE TRANSCRIPT
          </div>
          <div style={{
            background: '#F4F6F9', borderRadius: 18, padding: 18,
            fontSize: 14, color: '#334A66', lineHeight: 1.5, fontStyle: 'italic'
          }}>
            {transcript}
          </div>
        </div>

        {/* Section 4: AI Risk Analysis */}
        <div style={{ marginBottom: 24 }}>
          <div style={{ fontSize: 11, fontWeight: 800, color: '#8AA0BC', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 10 }}>
            AI RISK ANALYSIS
          </div>
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
            <span style={{
              display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', borderRadius: 16,
              background: '#FDE8E8', color: '#D32F2F', fontSize: 12.5, fontWeight: 800
            }}>
              <ShieldAlert size={15} /> Phishing URL Detected
            </span>
            <span style={{
              display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', borderRadius: 16,
              background: '#FFF5E5', color: '#D67B27', fontSize: 12.5, fontWeight: 800
            }}>
              <AlertTriangle size={15} /> Urgency Sentiment High
            </span>
            <span style={{
              display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', borderRadius: 16,
              background: '#FDE8E8', color: '#D32F2F', fontSize: 12.5, fontWeight: 800
            }}>
              <Ban size={15} /> Global Blocklist Match
            </span>
          </div>
        </div>

        {/* Section 5: Admin Resolution Notes */}
        <div style={{ marginBottom: 28 }}>
          <div style={{ fontSize: 11, fontWeight: 800, color: '#8AA0BC', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8 }}>
            ADMIN RESOLUTION
          </div>
          <textarea
            rows={3}
            value={notes}
            onChange={e => setNotes(e.target.value)}
            placeholder="Enter resolution notes..."
            style={{
              width: '100%', borderRadius: 16, border: '1px solid #EAEFF5', padding: 14,
              fontSize: 14, outline: 'none', background: '#FAFCFF', color: '#0F2A4C', resize: 'vertical'
            }}
          />
        </div>

        {/* Footer Buttons */}
        <div style={{ display: 'flex', gap: 12 }}>
          <button
            onClick={() => onResolve && onResolve('resolved', notes)}
            style={{
              flex: 1, padding: '14px', borderRadius: 20, border: 'none',
              background: '#0F2A4C', color: 'white', fontWeight: 800, fontSize: 14, cursor: 'pointer'
            }}
          >
            Mark as Resolved
          </button>
          <button
            onClick={() => onResolve && onResolve('dismissed', notes)}
            style={{
              padding: '14px 20px', borderRadius: 20, border: '1px solid #D0D7E2',
              background: 'white', color: '#0F2A4C', fontWeight: 800, fontSize: 14, cursor: 'pointer'
            }}
          >
            Dismiss Report
          </button>
          <button
            onClick={() => onResolve && onResolve('blocked', notes)}
            style={{
              padding: '14px 20px', borderRadius: 20, border: 'none',
              background: '#C81D1D', color: 'white', fontWeight: 800, fontSize: 14, cursor: 'pointer'
            }}
          >
            Block Number Globally
          </button>
        </div>
      </div>
    </div>
  )
}
