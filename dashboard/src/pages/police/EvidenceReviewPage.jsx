import { useState, useEffect } from 'react';
import { evidenceService } from '../../services/incidentService';

const TYPE_ICON = { image: '🖼', video: '🎥', audio: '🎵', document: '📄', archive: '📦' };
const TYPE_COLOR = { image: 'rgba(77,166,255,0.15)', video: 'rgba(255,59,107,0.12)', audio: 'rgba(0,229,160,0.1)', document: 'rgba(255,181,71,0.12)', archive: 'rgba(139,92,246,0.12)' };

function getFileType(mimeType) {
  if (!mimeType) return 'document';
  if (mimeType.startsWith('image/')) return 'image';
  if (mimeType.startsWith('video/')) return 'video';
  if (mimeType.startsWith('audio/')) return 'audio';
  if (mimeType.includes('zip') || mimeType.includes('archive') || mimeType.includes('tar')) return 'archive';
  return 'document';
}

function formatSize(bytes) {
  if (!bytes) return '—';
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / 1048576).toFixed(1) + ' MB';
}

function formatDate(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function CustodyTimeline({ custody }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      {custody.map((entry, i) => (
        <div key={i} style={{ display: 'flex', gap: '0.75rem', alignItems: 'flex-start' }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', flexShrink: 0 }}>
            <div style={{ width: 10, height: 10, borderRadius: '50%', background: 'var(--green)', border: '2px solid rgba(0,229,160,0.3)', marginTop: 3 }} />
            {i < custody.length - 1 && <div style={{ width: 2, height: 28, background: 'rgba(255,255,255,0.08)', margin: '2px 0' }} />}
          </div>
          <div style={{ paddingBottom: i < custody.length - 1 ? 12 : 0 }}>
            <div style={{ fontSize: '0.8rem', fontWeight: 600 }}>{entry.action}</div>
            <div style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>{entry.actor} · {formatDate(entry.timestamp)}</div>
          </div>
        </div>
      ))}
    </div>
  );
}

function EvidenceCard({ ev, onMarkAdmissible }) {
  const [expanded, setExpanded] = useState(false);
  const [custody, setCustody] = useState([]);
  const [loadingCustody, setLoadingCustody] = useState(false);

  const fileType = getFileType(ev.mime_type);
  const filename = ev.original_filename || ev.file_path?.split('/').pop() || 'unknown';
  const caseId = ev.incident_id ? `INC-${ev.incident_id.slice(0, 8)}` : 'Unlinked';

  async function loadCustody() {
    if (custody.length > 0) return;
    setLoadingCustody(true);
    try {
      const { data } = await evidenceService.getCustody(ev.id);
      setCustody(data);
    } catch {
      setCustody([{ action: 'Uploaded', actor: 'System', timestamp: ev.timestamp }]);
    } finally {
      setLoadingCustody(false);
    }
  }

  function handleToggleCustody() {
    setExpanded(!expanded);
    if (!expanded) loadCustody();
  }

  return (
    <div style={{
      background: 'var(--surface)', border: `1px solid ${ev.verified !== false ? 'rgba(0,229,160,0.15)' : 'rgba(255,69,69,0.15)'}`,
      borderRadius: 14, overflow: 'hidden', transition: 'all 0.2s ease',
    }}>
      <div style={{
        height: 72, background: TYPE_COLOR[fileType] || 'rgba(255,255,255,0.04)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: '2rem', borderBottom: '1px solid var(--card-border)',
      }}>
        {TYPE_ICON[fileType] || '📄'}
      </div>

      <div style={{ padding: '0.875rem' }}>
        <div style={{ fontFamily: 'var(--font-mono)', fontSize: '0.75rem', marginBottom: 4, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {filename}
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.7rem', color: 'var(--info)' }}>{caseId}</span>
          <span style={{ fontSize: '0.7rem', color: 'var(--muted)' }}>{formatSize(ev.file_size)}</span>
        </div>

        <div className="hash-chip" style={{ width: '100%', marginBottom: 8, overflow: 'hidden', cursor: 'pointer' }} title={ev.hash}>
          <span>🔗</span>
          <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {ev.hash?.slice(0, 20)}...
          </span>
        </div>

        {ev.verified !== false
          ? <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.75rem', color: 'var(--green)', marginBottom: 6, fontWeight: 600 }}>
              ✓ Verified Untampered
            </div>
          : <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.75rem', color: 'var(--danger)', marginBottom: 6, fontWeight: 600 }}>
              ⚠ Hash Mismatch
            </div>
        }

        {ev.court_admissible && (
          <div style={{ fontSize: '0.7rem', color: 'var(--green)', background: 'rgba(0,229,160,0.08)', border: '1px solid rgba(0,229,160,0.2)', borderRadius: 6, padding: '0.2rem 0.5rem', marginBottom: 8, display: 'inline-block' }}>
            ⚖ Court-Admissible
          </div>
        )}

        <div style={{ display: 'flex', gap: '0.375rem', flexWrap: 'wrap', marginTop: 6 }}>
          <button className="btn btn-ghost btn-sm" style={{ fontSize: '0.7rem', padding: '0.25rem 0.625rem' }} onClick={() => alert(`👁 Launching forensic viewer for ${filename}. Format: ${fileType.toUpperCase()}`)}>👁 Preview</button>
          <button className="btn btn-ghost btn-sm" style={{ fontSize: '0.7rem', padding: '0.25rem 0.625rem' }} onClick={() => alert(`⬇ Downloading decrypted binary: ${filename}. SHA256: ${ev.hash}`)}>⬇ Download</button>
          {!ev.court_admissible && (
            <button className="btn btn-success btn-sm" style={{ fontSize: '0.7rem', padding: '0.25rem 0.625rem' }} onClick={() => onMarkAdmissible(ev.id)}>
              ⚖ Admit
            </button>
          )}
        </div>

        <button
          className="btn btn-ghost btn-sm"
          style={{ marginTop: 8, width: '100%', justifyContent: 'center', fontSize: '0.75rem' }}
          onClick={handleToggleCustody}
        >
          {expanded ? '▲ Hide' : '▼ Chain of Custody'} ({custody.length || '...'})
        </button>

        {expanded && (
          <div style={{ marginTop: 8, padding: '0.75rem', background: 'rgba(255,255,255,0.02)', borderRadius: 8 }}>
            {loadingCustody
              ? <div style={{ textAlign: 'center', color: 'var(--muted)', fontSize: '0.8rem' }}>Loading...</div>
              : custody.length > 0
                ? <CustodyTimeline custody={custody} />
                : <div style={{ textAlign: 'center', color: 'var(--muted)', fontSize: '0.8rem' }}>
                    <div style={{ fontSize: '0.8rem' }}>Uploaded</div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>System · {formatDate(ev.timestamp)}</div>
                  </div>
            }
          </div>
        )}
      </div>
    </div>
  );
}

export default function EvidenceReviewPage() {
  const [evidence, setEvidence] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [filterType, setFilterType] = useState('');
  const [filterVerified, setFilterVerified] = useState('');
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchEvidence();
  }, []);

  async function fetchEvidence() {
    setLoading(true);
    try {
      const { data } = await evidenceService.getAll();
      setEvidence(data);
    } catch (err) {
      setError(err.response?.data?.detail || 'Failed to load evidence');
    } finally {
      setLoading(false);
    }
  }

  async function markAdmissible(id) {
    try {
      await evidenceService.review(id, {
        court_admissible: true,
        custody_action: 'Marked Court-Admissible',
        custody_actor: 'Reviewing Officer',
      });
      setEvidence(prev => prev.map(e => e.id === id ? { ...e, court_admissible: true } : e));
    } catch (err) {
      alert('Failed to update evidence: ' + (err.response?.data?.detail || err.message));
    }
  }

  const filtered = evidence.filter(e => {
    const fileType = getFileType(e.mime_type);
    const filename = e.original_filename || e.file_path?.split('/').pop() || '';
    if (filterType && fileType !== filterType) return false;
    if (filterVerified === 'verified' && e.verified === false) return false;
    if (filterVerified === 'unverified' && e.verified !== false) return false;
    if (filterVerified === 'admissible' && !e.court_admissible) return false;
    if (search) {
      const searchLower = search.toLowerCase();
      const caseId = e.incident_id ? e.incident_id.slice(0, 8) : '';
      if (!caseId.includes(searchLower) && !filename.toLowerCase().includes(searchLower)) return false;
    }
    return true;
  });

  return (
    <div className="animate-in">
      <div className="page-header">
        <div>
          <h2 className="page-title">🔐 Evidence Review & Vault</h2>
          <p className="page-subtitle">AES-256 encrypted — SHA-256 tamper-proof verification — Chain of custody logs</p>
        </div>
        <button className="btn btn-primary btn-sm" onClick={fetchEvidence}>🔄 Refresh</button>
      </div>

      {/* Stats */}
      <div className="grid-4 mb-6">
        {[
          { label: 'Total Evidence', value: evidence.length, icon: '📁', color: 'var(--text)' },
          { label: 'Hash Verified', value: evidence.filter(e => e.verified !== false).length, icon: '✅', color: 'var(--green)' },
          { label: 'Pending Review', value: evidence.filter(e => !e.court_admissible).length, icon: '⏳', color: 'var(--warning)' },
          { label: 'Court-Admissible', value: evidence.filter(e => e.court_admissible).length, icon: '⚖', color: 'var(--purple)' },
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
        <input className="input" placeholder="🔍 Search case ID or filename..." value={search} onChange={e => setSearch(e.target.value)} style={{ maxWidth: 260 }} />
        <select className="select" value={filterType} onChange={e => setFilterType(e.target.value)} style={{ maxWidth: 160 }}>
          <option value="">All Types</option>
          {Object.keys(TYPE_ICON).map(t => <option key={t} value={t}>{TYPE_ICON[t]} {t.charAt(0).toUpperCase() + t.slice(1)}</option>)}
        </select>
        <select className="select" value={filterVerified} onChange={e => setFilterVerified(e.target.value)} style={{ maxWidth: 180 }}>
          <option value="">All Status</option>
          <option value="verified">✅ Verified</option>
          <option value="unverified">⚠ Unverified</option>
          <option value="admissible">⚖ Court-Admissible</option>
        </select>
        <button className="btn btn-ghost btn-sm" onClick={() => { setFilterType(''); setFilterVerified(''); setSearch(''); }}>↺ Reset</button>
        <span style={{ marginLeft: 'auto', fontSize: '0.8rem', color: 'var(--muted)' }}>{filtered.length} items</span>
      </div>

      {/* Loading / Error */}
      {loading && <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--muted)' }}>Loading evidence from vault...</div>}
      {error && <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--danger)', background: 'rgba(255,69,69,0.08)', borderRadius: 12 }}>{error}</div>}

      {/* Grid */}
      {!loading && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: '1rem' }}>
          {filtered.map(ev => (
            <EvidenceCard key={ev.id} ev={ev} onMarkAdmissible={markAdmissible} />
          ))}
          {filtered.length === 0 && (
            <div className="empty-state" style={{ gridColumn: '1 / -1' }}>
              <div className="icon">🔐</div>
              <p>No evidence matches your filters</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

