import { useState, useEffect } from 'react';
import { reportService, downloadBlob } from '../../services/incidentService';

const CATEGORIES = [
  { value: '', label: 'All Categories' },
  { value: 'cyberstalking', label: '🔍 Cyberstalking' },
  { value: 'harassment', label: '😤 Online Harassment' },
  { value: 'fake_profile', label: '👤 Fake Profile' },
  { value: 'identity_theft', label: '🔐 Identity Theft' },
  { value: 'financial_fraud', label: '💸 Financial Fraud' },
  { value: 'blackmail', label: '🎭 Blackmail/Sextortion' },
  { value: 'deepfake', label: '🤖 Deepfake Abuse' },
  { value: 'phishing', label: '🎣 Phishing' },
  { value: 'sim_swap', label: '📱 SIM Swap' },
  { value: 'morphed_images', label: '💌 Morphed Images' },
  { value: 'vishing', label: '📞 Vishing/Call Fraud' },
  { value: 'social_hacking', label: '🌐 Social Media Hacking' },
];

const CATEGORY_ICONS = {
  cyberstalking: '🔍', harassment: '😤', fake_profile: '👤', identity_theft: '🔐',
  financial_fraud: '💸', blackmail: '🎭', deepfake: '🤖', phishing: '🎣',
  sim_swap: '📱', morphed_images: '💌', vishing: '📞', social_hacking: '🌐',
};

const OFFICERS = ['Unassigned', 'SI Patel R.', 'SI Mehta K.', 'SI Shah D.', 'DSP Sharma A.'];
const STATUSES = ['submitted', 'under-review', 'assigned', 'investigation', 'closed'];

function formatDate(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function DetailPanel({ complaint, onClose, onStatusUpdate }) {
  const [notes, setNotes] = useState('');
  const [officer, setOfficer] = useState(complaint.assigned_officer || 'Unassigned');
  const [status, setStatus] = useState(complaint.status);
  const [saving, setSaving] = useState(false);

  async function handleSave() {
    setSaving(true);
    try {
      await onStatusUpdate(complaint.id, {
        status,
        assigned_officer: officer === 'Unassigned' ? null : officer,
        notes: notes || undefined,
      });
      onClose();
    } catch (err) {
      alert('Failed to update: ' + (err.response?.data?.detail || err.message));
    } finally {
      setSaving(false);
    }
  }

  return (
      <div style={{
        background: 'var(--surface)', border: '1px solid var(--card-border)',
        borderRadius: 20, width: '100%', maxWidth: 720,
        maxHeight: '90vh', overflowY: 'auto',
        animation: 'fadeInUp 0.25s ease',
      }}>
        {/* Toast logic can be added if needed, but we'll use a simple state for downloading */}
        {saving && <div style={{position:'absolute', top: 16, right: 16, background: 'var(--primary)', color: 'white', padding: '4px 12px', borderRadius: 4, fontSize: '0.8rem'}}>Processing...</div>}
      <div style={{
        background: 'var(--surface)', border: '1px solid var(--card-border)',
        borderRadius: 20, width: '100%', maxWidth: 720,
        maxHeight: '90vh', overflowY: 'auto',
        animation: 'fadeInUp 0.25s ease',
      }}>
        <div style={{ padding: '1.5rem', borderBottom: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontFamily: 'var(--font-mono)', color: 'var(--info)', fontSize: '0.8125rem', marginBottom: 4 }}>
              CYB-{complaint.id?.slice(0, 8)?.toUpperCase()}
            </div>
            <h3 style={{ fontFamily: 'var(--font-display)', fontSize: '1.25rem' }}>
              {CATEGORY_ICONS[complaint.category] || '📋'} {complaint.category?.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
            </h3>
            <div style={{ display: 'flex', gap: '0.5rem', marginTop: 8 }}>
              <span className={`badge badge-${complaint.priority || 'medium'}`}>{complaint.priority || 'medium'}</span>
              <span className={`badge badge-${complaint.status}`}>{complaint.status?.replace('-', ' ')}</span>
            </div>
          </div>
          <button className="btn btn-ghost btn-sm" onClick={onClose}>✕ Close</button>
        </div>

        <div style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          <div>
            <div className="label">Incident Description</div>
            <div style={{ marginTop: 6, padding: '0.875rem', background: 'rgba(255,255,255,0.03)', borderRadius: 10, fontSize: '0.9rem', lineHeight: 1.6 }}>
              {complaint.description}
            </div>
          </div>

          {(complaint.accused_platform || complaint.accused_username) && (
            <div>
              <div className="label">Accused Details</div>
              <div style={{ marginTop: 6, display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                {complaint.accused_username && (
                  <div style={{ padding: '0.5rem 0.875rem', background: 'rgba(255,69,69,0.06)', border: '1px solid rgba(255,69,69,0.15)', borderRadius: 8 }}>
                    <div style={{ fontSize: '0.7rem', color: 'var(--muted)' }}>Username</div>
                    <div style={{ fontSize: '0.875rem', fontWeight: 600, marginTop: 2 }}>{complaint.accused_username}</div>
                  </div>
                )}
                {complaint.accused_platform && (
                  <div style={{ padding: '0.5rem 0.875rem', background: 'rgba(255,69,69,0.06)', border: '1px solid rgba(255,69,69,0.15)', borderRadius: 8 }}>
                    <div style={{ fontSize: '0.7rem', color: 'var(--muted)' }}>Platform</div>
                    <div style={{ fontSize: '0.875rem', fontWeight: 600, marginTop: 2 }}>{complaint.accused_platform}</div>
                  </div>
                )}
              </div>
            </div>
          )}

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

          <div className="form-group" style={{ margin: 0 }}>
            <label className="label">Internal Notes (not visible to complainant)</label>
            <textarea
              className="input textarea"
              placeholder="Add investigation notes, case progress, evidence remarks..."
              value={notes}
              onChange={e => setNotes(e.target.value)}
            />
          </div>

          <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
            <button className="btn btn-primary" onClick={handleSave} disabled={saving}>
              {saving ? 'Saving...' : '💾 Save Changes'}
            </button>
            <button className="btn btn-ghost" onClick={async () => {
              try {
                setSaving(true);
                const res = await reportService.generateFir(complaint.id);
                downloadBlob(res.data, `FIR-${complaint.id}.pdf`);
              } catch (e) {
                console.error(e);
              } finally {
                setSaving(false);
              }
            }}>
              🖨 Print FIR Template
            </button>
            <button className="btn btn-ghost" onClick={() => window.print()}>
              📄 Download PDF
            </button>
            <button className="btn btn-ghost" style={{ color: 'var(--warning)', borderColor: 'rgba(255,181,71,0.3)' }} onClick={async () => {
              await onStatusUpdate(complaint.id, { status: 'under-review', notes: (notes ? notes + '\n' : '') + 'FLAGGED FOR CLARIFICATION' });
              onClose();
            }}>
              ⚠ Flag for Clarification
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function ComplaintManagementPage() {
  const [complaints, setComplaints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selected, setSelected] = useState(null);
  const [filterCat, setFilterCat] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterPriority, setFilterPriority] = useState('');
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchComplaints();
  }, []);

  async function fetchComplaints() {
    setLoading(true);
    try {
      const { data } = await reportService.getAll();
      setComplaints(data);
    } catch (err) {
      setError(err.response?.data?.detail || 'Failed to load complaints');
    } finally {
      setLoading(false);
    }
  }

  async function handleStatusUpdate(id, updateData) {
    await reportService.update(id, updateData);
    setComplaints(prev => prev.map(c => c.id === id ? { ...c, ...updateData } : c));
  }

  const filtered = complaints.filter(c => {
    if (filterCat && c.category !== filterCat) return false;
    if (filterStatus && c.status !== filterStatus) return false;
    if (filterPriority && (c.priority || 'medium') !== filterPriority) return false;
    if (search) {
      const searchLower = search.toLowerCase();
      const catLabel = c.category?.replace(/_/g, ' ') || '';
      if (!c.id?.toLowerCase().includes(searchLower) && !catLabel.toLowerCase().includes(searchLower)) return false;
    }
    return true;
  });

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
        <button className="btn btn-primary btn-sm" onClick={fetchComplaints}>🔄 Refresh</button>
      </div>

      {/* Stats */}
      <div className="grid-4 mb-6">
        {[
          { label: 'Total Complaints', value: stats.total, color: 'var(--text)', icon: '📋' },
          { label: 'Pending Review', value: stats.pending, color: 'var(--warning)', icon: '⏳' },
          { label: 'Under Investigation', value: stats.reviewing, color: 'var(--purple)', icon: '🔍' },
          { label: 'Closed', value: stats.closed, color: 'var(--green)', icon: '✅' },
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
        <input className="input" placeholder="🔍 Search complaint ID or category..." value={search} onChange={e => setSearch(e.target.value)} style={{ maxWidth: 240 }} />
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
        <button className="btn btn-ghost btn-sm" onClick={() => { setFilterCat(''); setFilterStatus(''); setFilterPriority(''); setSearch(''); }}>↺ Reset</button>
        <span style={{ marginLeft: 'auto', fontSize: '0.8125rem', color: 'var(--muted)' }}>{filtered.length} results</span>
      </div>

      {loading && <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--muted)' }}>Loading complaints...</div>}
      {error && <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--danger)', background: 'rgba(255,69,69,0.08)', borderRadius: 12 }}>{error}</div>}

      {/* Table */}
      {!loading && (
        <div className="card p-0">
          <div className="table-wrap">
            <table className="table">
              <thead>
                <tr>
                  <th>Complaint #</th><th>Category</th><th>Filed</th>
                  <th>Priority</th><th>Status</th><th>Officer</th><th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map(c => (
                  <tr key={c.id} onClick={() => setSelected(c)} style={{ cursor: 'pointer' }}>
                    <td><span style={{ fontFamily: 'var(--font-mono)', color: 'var(--info)', fontSize: '0.8rem' }}>CYB-{c.id?.slice(0, 8)?.toUpperCase()}</span></td>
                    <td>
                      <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <span>{CATEGORY_ICONS[c.category] || '📋'}</span>
                        <span style={{ fontSize: '0.875rem' }}>{c.category?.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}</span>
                      </span>
                    </td>
                    <td style={{ color: 'var(--muted)', fontSize: '0.75rem', fontFamily: 'var(--font-mono)' }}>{formatDate(c.created_at)}</td>
                    <td><span className={`badge badge-${c.priority || 'medium'}`}>{c.priority || 'medium'}</span></td>
                    <td><span className={`badge badge-${c.status}`}>{c.status?.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}</span></td>
                    <td style={{ fontSize: '0.875rem' }}>
                      {c.assigned_officer
                        ? c.assigned_officer
                        : <span style={{ color: 'var(--warning)', fontSize: '0.8rem' }}>⚠ Unassigned</span>
                      }
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: '0.375rem' }}>
                        <button className="btn btn-primary btn-sm" onClick={e => { e.stopPropagation(); setSelected(c); }}>View</button>
                        <button className="btn btn-ghost btn-sm" onClick={e => { e.stopPropagation(); setSelected(c); }}>Assign</button>
                      </div>
                    </td>
                  </tr>
                ))}
                {filtered.length === 0 && (
                  <tr><td colSpan={7} style={{ textAlign: 'center', padding: '2rem', color: 'var(--muted)' }}>No complaints match filters</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

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
