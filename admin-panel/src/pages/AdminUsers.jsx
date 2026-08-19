import { useState } from 'react'
import {
  UserCog,
  Plus,
  ShieldCheck,
  Search,
  Key,
  CheckCircle,
  Clock
} from 'lucide-react'

export default function AdminUsers() {
  const [admins, setAdmins] = useState([
    { id: 'adm-01', name: 'Vraj Mehta', email: 'vraj.mehta@safesenior.org', role: 'Superadmin (SecOps Lead)', status: 'Active (2FA Enforced)', lastLogin: '10 mins ago' },
    { id: 'adm-02', name: 'Kiran Malhotra', email: 'kiran.malhotra@safesenior.org', role: 'Security Analyst', status: 'Active (2FA Enforced)', lastLogin: '2 hours ago' },
    { id: 'adm-03', name: 'Dr. Ananya Sen', email: 'ananya.sen@safesenior.org', role: 'Crisis Counselor Lead (NIMHANS)', status: 'Active (2FA Enforced)', lastLogin: 'Yesterday' }
  ])

  const [newModal, setNewModal] = useState(false)
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [role, setRole] = useState('Security Analyst')

  function handleCreate(e) {
    e.preventDefault()
    setAdmins([...admins, {
      id: `adm-0${admins.length + 1}`,
      name,
      email,
      role,
      status: 'Active (2FA Enforced)',
      lastLogin: 'Pending Invitation'
    }])
    setNewModal(false)
    setName('')
    setEmail('')
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      <div className="stitch-card-header">
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800 }}>Admin & SecOps Team Access</h1>
          <p style={{ fontSize: 14, color: 'var(--on-surface-variant)' }}>
            Role-based access control (RBAC), multi-factor hardware key provisioning, and SecOps management
          </p>
        </div>
        <button className="stitch-btn stitch-btn-primary stitch-btn-sm" onClick={() => setNewModal(true)}>
          <Plus size={14} /> Provision New Admin
        </button>
      </div>

      <div className="stitch-card">
        <div className="stitch-table-container">
          <table className="stitch-table">
            <thead>
              <tr>
                <th>Admin Name</th>
                <th>Security ID / Email</th>
                <th>Role & Permissions</th>
                <th>2FA Status</th>
                <th>Last Session</th>
              </tr>
            </thead>
            <tbody>
              {admins.map(adm => (
                <tr key={adm.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <div className="admin-avatar" style={{ width: 32, height: 32, fontSize: 13 }}>
                        {adm.name.charAt(0)}
                      </div>
                      <strong style={{ fontSize: 14 }}>{adm.name}</strong>
                    </div>
                  </td>
                  <td>
                    <div style={{ fontSize: 13 }}>{adm.email}</div>
                  </td>
                  <td>
                    <span className="stitch-badge badge-neutral">{adm.role}</span>
                  </td>
                  <td>
                    <span className="stitch-badge badge-safe">
                      <ShieldCheck size={12} /> {adm.status}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--on-surface-variant)' }}>
                      <Clock size={12} /> {adm.lastLogin}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {newModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <div className="modal-title">Provision New Administrative Operator</div>
              <button className="modal-close" onClick={() => setNewModal(false)}>✕</button>
            </div>

            <form onSubmit={handleCreate} style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              <div className="form-group">
                <label className="form-label">Full Name</label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={e => setName(e.target.value)}
                  placeholder="e.g. Jason Thorne"
                  className="stitch-input"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Work Email</label>
                <input
                  type="email"
                  required
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  placeholder="jason.thorne@safesenior.org"
                  className="stitch-input"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Security Role</label>
                <select value={role} onChange={e => setRole(e.target.value)} className="stitch-select">
                  <option>Security Analyst</option>
                  <option>Crisis Counselor Lead</option>
                  <option>Superadmin (SecOps Lead)</option>
                  <option>Compliance Auditor</option>
                </select>
              </div>

              <button type="submit" className="stitch-btn stitch-btn-primary" style={{ marginTop: 8 }}>
                Issue 2FA Enrollment Invite
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
