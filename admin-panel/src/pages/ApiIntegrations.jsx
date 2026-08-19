import { useState } from 'react'
import { useAdminData } from '../context/AdminDataContext'

export default function ApiIntegrations() {
  const { apiIntegrations, regenerateApiKey } = useAdminData()
  const [copiedId, setCopiedId] = useState(null)
  const [testingId, setTestingId] = useState(null)
  const [testResult, setTestResult] = useState(null)

  const copyKey = (id, key) => {
    navigator.clipboard.writeText(key)
    setCopiedId(id)
    setTimeout(() => setCopiedId(null), 2500)
  }

  const testConnection = (id) => {
    setTestingId(id)
    setTimeout(() => {
      setTestingId(null)
      setTestResult({ id, status: 'Healthy (22ms ping)' })
      setTimeout(() => setTestResult(null), 3000)
    }, 600)
  }

  return (
    <div className="space-y-6 max-w-5xl mx-auto">
      {/* ── Header (Stitch Screen 93) ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface font-bold">API & Integration Management</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant mt-0.5">
            Active webhooks, carrier screening microservices, and AI neural model connectors.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {apiIntegrations.map((item) => (
          <div
            key={item.id}
            className="bg-surface rounded-3xl p-6 shadow-sm border border-surface-container-high flex flex-col justify-between"
          >
            <div>
              <div className="flex items-start justify-between mb-3">
                <h3 className="font-bold text-sm text-on-surface">{item.name}</h3>
                <span className={`px-2.5 py-0.5 rounded-full text-[11px] font-bold ${
                  item.status === 'Connected' ? 'bg-primary-container/20 text-primary' : 'bg-tertiary-container/20 text-tertiary'
                }`}>
                  {item.status}
                </span>
              </div>

              <p className="text-xs text-on-surface-variant mb-4">
                Throughput: {item.rateLimit}
              </p>

              <div className="bg-surface-container-low p-3 rounded-xl border border-surface-container-high flex items-center justify-between mb-4">
                <span className="font-mono text-xs text-on-surface truncate pr-2">{item.key}</span>
                <button
                  onClick={() => copyKey(item.id, item.key)}
                  className="p-1 text-primary hover:bg-primary-container/10 rounded transition-colors shrink-0"
                  title="Copy Key"
                >
                  <span className="material-symbols-outlined text-[18px]">
                    {copiedId === item.id ? 'check' : 'content_copy'}
                  </span>
                </button>
              </div>

              {testResult && testResult.id === item.id && (
                <div className="text-[11px] text-primary font-bold mb-3 flex items-center gap-1">
                  <span className="material-symbols-outlined text-[14px]">check_circle</span>
                  {testResult.status}
                </div>
              )}
            </div>

            <div className="flex gap-2 pt-2">
              <button
                onClick={() => testConnection(item.id)}
                disabled={testingId === item.id}
                className="flex-1 py-2 bg-surface-container-high hover:bg-surface-container-highest rounded-xl text-xs font-bold text-on-surface transition-colors"
              >
                {testingId === item.id ? 'Testing...' : 'Ping Test'}
              </button>
              <button
                onClick={() => regenerateApiKey(item.id)}
                className="flex-1 py-2 border border-outline hover:bg-surface-container-low rounded-xl text-xs font-bold text-on-surface transition-colors"
              >
                Rotate Key
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
