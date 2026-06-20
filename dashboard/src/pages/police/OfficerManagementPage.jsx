import { useState, useEffect } from 'react';
import api from '../../config/api';

const ROLES = ['officer', 'senior_officer', 'cyber_cell', 'admin'];
const ROLE_COLORS = {
  admin: '#FF3B6B',
  cyber_cell: '#378ADD',
  senior_officer: '#FFB547',
  officer: '#00E5A0',
};

function StatCard({ icon, label, value, color }) {
  return (
    <div style={{
      background: 'rgba(255,255,255,0.04)',
      border: '1px solid rgba(255,255,255,0.08)',
      borderRadius: 14, padding: '1.25rem 1.5rem',
      display: 'flex', alignItems: 'center', gap: '1rem',
    }}>
      <div style={{
        width: 44, height: 44, borderRadius: 12,
        background: color + '22', display: 'flex',
        alignItems: 'center', justifyContent: 'center', fontSize: '1.4rem',
      }}>{icon}</div>
      <div>
        <div style={{ fontSize: '1.6rem', fontWeight: 800, color: color, fontFamily: 'var(--font-mono)' }}>{value}</div>
        <div style={{ fontSize: '0.78rem', color: 'var(--muted)', fontWeight: 600 }}>{label}</div>
      </div>
    </div>
  );
}

function OfficerModal({ officer, onClose, onSaved }) {
  const isEdit = !!officer?.id;
  const [form, setForm] = useState(
    isEdit
      ? { ...officer }
      : { full_name: '', badge_number: '', email: '', mobile: '', role: 'officer', is_on_duty: true }
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  function set(k, v) { setForm(f => ({ ...f, [k]: v })); }

  async function handleSubmit(e) {
    e.preventDefault();
    setSaving(true);
    setError('');
    try {
      if (isEdit) {
        await api.patch(`/officers/${officer.id}`, form);
      } else {
        await api.post('/officers/', { ...form, password: 'TempPass@123' });
      }
      onSaved();
    } catch (err) {
      setError(err.response?.data?.detail || 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div style={{
      position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)',
      zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center',
    }} onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{
        background: '#141929', border: '1px solid rgba(255,255,255,0.1)',
        borderRadius: 16, padding: '2rem', width: 480, maxHeight: '90vh', overflowY: 'auto',
      }}>
        <h2 style={{ margin: '0 0 1.5rem', fontFamily: 'var(--font-display)', color: 'var(--text)' }}>
          {isEdit ? '✏️ Edit Officer' : '➕ Add Officer'}
        </h2>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {[
            { key: 'full_name', label: 'Full Name', required: true },
            { key: 'badge_number', label: 'Badge Number', required: true, mono: true },
            { key: 'email', label: 'Email', type: 'email', required: !isEdit },
            { key: 'mobile', label: 'Mobile (+91)', type: 'tel' },
          ].map(({ key, label, type = 'text', required, mono }) => (
            <div key={key}>
              <label style={{ fontSize: '0.75rem', color: 'var(--muted)', fontWeight: 600, display: 'block', marginBottom: 4 }}>
                {label} {required && <span style={{ color: 'var(--accent)' }}>*</span>}
              </label>
              <input
                type={type}
                required={required}
                value={form[key] || ''}
                onChange={e => set(key, e.target.value)}
                style={{
                  width: '100%', padding: '0.6rem 1rem',
                  background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
                  borderRadius: 8, color: 'var(--text)', fontSize: '0.9rem',
                  fontFamily: mono ? 'var(--font-mono)' : 'inherit', boxSizing: 'border-box',
                }}
              />
            </div>
          ))}

          <div>
            <label style={{ fontSize: '0.75rem', color: 'var(--muted)', fontWeight: 600, display: 'block', marginBottom: 4 }}>
              ROLE <span style={{ color: 'var(--accent)' }}>*</span>
            </label>
            <select
              value={form.role}
              onChange={e => set('role', e.target.value)}
              style={{
                width: '100%', padding: '0.6rem 1rem',
                background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
                borderRadius: 8, color: 'var(--text)', fontSize: '0.9rem',
              }}
            >
              {ROLES.map(r => (
                <option key={r} value={r}>{r.replace('_', ' ').replace(/\b\w/g, c => c.toUpperCase())}</option>
              ))}
            </select>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <label style={{ fontSize: '0.85rem', color: 'var(--text)', fontWeight: 500, cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={form.is_on_duty || false}
                onChange={e => set('is_on_duty', e.target.checked)}
                style={{ marginRight: 8, accentColor: 'var(--green)' }}
              />
              Currently On Duty
            </label>
          </div>

          {!isEdit && (
            <div style={{
              padding: '0.75rem 1rem', background: 'rgba(255,181,71,0.1)',
              border: '1px solid rgba(255,181,71,0.2)', borderRadius: 8,
              fontSize: '0.8rem', color: '#FFB547',
            }}>
              ⚠️ Temporary password <code>TempPass@123</code> will be set. Officer must change on first login.
            </div>
          )}

          {error && (
            <div style={{ padding: '0.75rem', background: 'rgba(255,69,69,0.1)', borderRadius: 8, color: '#FF4545', fontSize: '0.85rem' }}>
              ✗ {error}
            </div>
          )}

          <div style={{ display: 'flex', gap: '0.75rem', marginTop: '0.5rem' }}>
            <button type="button" onClick={onClose} style={{
              flex: 1, padding: '0.7rem', background: 'rgba(255,255,255,0.06)',
              border: '1px solid rgba(255,255,255,0.1)', borderRadius: 8,
              color: 'var(--muted)', fontWeight: 700, cursor: 'pointer',
            }}>
              Cancel
            </button>
            <button type="submit" disabled={saving} style={{
              flex: 2, padding: '0.7rem',
              background: 'linear-gradient(135deg, var(--accent), #c0284a)',
              border: 'none', borderRadius: 8,
              color: '#fff', fontWeight: 700, cursor: 'pointer',
              opacity: saving ? 0.7 : 1,
            }}>
              {saving ? 'Saving...' : isEdit ? 'Save Changes' : 'Add Officer'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function OfficerManagementPage() {
  const [officers, setOfficers] = useState([]);
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterRole, setFilterRole] = useState('all');
  const [filterDuty, setFilterDuty] = useState('all');
  const [modal, setModal] = useState(null); // null | 'add' | officer object
  const [toast, setToast] = useState(null);
  const [deleting, setDeleting] = useState(null);

  function showToast(msg, type = 'success') {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3200);
  }

  async function loadData() {
    setLoading(true);
    try {
      const [offRes, statRes] = await Promise.all([
        api.get('/officers/'),
        api.get('/officers/stats'),
      ]);
      setOfficers(offRes.data || []);
      setStats(statRes.data || {});
    } catch {
      showToast('Failed to load officers', 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { loadData(); }, []);

  async function toggleDuty(officer) {
    try {
      await api.patch(`/officers/${officer.id}`, { is_on_duty: !officer.is_on_duty });
      setOfficers(prev => prev.map(o =>
        o.id === officer.id ? { ...o, is_on_duty: !o.is_on_duty } : o
      ));
      showToast(`${officer.full_name} is now ${!officer.is_on_duty ? 'On Duty' : 'Off Duty'}`);
    } catch {
      showToast('Update failed', 'error');
    }
  }

  async function handleDelete(officer) {
    if (!window.confirm(`Remove ${officer.full_name}? This cannot be undone.`)) return;
    setDeleting(officer.id);
    try {
      await api.delete(`/officers/${officer.id}`);
      setOfficers(prev => prev.filter(o => o.id !== officer.id));
      showToast(`${officer.full_name} removed`);
    } catch {
      showToast('Delete failed', 'error');
    } finally {
      setDeleting(null);
    }
  }

  const filtered = officers.filter(o => {
    const matchSearch = !search ||
      o.full_name?.toLowerCase().includes(search.toLowerCase()) ||
      o.badge_number?.toLowerCase().includes(search.toLowerCase()) ||
      o.email?.toLowerCase().includes(search.toLowerCase());
    const matchRole = filterRole === 'all' || o.role === filterRole;
    const matchDuty = filterDuty === 'all' ||
      (filterDuty === 'on' && o.is_on_duty) ||
      (filterDuty === 'off' && !o.is_on_duty);
    return matchSearch && matchRole && matchDuty;
  });

  return (
    <div style={{ padding: '2rem', maxWidth: 1200, margin: '0 auto' }}>
      {/* Toast */}
      {toast && (
        <div style={{
          position: 'fixed', top: 24, right: 24, zIndex: 9999,
          background: toast.type === 'error' ? '#FF4545' : '#00E5A0',
          color: '#0A0F1E', padding: '0.75rem 1.5rem',
          borderRadius: 10, fontWeight: 700, fontSize: '0.9rem',
          boxShadow: '0 4px 20px rgba(0,0,0,0.4)',
        }}>
          {toast.type === 'error' ? '✗' : '✓'} {toast.msg}
        </div>
      )}

      {/* Modal */}
      {modal && (
        <OfficerModal
          officer={modal === 'add' ? null : modal}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); loadData(); showToast('Officer saved!'); }}
        />
      )}

      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '2rem' }}>
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12,
            background: 'rgba(55,138,221,0.15)', display: 'flex',
            alignItems: 'center', justifyContent: 'center', fontSize: '1.5rem',
          }}>👮</div>
          <div>
            <h1 style={{ margin: 0, fontSize: '1.5rem', fontFamily: 'var(--font-display)', color: 'var(--text)' }}>
              Officer Management
            </h1>
            <p style={{ margin: 0, fontSize: '0.875rem', color: 'var(--muted)' }}>
              Manage the Ahmedabad Cyber Crime Cell roster
            </p>
          </div>
        </div>
        <button
          onClick={() => setModal('add')}
          style={{
            padding: '0.65rem 1.5rem',
            background: 'linear-gradient(135deg, var(--accent), #c0284a)',
            color: '#fff', border: 'none', borderRadius: 10,
            fontWeight: 700, fontSize: '0.9rem', cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 8,
            boxShadow: '0 4px 16px rgba(255,59,107,0.3)',
          }}
        >
          ➕ Add Officer
        </button>
      </div>

      {/* Stats Row */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1rem', marginBottom: '2rem' }}>
        <StatCard icon="👮" label="Total Officers" value={stats.total_officers ?? officers.length} color="#378ADD" />
        <StatCard icon="🟢" label="On Duty" value={stats.on_duty ?? officers.filter(o => o.is_on_duty).length} color="#00E5A0" />
        <StatCard icon="🔴" label="Off Duty" value={stats.off_duty ?? officers.filter(o => !o.is_on_duty).length} color="#FF4545" />
        <StatCard icon="📋" label="Total Cases" value={stats.total_cases_assigned ?? 0} color="#FFB547" />
      </div>

      {/* Filters */}
      <div style={{
        display: 'flex', gap: '1rem', flexWrap: 'wrap', marginBottom: '1.5rem',
        background: 'rgba(255,255,255,0.03)', padding: '1rem',
        borderRadius: 12, border: '1px solid rgba(255,255,255,0.06)',
      }}>
        <input
          type="text"
          placeholder="🔍 Search by name, badge, email..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          style={{
            flex: 1, minWidth: 220, padding: '0.6rem 1rem',
            background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
            borderRadius: 8, color: 'var(--text)', fontSize: '0.875rem',
          }}
        />
        <select
          value={filterRole}
          onChange={e => setFilterRole(e.target.value)}
          style={{
            padding: '0.6rem 1rem', background: 'rgba(255,255,255,0.06)',
            border: '1px solid rgba(255,255,255,0.1)',
            borderRadius: 8, color: 'var(--text)', fontSize: '0.875rem',
          }}
        >
          <option value="all">All Roles</option>
          {ROLES.map(r => <option key={r} value={r}>{r.replace('_', ' ')}</option>)}
        </select>
        <select
          value={filterDuty}
          onChange={e => setFilterDuty(e.target.value)}
          style={{
            padding: '0.6rem 1rem', background: 'rgba(255,255,255,0.06)',
            border: '1px solid rgba(255,255,255,0.1)',
            borderRadius: 8, color: 'var(--text)', fontSize: '0.875rem',
          }}
        >
          <option value="all">All Status</option>
          <option value="on">On Duty</option>
          <option value="off">Off Duty</option>
        </select>
        <span style={{ fontSize: '0.8rem', color: 'var(--muted)', alignSelf: 'center' }}>
          {filtered.length} officer{filtered.length !== 1 ? 's' : ''}
        </span>
      </div>

      {/* Officers Table */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '4rem', color: 'var(--muted)' }}>
          <div style={{ fontSize: '2rem', animation: 'spin 1s linear infinite', display: 'inline-block' }}>⟳</div>
          <p>Loading roster...</p>
        </div>
      ) : filtered.length === 0 ? (
        <div style={{
          textAlign: 'center', padding: '4rem',
          background: 'rgba(255,255,255,0.02)', borderRadius: 16,
          border: '1px dashed rgba(255,255,255,0.1)',
        }}>
          <div style={{ fontSize: '2.5rem' }}>👮‍♂️</div>
          <p style={{ color: 'var(--muted)' }}>No officers found matching your filters.</p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
          {filtered.map(officer => {
            const roleColor = ROLE_COLORS[officer.role] || '#7B8DB0';
            const initials = officer.full_name?.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase() || 'OF';
            return (
              <div
                key={officer.id}
                style={{
                  display: 'flex', alignItems: 'center', gap: '1rem',
                  background: 'rgba(255,255,255,0.04)',
                  border: '1px solid rgba(255,255,255,0.08)',
                  borderRadius: 12, padding: '1rem 1.25rem',
                  transition: 'all 0.2s ease',
                }}
                onMouseEnter={e => e.currentTarget.style.borderColor = 'rgba(255,255,255,0.15)'}
                onMouseLeave={e => e.currentTarget.style.borderColor = 'rgba(255,255,255,0.08)'}
              >
                {/* Avatar */}
                <div style={{
                  width: 44, height: 44, borderRadius: '50%',
                  background: roleColor + '22', border: `2px solid ${roleColor}44`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontWeight: 800, fontSize: '0.875rem', color: roleColor, flexShrink: 0,
                }}>
                  {initials}
                </div>

                {/* Name + badge */}
                <div style={{ flex: '0 0 200px' }}>
                  <div style={{ fontWeight: 700, color: 'var(--text)', fontSize: '0.95rem' }}>
                    {officer.full_name}
                  </div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--muted)', fontFamily: 'var(--font-mono)' }}>
                    Badge #{officer.badge_number}
                  </div>
                </div>

                {/* Email */}
                <div style={{ flex: 1, fontSize: '0.8rem', color: 'var(--muted)', minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  {officer.email}
                </div>

                {/* Role chip */}
                <div style={{
                  padding: '0.3rem 0.8rem', borderRadius: 20, fontSize: '0.75rem',
                  fontWeight: 700, background: roleColor + '22', color: roleColor,
                  border: `1px solid ${roleColor}44`, flexShrink: 0,
                }}>
                  {officer.role?.replace('_', ' ')}
                </div>

                {/* Cases count */}
                <div style={{ textAlign: 'center', flexShrink: 0, width: 60 }}>
                  <div style={{ fontWeight: 700, fontSize: '1rem', color: 'var(--text)', fontFamily: 'var(--font-mono)' }}>
                    {officer.cases_assigned || 0}
                  </div>
                  <div style={{ fontSize: '0.65rem', color: 'var(--muted)' }}>CASES</div>
                </div>

                {/* Duty toggle */}
                <button
                  onClick={() => toggleDuty(officer)}
                  style={{
                    padding: '0.35rem 0.8rem', borderRadius: 20, fontSize: '0.75rem',
                    fontWeight: 700, border: 'none', cursor: 'pointer',
                    background: officer.is_on_duty ? 'rgba(0,229,160,0.15)' : 'rgba(255,69,69,0.1)',
                    color: officer.is_on_duty ? '#00E5A0' : '#FF4545',
                    transition: 'all 0.2s ease', flexShrink: 0,
                  }}
                >
                  {officer.is_on_duty ? '🟢 On Duty' : '🔴 Off Duty'}
                </button>

                {/* Actions */}
                <div style={{ display: 'flex', gap: '0.5rem', flexShrink: 0 }}>
                  <button
                    onClick={() => setModal(officer)}
                    title="Edit officer"
                    style={{
                      width: 34, height: 34, borderRadius: 8,
                      background: 'rgba(55,138,221,0.1)', border: '1px solid rgba(55,138,221,0.2)',
                      color: '#378ADD', cursor: 'pointer', fontSize: '0.9rem',
                    }}
                  >✏️</button>
                  <button
                    onClick={() => handleDelete(officer)}
                    disabled={deleting === officer.id}
                    title="Remove officer"
                    style={{
                      width: 34, height: 34, borderRadius: 8,
                      background: 'rgba(255,69,69,0.1)', border: '1px solid rgba(255,69,69,0.2)',
                      color: '#FF4545', cursor: 'pointer', fontSize: '0.9rem',
                      opacity: deleting === officer.id ? 0.5 : 1,
                    }}
                  >🗑️</button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
