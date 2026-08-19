import { useState } from 'react'
import { useSearchParams, useNavigate } from 'react-router-dom'
import {
  FileText,
  ShieldCheck,
  Download,
  Printer,
  CheckCircle,
  Share2,
  Lock,
  ArrowLeft,
  User,
  Calendar,
  AlertOctagon
} from 'lucide-react'

export default function PostIncidentReport() {
  const [params] = useSearchParams()
  const nav = useNavigate()
  const incidentId = params.get('id') || 'INC-2026-08841'

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24, maxWidth: 960, margin: '0 auto' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <button className="stitch-btn stitch-btn-ghost stitch-btn-sm" onClick={() => nav('/scam-reports')}>
          <ArrowLeft size={14} /> Back to Incident Escalations
        </button>

        <div style={{ display: 'flex', gap: 10 }}>
          <button className="stitch-btn stitch-btn-outline stitch-btn-sm" onClick={() => window.print()}>
            <Printer size={14} /> Print Formal PDF
          </button>
          <button className="stitch-btn stitch-btn-primary stitch-btn-sm" onClick={() => alert('Secure encrypted report link copied to clipboard.')}>
            <Share2 size={14} /> Share with Family / Bank
          </button>
        </div>
      </div>

      {/* Formal Post-Incident Report Card */}
      <div className="stitch-card" style={{ padding: '36px 40px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', borderBottom: '2px solid var(--surface-container)', paddingBottom: 24, marginBottom: 24 }}>
          <div>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: 'var(--primary-light)', color: 'var(--primary)', padding: '4px 10px', borderRadius: 9999, fontSize: 12, fontWeight: 800 }}>
              <ShieldCheck size={14} /> OFFICIAL SAFESENIOR INCIDENT POST-MORTEM
            </div>
            <h1 style={{ fontSize: 26, marginTop: 8 }}>Incident Audit & Remediation Dossier</h1>
            <p style={{ fontSize: 13, color: 'var(--on-surface-variant)' }}>
              Case File Reference: <strong>{incidentId}</strong> • Generated on Aug 17, 2026
            </p>
          </div>

          <div style={{ textAlign: 'right' }}>
            <span className="stitch-badge badge-safe" style={{ fontSize: 13, padding: '6px 14px' }}>
              Loss Prevented: ₹3,50,000
            </span>
          </div>
        </div>

        {/* Dossier Grid Summary */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16, marginBottom: 28, background: 'var(--surface-container-low)', padding: 18, borderRadius: 'var(--radius-lg)' }}>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, textTransform: 'uppercase', color: 'var(--on-surface-variant)' }}>Target Senior</div>
            <div style={{ fontSize: 15, fontWeight: 700, marginTop: 2 }}>Harish Verma (85) · Bengaluru</div>
          </div>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, textTransform: 'uppercase', color: 'var(--on-surface-variant)' }}>Attack Vector</div>
            <div style={{ fontSize: 15, fontWeight: 700, marginTop: 2 }}>Digital Arrest (CBI Customs Deepfake)</div>
          </div>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, textTransform: 'uppercase', color: 'var(--on-surface-variant)' }}>Intercepted Time</div>
            <div style={{ fontSize: 15, fontWeight: 700, marginTop: 2 }}>Aug 17, 2026 @ 11:24 AM IST</div>
          </div>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, textTransform: 'uppercase', color: 'var(--on-surface-variant)' }}>Financial Outcome</div>
            <div style={{ fontSize: 15, fontWeight: 700, color: 'var(--success)', marginTop: 2 }}>₹0 Lost (100% Blocked)</div>
          </div>
        </div>

        {/* Forensic Timeline */}
        <div style={{ marginBottom: 28 }}>
          <h3 style={{ fontSize: 18, marginBottom: 14 }}>Forensic Chronology of Events</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, borderLeft: '2px solid var(--primary)', paddingLeft: 18, marginLeft: 6 }}>
            <div>
              <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--primary)' }}>11:24:02 AM IST — Inbound Call Initiated</div>
              <p style={{ fontSize: 14, color: 'var(--on-surface)' }}>
                Spoofed CBI Delhi landline (+91 11 2309 4712) rang Harish Verma's mobile phone.
              </p>
            </div>
            <div>
              <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--secondary)' }}>11:24:14 AM IST — Spectral Voice AI Interception</div>
              <p style={{ fontSize: 14, color: 'var(--on-surface)' }}>
                SafeSenior Edge Voice Classifier detected artificial pitch cadence matching synthetic officer voice clone. Real-time audible whisper alert delivered: <em>"Savdhan: Nakli Awaaz Sanshay"</em>.
              </p>
            </div>
            <div>
              <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--warning)' }}>11:25:01 AM IST — RTGS Extortion Demand Intercepted</div>
              <p style={{ fontSize: 14, color: 'var(--on-surface)' }}>
                Caller demanded immediate RTGS transfer of ₹3,50,000 citing Aadhaar money laundering. System triggered Tier 2 Guardian Dual-Auth block on all outgoing UPI/NEFT.
              </p>
            </div>
            <div>
              <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--primary)' }}>11:25:40 AM IST — Guardian & 1930 Helpline Intervention</div>
              <p style={{ fontSize: 14, color: 'var(--on-surface)' }}>
                Primary guardian Vikram Verma received instantaneous push notification, called Harish directly to verify, and alerted Bengaluru Cyber Police (cybercrime.gov.in case # filed).
              </p>
            </div>
          </div>
        </div>

        {/* Recommended Action Checklist */}
        <div>
          <h3 style={{ fontSize: 18, marginBottom: 12 }}>Follow-Up Protective Actions</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, fontSize: 14 }}>
              <CheckCircle size={18} color="var(--primary)" />
              <span>Caller number <strong>+1 (602) 555-0199</strong> added to federal carrier blacklist repository.</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, fontSize: 14 }}>
              <CheckCircle size={18} color="var(--primary)" />
              <span>Safety Quiz module <em>"Grandchild Impersonation Scams"</em> assigned to Arthur’s device.</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, fontSize: 14 }}>
              <CheckCircle size={18} color="var(--primary)" />
              <span>Law Enforcement IC3 report payload generated and ready for voluntary dispatch.</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
