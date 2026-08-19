import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAdminData } from '../context/AdminDataContext'

export default function BatchUserImport() {
  const navigate = useNavigate()
  const { importBatchUsers } = useAdminData()
  const [csvText, setCsvText] = useState(
    `Name,Age,Phone,Location,RiskScore\n"Shanti Patel",76,"+91 98250 14820","Ahmedabad, GJ",42\n"Ramesh Sharma",82,"+91 98110 59281","New Delhi NCR",78\n"Anandi Deshmukh",74,"+91 90289 44210","Mumbai, MH",55`
  )
  const [importedCount, setImportedCount] = useState(null)

  const handleImport = () => {
    try {
      const lines = csvText.trim().split('\n')
      if (lines.length <= 1) return alert('Please enter at least one user record.')
      
      const newUsers = lines.slice(1).map((line, idx) => {
        const parts = line.split(',').map(s => s.trim().replace(/^"|"$/g, ''))
        return {
          id: `batch-${Date.now()}-${idx}`,
          name: parts[0] || `Imported Senior #${idx + 1}`,
          age: parseInt(parts[1], 10) || 72,
          phone: parts[2] || '(555) 000-0000',
          location: parts[3] || 'Portland, OR',
          device: 'Standard Endpoint',
          guardians: [{ name: 'Assigned Caregiver', relation: 'Family', phone: '(555) 999-8888' }],
          geofenceStatus: 'Inside Safe Zone',
          riskScore: parseInt(parts[4], 10) || 30,
          avatar: `https://images.unsplash.com/photo-1544005313?w=150&auto=format&fit=crop&q=80`,
          isSuspended: false
        }
      })

      importBatchUsers(newUsers)
      setImportedCount(newUsers.length)
      setTimeout(() => {
        navigate('/users')
      }, 1500)
    } catch (e) {
      alert('Error parsing CSV. Please check formatting.')
    }
  }

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* ── Header (Stitch Screen 88) ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">Batch User Import</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Provision protected senior endpoints and assign emergency guardians via structured CSV data.
          </p>
        </div>
      </div>

      {importedCount && (
        <div className="bg-primary text-on-primary p-4 rounded-2xl flex items-center gap-3 shadow-md text-xs font-bold animate-pulse">
          <span className="material-symbols-outlined text-[20px]">check_circle</span>
          Successfully provisioned {importedCount} new senior accounts. Redirecting to directory...
        </div>
      )}

      <div className="bg-surface rounded-3xl p-6 md:p-8 shadow-sm border border-surface-container-high space-y-5">
        <div>
          <label className="block font-bold text-xs text-on-surface mb-2">
            Paste CSV Data (Columns: Name, Age, Phone, Location, RiskScore)
          </label>
          <textarea
            rows={8}
            value={csvText}
            onChange={(e) => setCsvText(e.target.value)}
            className="w-full p-4 font-mono text-xs text-on-surface bg-surface-container-low border border-outline rounded-2xl focus:border-primary focus:outline-none leading-relaxed"
          />
        </div>

        <div className="flex items-center justify-between pt-2">
          <button
            onClick={() => navigate('/users')}
            className="px-5 py-2.5 rounded-xl border border-outline text-xs font-bold text-on-surface hover:bg-surface-container-high transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleImport}
            className="px-6 py-2.5 bg-primary text-on-primary rounded-xl text-xs font-bold hover:bg-primary-container transition-colors shadow-sm flex items-center gap-2"
          >
            <span className="material-symbols-outlined text-[18px]">upload</span>
            Execute Bulk Provisioning
          </button>
        </div>
      </div>
    </div>
  )
}
