import { useState } from 'react';

const CATEGORIES = ['Scam Alert', 'Safety Advisory', 'System Update', 'Emergency Notice'];
const TARGETS = ['All Users', 'Ahmedabad City', 'Satellite Zone', 'Navrangpura Zone', 'Maninagar Zone', 'Custom Radius'];

const PAST_BROADCASTS = [
  { id: 'BCT-047', title: 'SIM Swap Fraud Alert — Telecom Impersonation', category: 'Scam Alert', sentAt: '14 Jun 2026, 09:00', target: 'Ahmedabad City', delivered: 12847, openRate: 64, status: 'sent' },
  { id: 'BCT-046', title: 'Night Safety Advisory — Avoid Isolated Areas', category: 'Safety Advisory', sentAt: '13 Jun 2026, 20:00', target: 'All Users', delivered: 28430, openRate: 71, status: 'sent' },
  { id: 'BCT-045', title: 'Deepfake Scam Warning — Instagram DMs', category: 'Scam Alert', sentAt: '12 Jun 2026, 14:30', target: 'All Users', delivered: 31200, openRate: 58, status: 'sent' },
  { id: 'BCT-044', title: 'System Maintenance — Evidence Vault', category: 'System Update', sentAt: '11 Jun 2026, 10:00', target: 'Ahmedabad City', delivered: 0, openRate: 0, status: 'scheduled' },
];

export default function BroadcastPage() {
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [category, setCategory] = useState(CATEGORIES[0]);
  const [target, setTarget] = useState(TARGETS[0]);
  const [radius, setRadius] = useState(5);
  const [schedule, setSchedule] = useState('now');
  const [scheduleTime, setScheduleTime] = useState('');
  const [showConfirm, setShowConfirm] = useState(false);
  const [sent, setSent] = useState(false);

  const MSG_MAX = 300;

  function handleSend() {
    setShowConfirm(false);
    setSent(true);
    setTimeout(() => setSent(false), 4000);
    setTitle('');
    setMessage('');
  }

  return (
    <div className="animate-in">
      <div className="page-header">
        <div>
          <h2 className="page-title">📡 Broadcast Advisory System</h2>
          <p className="page-subtitle">Send targeted safety advisories and scam alerts to CyberShield users</p>
        </div>
      </div>

      {sent && (
        <div style={{
          background: 'rgba(0,229,160,0.1)', border: '1px solid rgba(0,229,160,0.3)',
          borderRadius: 12, padding: '1rem 1.25rem', marginBottom: '1.5rem',
          display: 'flex', alignItems: 'center', gap: '0.75rem', animation: 'fadeInUp 0.3s ease',
        }}>
          <span style={{ fontSize: '1.25rem' }}>✅</span>
          <div>
            <div style={{ fontWeight: 600, color: 'var(--green)' }}>Broadcast Sent Successfully</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--muted)' }}>Notification queued for delivery via FCM to selected users.</div>
          </div>
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: '1.5rem', alignItems: 'start' }}>
        {/* Compose Form */}
        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>✏️ Compose Broadcast</h3>

          <div className="form-group">
            <label className="label">Advisory Title *</label>
            <input
              className="input"
              placeholder="e.g. New SIM Swap Fraud Targeting Ahmedabad Residents"
              value={title}
              onChange={e => setTitle(e.target.value)}
            />
          </div>

          <div className="form-group">
            <label className="label">Message Content * <span style={{ float: 'right', color: message.length > MSG_MAX * 0.9 ? 'var(--warning)' : 'var(--muted)' }}>{message.length}/{MSG_MAX}</span></label>
            <textarea
              className="input textarea"
              style={{ minHeight: 130 }}
              placeholder="Describe the alert clearly. Include what to watch out for and what users should do..."
              value={message}
              onChange={e => { if (e.target.value.length <= MSG_MAX) setMessage(e.target.value); }}
            />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
            <div className="form-group" style={{ margin: 0 }}>
              <label className="label">Category</label>
              <select className="select" value={category} onChange={e => setCategory(e.target.value)}>
                {CATEGORIES.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>
            <div className="form-group" style={{ margin: 0 }}>
              <label className="label">Target Audience</label>
              <select className="select" value={target} onChange={e => setTarget(e.target.value)}>
                {TARGETS.map(t => <option key={t}>{t}</option>)}
              </select>
            </div>
          </div>

          {target === 'Custom Radius' && (
            <div className="form-group mt-4">
              <label className="label">Radius: {radius} km around Ahmedabad center</label>
              <input type="range" min={1} max={30} value={radius} onChange={e => setRadius(Number(e.target.value))}
                style={{ width: '100%', accentColor: 'var(--accent)' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--muted)' }}>
                <span>1 km</span><span>30 km</span>
              </div>
            </div>
          )}

          <div className="form-group mt-4" style={{ margin: '1rem 0 0' }}>
            <label className="label">Schedule</label>
            <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
              {['now', 'schedule'].map(opt => (
                <button
                  key={opt}
                  className={`btn ${schedule === opt ? 'btn-primary' : 'btn-ghost'} btn-sm`}
                  onClick={() => setSchedule(opt)}
                  style={{ flex: 1, justifyContent: 'center' }}
                >
                  {opt === 'now' ? '⚡ Send Now' : '🕐 Schedule'}
                </button>
              ))}
            </div>
            {schedule === 'schedule' && (
              <input type="datetime-local" className="input mt-3" value={scheduleTime} onChange={e => setScheduleTime(e.target.value)} />
            )}
          </div>

          <div className="divider" />
          <button
            className="btn btn-primary w-full"
            style={{ justifyContent: 'center', padding: '0.75rem' }}
            disabled={!title || !message}
            onClick={() => setShowConfirm(true)}
          >
            📡 {schedule === 'now' ? 'Send Broadcast' : 'Schedule Broadcast'}
          </button>
        </div>

        {/* Preview */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div className="card card-p">
            <h4 style={{ fontFamily: 'var(--font-display)', marginBottom: '1rem' }}>📱 Notification Preview</h4>
            <div style={{
              background: '#1C1C1E', borderRadius: 16, padding: '1rem',
              border: '1px solid rgba(255,255,255,0.1)', boxShadow: '0 8px 32px rgba(0,0,0,0.5)',
            }}>
              <div style={{ display: 'flex', gap: '0.625rem', alignItems: 'flex-start' }}>
                <div style={{ width: 36, height: 36, borderRadius: 10, background: 'linear-gradient(135deg,#FF3B6B,#8B5CF6)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1rem', flexShrink: 0 }}>🛡️</div>
                <div>
                  <div style={{ fontWeight: 700, fontSize: '0.875rem', color: '#fff' }}>CyberShield</div>
                  <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: '#E5E5EA', marginTop: 2 }}>{title || 'Advisory Title'}</div>
                  <div style={{ fontSize: '0.75rem', color: '#8E8E93', marginTop: 3, lineHeight: 1.4 }}>{message || 'Message will appear here...'}</div>
                  <div style={{ fontSize: '0.7rem', color: '#3C3C43', marginTop: 6 }}>now · Ahmedabad Cyber Crime Cell</div>
                </div>
              </div>
            </div>
          </div>

          <div className="card card-p">
            <h4 style={{ fontFamily: 'var(--font-display)', marginBottom: '0.875rem' }}>📊 Estimated Reach</h4>
            {[
              { label: 'Target Users', value: target === 'All Users' ? '31,240' : target === 'Ahmedabad City' ? '14,580' : `~${Math.round(radius * 850)} users` },
              { label: 'Est. Delivery Rate', value: '96.3%' },
              { label: 'Est. Open Rate', value: '62–74%' },
            ].map(s => (
              <div key={s.label} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem 0', borderBottom: '1px solid rgba(255,255,255,0.04)' }}>
                <span style={{ fontSize: '0.8125rem', color: 'var(--muted)' }}>{s.label}</span>
                <span style={{ fontWeight: 700, fontFamily: 'var(--font-display)', color: 'var(--green)' }}>{s.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Delivery Reports */}
      <div className="card p-0 mt-6">
        <div style={{ padding: '1.25rem 1.5rem', borderBottom: '1px solid var(--card-border)' }}>
          <h3 style={{ fontFamily: 'var(--font-display)' }}>📋 Recent Broadcasts & Delivery Reports</h3>
        </div>
        <div className="table-wrap">
          <table className="table">
            <thead>
              <tr>
                <th>ID</th><th>Title</th><th>Category</th><th>Sent</th><th>Target</th><th>Delivered</th><th>Open Rate</th><th>Status</th>
              </tr>
            </thead>
            <tbody>
              {PAST_BROADCASTS.map(b => (
                <tr key={b.id}>
                  <td><span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem', color: 'var(--info)' }}>{b.id}</span></td>
                  <td style={{ fontSize: '0.875rem', maxWidth: 220 }} className="truncate">{b.title}</td>
                  <td>
                    <span className={`badge ${b.category === 'Scam Alert' ? 'badge-high' : b.category === 'Safety Advisory' ? 'badge-under-review' : 'badge-submitted'}`} style={{ fontSize: '0.7rem' }}>
                      {b.category}
                    </span>
                  </td>
                  <td style={{ fontSize: '0.75rem', color: 'var(--muted)', fontFamily: 'var(--font-mono)' }}>{b.sentAt}</td>
                  <td style={{ fontSize: '0.8125rem', color: 'var(--muted)' }}>{b.target}</td>
                  <td style={{ fontWeight: 600 }}>{b.delivered > 0 ? b.delivered.toLocaleString() : '—'}</td>
                  <td>
                    {b.openRate > 0
                      ? <span style={{ color: 'var(--green)', fontWeight: 700 }}>{b.openRate}%</span>
                      : <span style={{ color: 'var(--muted)' }}>—</span>
                    }
                  </td>
                  <td>
                    <span className={`badge ${b.status === 'sent' ? 'badge-closed' : 'badge-under-review'}`} style={{ fontSize: '0.7rem' }}>
                      {b.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Confirm Modal */}
      {showConfirm && (
        <div className="modal-overlay" onClick={() => setShowConfirm(false)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-title">⚠️ Confirm Broadcast</div>
            <p style={{ color: 'var(--muted)', marginBottom: '1.25rem', fontSize: '0.9rem' }}>
              This will send a push notification to <strong style={{ color: 'var(--text)' }}>{target}</strong>. This action cannot be undone.
            </p>
            <div style={{ padding: '0.875rem', background: 'rgba(255,59,107,0.08)', borderRadius: 10, border: '1px solid rgba(255,59,107,0.2)', marginBottom: '1.25rem' }}>
              <div style={{ fontWeight: 600, marginBottom: 4 }}>{title}</div>
              <div style={{ fontSize: '0.875rem', color: 'var(--muted)' }}>{message}</div>
            </div>
            <div style={{ display: 'flex', gap: '0.75rem' }}>
              <button className="btn btn-primary" style={{ flex: 1, justifyContent: 'center' }} onClick={handleSend}>
                📡 Confirm & Send
              </button>
              <button className="btn btn-ghost" style={{ flex: 1, justifyContent: 'center' }} onClick={() => setShowConfirm(false)}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
