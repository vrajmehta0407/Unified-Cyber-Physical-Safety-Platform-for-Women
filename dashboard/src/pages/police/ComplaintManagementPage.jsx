import { useState, useEffect } from 'react';

const CATEGORIES = [
  { value: '', label: 'All Categories' },
  { value: 'cyberstalking', label: '🔍 Cyberstalking', icon: '🔍' },
  { value: 'harassment', label: '😤 Online Harassment', icon: '😤' },
  { value: 'fake_profile', label: '👤 Fake Profile', icon: '👤' },
  { value: 'identity_theft', label: '🔐 Identity Theft', icon: '🔐' },
  { value: 'financial_fraud', label: '💸 Financial Fraud', icon: '💸' },
  { value: 'blackmail', label: '🎭 Blackmail/Sextortion', icon: '🎭' },
  { value: 'deepfake', label: '🤖 Deepfake Abuse', icon: '🤖' },
  { value: 'phishing', label: '🎣 Phishing', icon: '🎣' },
  { value: 'sim_swap', label: '📱 SIM Swap', icon: '📱' },
  { value: 'morphed_images', label: '💌 Morphed Images', icon: '💌' },
  { value: 'vishing', label: '📞 Vishing/Call Fraud', icon: '📞' },
  { value: 'social_hacking', label: '🌐 Social Media Hacking', icon: '🌐' },
];

const MOCK_COMPLAINTS = [
  { id: 'CYB-AHM-0441', category: 'deepfake', icon: '🤖', categoryLabel: 'Deepfake Abuse', victim: 'Victim #2892', filed: '14 Jun 2026, 11:18', priority: 'critical', status: 'under-review', officer: 'Unassigned', description: 'AI-generated deepfake video of victim circulating on WhatsApp groups. Used for blackmail. Evidence: 3 videos, 2 screenshots.', accused: { platform: 'WhatsApp', username: 'Unknown' } },
  { id: 'CYB-AHM-0440', category: 'sim_swap', icon: '📱', categoryLabel: 'SIM Swap Fraud', victim: 'Victim #2891', filed: '14 Jun 2026, 10:45', priority: 'high', status: 'submitted', officer: 'Unassigned', description: 'Victim received call from someone claiming to be Airtel support, requested OTP, SIM was swapped within hours.', accused: { phone: '+91 7XXXXXXX', platform: 'Phone Call' } },
  { id: 'CYB-AHM-0439', category: 'financial_fraud', icon: '💸', categoryLabel: 'Financial Fraud', victim: 'Victim #2890', filed: '14 Jun 2026, 09:30', priority: 'high', status: 'assigned', officer: 'SI Patel R.', description: 'Fraudulent investment app. Victim invested ₹85,000. App disappeared after 30 days.', accused: { username: 'InvestPro2026', platform: 'Google Play / Instagram' } },
  { id: 'CYB-AHM-0438', category: 'fake_profile', icon: '👤', categoryLabel: 'Fake Profile', victim: 'Victim #2889', filed: '14 Jun 2026, 08:15', priority: 'medium', status: 'investigation', officer: 'SI Mehta K.', description: 'Fake Instagram profile using victim\'s photos, contacting her contacts for money.', accused: { username: '@priya_real_2026', platform: 'Instagram' } },
  { id: 'CYB-AHM-0437', category: 'cyberstalking', icon: '🔍', categoryLabel: 'Cyberstalking', victim: 'Victim #2888', filed: '13 Jun 2026, 22:50', priority: 'high', status: 'assigned', officer: 'SI Shah D.', description: 'Continuous monitoring of victim\'s social profiles, showing up at locations she posts about.', accused: { username: 'Suspect tracked via IP', platform: 'Instagram, Facebook' } },
  { id: 'CYB-AHM-0436', category: 'phishing', icon: '🎣', categoryLabel: 'Phishing', victim: 'Victim #2887', filed: '13 Jun 2026, 18:30', priority: 'low', status: 'closed', officer: 'SI Patel R.', description: 'Phishing email imitating SBI. Victim clicked link, entered credentials.', accused: { platform: 'Email — domain: sbi-update.xyz' } },
];

const OFFICERS = ['Unassigned', 'SI Patel R.', 'SI Mehta K.', 'SI Shah D.', 'DSP Sharma A.'];
const STATUSES = ['submitted', 'under-review', 'assigned', 'investigation', 'closed'];

function DetailPanel({ complaint, onClose, onStatusUpdate }) {
  const [notes, setNotes] = useState('');
  const [officer, setOfficer] = useState(complaint.officer);
  const [status, setStatus] = useState(complaint.status);

  return (
    <div style={{
      position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.75)',
      backdropFilter: 'blur(4px)', zIndex: 1000,
      display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '1rem',
    }}>
      <div style={{
        background: 'var(--surface)', border: '1px solid var(--card-border)',
        borderRadius: 20, width: '100%', maxWidth: 720,
        maxHeight: '90vh', overflowY: 'auto',
        animation: 'fadeInUp 0.25s ease',
      }}>
        {/* Header */}
        <div style={{ padding: '1.5rem', borderBottom: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontFamily: 'var(--font-mono)', color: 'var(--info)', fontSize: '0.8125rem', marginBottom: 4 }}>{complaint.id}</div>
            <h3 style={{ fontFamily: 'var(--font-display)', fontSize: '1.25rem' }}>
              {complaint.icon} {complaint.categoryLabel}
            </h3>
            <div style={{ display: 'flex', gap: '0.5rem', marginTop: 8 }}>
              <span className={`badge badge-${complaint.priority}`}>{complaint.priority}</span>
              <span className={`badge badge-${complaint.status}`}>{complaint.status.replace('-', ' ')}</span>
            </div>
          </div>
          <button className="btn btn-ghost btn-sm" onClick={onClose}>✕ Close</button>
        </div>

        <div style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          {/* Description */}
          <div>
            <div className="label">Incident Description</div>
            <div style={{ marginTop: 6, padding: '0.875rem', background: 'rgba(255,255,255,0.03)', borderRadius: 10, fontSize: '0.9rem', lineHeight: 1.6 }}>
              {complaint.description}
            </div>
          </div>

          {/* Accused details */}
          {complaint.accused && (
            <div>
              <div className="label">Accused Details</div>
              <div style={{ marginTop: 6, display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                {Object.entries(complaint.accused).map(([k, v]) => (
                  <div key={k} style={{ padding: '0.5rem 0.875rem', background: 'rgba(255,69,69,0.06)', border: '1px solid rgba(255,69,69,0.15)', borderRadius: 8 }}>
                    <div style={{ fontSize: '0.7rem', color: 'var(--muted)', textTransform: 'capitalize' }}>{k}</div>
                    <div style={{ fontSize: '0.875rem', fontWeight: 600, marginTop: 2 }}>{v}</div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Evidence placeholder */}
          <div>
            <div className="label">Linked Evidence</div>
            <div style={{ marginTop: 6, display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
              {['screenshot_001.jpg', 'video_evidence.mp4', 'chat_export.pdf'].map(f => (
                <div key={f} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.375rem 0.75rem', background: 'rgba(0,229,160,0.07)', border: '1px solid rgba(0,229,160,0.2)', borderRadius: 8 }}>
                  <span style={{ fontSize: '0.75rem' }}>✅</span>
                  <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.75rem', color: 'var(--green)' }}>{f}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Assignment */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
            <div className="form-group" style={{ margin: 0 }}>
              <label className="label">Assign Officer</label>
              <select className="select" value={officer} onChange={e => setOfficer(e.target.value)}>
                {OFFICERS.map(o => <option key={o} value={o}>{o}</option>)}
              </select>
            </div>
            <div className="form-group" style={{ margin: 0 }}>
              <label className="label">Update Status</label>
              <select className="select" value={status} onChange={e => setStatus(e.target.value)}>
                {STATUSES.map(s => <option key={s} value={s}>{s.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}</option>)}
              </select>
            </div>
          </div>

          {/* Internal notes */}
          <div className="form-group" style={{ margin: 0 }}>
            <label className="label">Internal Notes (not visible to complainant)</label>
            <textarea
              className="input textarea"
              placeholder="Add investigation notes, case progress, evidence remarks..."
              value={notes}
              onChange={e => setNotes(e.target.value)}
            />
          </div>

          {/* Actions */}
          <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
            <button className="btn btn-primary" onClick={() => { onStatusUpdate(complaint.id, status, officer, notes); onClose(); }}>
              💾 Save Changes
            </button>
            <button className="btn btn-ghost" onClick={() => alert(`🖨 Printing FIR Template for ${complaint.id}...`)}>
              🖨 Print FIR Template
            </button>
            <button className="btn btn-ghost" onClick={() => alert(`📄 Downloading Forensic Complaint Case File PDF for ${complaint.id}...`)}>
              📄 Download PDF
            </button>
            <button className="btn btn-ghost" style={{ color: 'var(--warning)', borderColor: 'rgba(255,181,71,0.3)' }} onClick={() => alert(`⚠ Verification request sent to user. Notification triggered.`)}>
              ⚠ Flag for Clarification
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function ComplaintManagementPage() {
  const [complaints, setComplaints] = useState(MOCK_COMPLAINTS);
  const [selected, setSelected] = useState(null);
  const [filterCat, setFilterCat] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterPriority, setFilterPriority] = useState('');
  const [search, setSearch] = useState('');

  const filtered = complaints.filter(c => {
    if (filterCat && c.category !== filterCat) return false;
    if (filterStatus && c.status !== filterStatus) return false;
    if (filterPriority && c.priority !== filterPriority) return false;
    if (search && !c.id.toLowerCase().includes(search.toLowerCase()) && !c.categoryLabel.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  function handleStatusUpdate(id, status, officer, notes) {
    setComplaints(prev => prev.map(c => c.id === id ? { ...c, status, officer } : c));
  }

  const stats = {
    total: complaints.length,
    pending: complaints.filter(c => c.status === 'submitted').length,
    reviewing: complaints.filter(c => ['under-review', 'assigned', 'investigation'].includes(c.status)).length,
    closed: complaints.filter(c => c.status === 'closed').length,
  };

  return (
    <div className="animate-in">
      <div className="page-header">
        <div>
          <h2 className="page-title">Cyber Complaint Management</h2>
          <p className="page-subtitle">All registered cybercrime complaints — Ahmedabad Jurisdiction</p>
        </div>
        <button className="btn btn-primary btn-sm" onClick={() => alert('Add Complaint wizard triggered. Complainant info form opened.')}>+ New Complaint</button>
      </div>

      {/* Stats */}
      <div className="grid-4 mb-6">
        {[
          { label: 'Total Complaints', value: stats.total, color: 'var(--text)', icon: '📋' },
          { label: 'Pending Review', value: stats.pending, color: 'var(--warning)', icon: '⏳' },
          { label: 'Under Investigation', value: stats.reviewing, color: 'var(--purple)', icon: '🔍' },
          { label: 'Closed This Month', value: stats.closed, color: 'var(--green)', icon: '✅' },
        ].map(s => (
          <div key={s.label} className="card card-p" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.5rem' }}>{s.icon}</div>
            <div style={{ fontSize: '1.75rem', fontWeight: 700, color: s.color, fontFamily: 'var(--font-display)' }}>{s.value}</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--muted)' }}>{s.label}</div>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="filter-bar">
        <input
          className="input"
          placeholder="🔍 Search complaint ID or category..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          style={{ maxWidth: 240 }}
        />
        <select className="select" value={filterCat} onChange={e => setFilterCat(e.target.value)} style={{ maxWidth: 200 }}>
          {CATEGORIES.map(c => <option key={c.value} value={c.value}>{c.label}</option>)}
        </select>
        <select className="select" value={filterStatus} onChange={e => setFilterStatus(e.target.value)} style={{ maxWidth: 160 }}>
          <option value="">All Status</option>
          {STATUSES.map(s => <option key={s} value={s}>{s.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}</option>)}
        </select>
        <select className="select" value={filterPriority} onChange={e => setFilterPriority(e.target.value)} style={{ maxWidth: 140 }}>
          <option value="">All Priority</option>
          {['low', 'medium', 'high', 'critical'].map(p => <option key={p} value={p}>{p.charAt(0).toUpperCase() + p.slice(1)}</option>)}
        </select>
        <button className="btn btn-ghost btn-sm" onClick={() => { setFilterCat(''); setFilterStatus(''); setFilterPriority(''); setSearch(''); }}>
          ↺ Reset
        </button>
        <span style={{ marginLeft: 'auto', fontSize: '0.8125rem', color: 'var(--muted)' }}>{filtered.length} results</span>
      </div>

      {/* Table */}
      <div className="card p-0">
        <div className="table-wrap">
          <table className="table">
            <thead>
              <tr>
                <th>Complaint #</th><th>Category</th><th>Victim</th><th>Filed</th>
                <th>Priority</th><th>Status</th><th>Officer</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(c => (
                <tr key={c.id} onClick={() => setSelected(c)} style={{ cursor: 'pointer' }}>
                  <td><span style={{ fontFamily: 'var(--font-mono)', color: 'var(--info)', fontSize: '0.8rem' }}>{c.id}</span></td>
                  <td>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <span>{c.icon}</span><span style={{ fontSize: '0.875rem' }}>{c.categoryLabel}</span>
                    </span>
                  </td>
                  <td style={{ color: 'var(--muted)', fontSize: '0.875rem' }}>{c.victim}</td>
                  <td style={{ color: 'var(--muted)', fontSize: '0.75rem', fontFamily: 'var(--font-mono)' }}>{c.filed}</td>
                  <td><span className={`badge badge-${c.priority}`}>{c.priority}</span></td>
                  <td><span className={`badge badge-${c.status}`}>{c.status.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}</span></td>
                  <td style={{ fontSize: '0.875rem' }}>
                    {c.officer === 'Unassigned'
                      ? <span style={{ color: 'var(--warning)', fontSize: '0.8rem' }}>⚠ Unassigned</span>
                      : c.officer}
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '0.375rem' }}>
                      <button className="btn btn-primary btn-sm" onClick={e => { e.stopPropagation(); setSelected(c); }}>View</button>
                      <button className="btn btn-ghost btn-sm" onClick={e => e.stopPropagation()}>Assign</button>
                    </div>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr><td colSpan={8} style={{ textAlign: 'center', padding: '2rem', color: 'var(--muted)' }}>No complaints match filters</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {selected && (
        <DetailPanel
          complaint={selected}
          onClose={() => setSelected(null)}
          onStatusUpdate={handleStatusUpdate}
        />
      )}
    </div>
  );
}
