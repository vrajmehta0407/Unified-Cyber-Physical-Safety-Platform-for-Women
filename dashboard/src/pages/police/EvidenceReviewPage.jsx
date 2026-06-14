import { useState } from 'react';

const MOCK_EVIDENCE = [
  { id: 'EVD-0001', filename: 'deepfake_video_01.mp4', type: 'video', size: '42.8 MB', caseId: 'CYB-AHM-0441', uploadedAt: '14 Jun 2026, 11:22', hash: 'a3f8c2d1e9b4f762a3f8c2d1e9b4f762a3f8c2d1e9b4f762a3f8c2d1e9b4f7', verified: true, courtAdmissible: false, custody: [{ who: 'User Upload', when: '14 Jun 11:22', action: 'Uploaded' }, { who: 'System', when: '14 Jun 11:22', action: 'Hash Verified' }] },
  { id: 'EVD-0002', filename: 'screenshot_chat_01.jpg', type: 'image', size: '1.2 MB', caseId: 'CYB-AHM-0441', uploadedAt: '14 Jun 2026, 11:20', hash: 'b4e9d3f2a1c7e895b4e9d3f2a1c7e895b4e9d3f2a1c7e895b4e9d3f2a1c7e8', verified: true, courtAdmissible: true, custody: [{ who: 'User Upload', when: '14 Jun 11:20', action: 'Uploaded' }, { who: 'System', when: '14 Jun 11:20', action: 'Hash Verified' }, { who: 'SI Patel R.', when: '14 Jun 14:00', action: 'Marked Court-Admissible' }] },
  { id: 'EVD-0003', filename: 'chat_export_whatsapp.pdf', type: 'document', size: '856 KB', caseId: 'CYB-AHM-0440', uploadedAt: '14 Jun 2026, 10:48', hash: 'c5f1e4a3b2d8f906c5f1e4a3b2d8f906c5f1e4a3b2d8f906c5f1e4a3b2d8f9', verified: true, courtAdmissible: false, custody: [{ who: 'User Upload', when: '14 Jun 10:48', action: 'Uploaded' }, { who: 'System', when: '14 Jun 10:48', action: 'Hash Verified' }] },
  { id: 'EVD-0004', filename: 'call_recording_fraud.mp3', type: 'audio', size: '18.4 MB', caseId: 'CYB-AHM-0439', uploadedAt: '14 Jun 2026, 09:35', hash: 'd6a2f5b4c3e9g017d6a2f5b4c3e9g017d6a2f5b4c3e9g017d6a2f5b4c3e9g0', verified: false, courtAdmissible: false, custody: [{ who: 'User Upload', when: '14 Jun 09:35', action: 'Uploaded' }] },
  { id: 'EVD-0005', filename: 'fake_profile_screenshots.zip', type: 'archive', size: '3.7 MB', caseId: 'CYB-AHM-0438', uploadedAt: '14 Jun 2026, 08:20', hash: 'e7b3g6c5d4f0h128e7b3g6c5d4f0h128e7b3g6c5d4f0h128e7b3g6c5d4f0h1', verified: true, courtAdmissible: true, custody: [{ who: 'User Upload', when: '14 Jun 08:20', action: 'Uploaded' }, { who: 'System', when: '14 Jun 08:20', action: 'Hash Verified' }, { who: 'SI Mehta K.', when: '14 Jun 12:30', action: 'Reviewed — Marked Admissible' }] },
  { id: 'EVD-0006', filename: 'phishing_url_screenshot.png', type: 'image', size: '580 KB', caseId: 'CYB-AHM-0437', uploadedAt: '13 Jun 2026, 23:05', hash: 'f8c4h7d6e5g1i239f8c4h7d6e5g1i239f8c4h7d6e5g1i239f8c4h7d6e5g1i2', verified: true, courtAdmissible: false, custody: [{ who: 'User Upload', when: '13 Jun 23:05', action: 'Uploaded' }, { who: 'System', when: '13 Jun 23:05', action: 'Hash Verified' }] },
];

const TYPE_ICON = { image: '🖼', video: '🎥', audio: '🎵', document: '📄', archive: '📦' };
const TYPE_COLOR = { image: 'rgba(77,166,255,0.15)', video: 'rgba(255,59,107,0.12)', audio: 'rgba(0,229,160,0.1)', document: 'rgba(255,181,71,0.12)', archive: 'rgba(139,92,246,0.12)' };

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
            <div style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>{entry.who} · {entry.when}</div>
          </div>
        </div>
      ))}
    </div>
  );
}

function EvidenceCard({ ev, onMarkAdmissible, onFlag }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div style={{
      background: 'var(--surface)', border: `1px solid ${ev.verified ? 'rgba(0,229,160,0.15)' : 'rgba(255,69,69,0.15)'}`,
      borderRadius: 14, overflow: 'hidden', transition: 'all 0.2s ease',
    }}>
      {/* Type preview */}
      <div style={{
        height: 72, background: TYPE_COLOR[ev.type] || 'rgba(255,255,255,0.04)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: '2rem', borderBottom: '1px solid var(--card-border)',
      }}>
        {TYPE_ICON[ev.type]}
      </div>

      <div style={{ padding: '0.875rem' }}>
        {/* Filename */}
        <div style={{ fontFamily: 'var(--font-mono)', fontSize: '0.75rem', marginBottom: 4, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {ev.filename}
        </div>

        {/* Case + size */}
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.7rem', color: 'var(--info)' }}>{ev.caseId}</span>
          <span style={{ fontSize: '0.7rem', color: 'var(--muted)' }}>{ev.size}</span>
        </div>

        {/* Hash */}
        <div className="hash-chip" style={{ width: '100%', marginBottom: 8, overflow: 'hidden', cursor: 'pointer' }} title={ev.hash}>
          <span>🔗</span>
          <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {ev.hash.slice(0, 20)}...
          </span>
        </div>

        {/* Verification badge */}
        {ev.verified
          ? <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.75rem', color: 'var(--green)', marginBottom: 6, fontWeight: 600 }}>
              ✓ Verified Untampered
            </div>
          : <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.75rem', color: 'var(--danger)', marginBottom: 6, fontWeight: 600 }}>
              ⚠ Hash Mismatch
            </div>
        }

        {/* Court admissible */}
        {ev.courtAdmissible && (
          <div style={{ fontSize: '0.7rem', color: 'var(--green)', background: 'rgba(0,229,160,0.08)', border: '1px solid rgba(0,229,160,0.2)', borderRadius: 6, padding: '0.2rem 0.5rem', marginBottom: 8, display: 'inline-block' }}>
            ⚖ Court-Admissible
          </div>
        )}

        {/* Actions */}
        <div style={{ display: 'flex', gap: '0.375rem', flexWrap: 'wrap', marginTop: 6 }}>
          <button className="btn btn-ghost btn-sm" style={{ fontSize: '0.7rem', padding: '0.25rem 0.625rem' }} onClick={() => alert(`👁 Launching forensic viewer for ${ev.filename}. Format: ${ev.type.toUpperCase()}`)}>👁 Preview</button>
          <button className="btn btn-ghost btn-sm" style={{ fontSize: '0.7rem', padding: '0.25rem 0.625rem' }} onClick={() => alert(`⬇ Downloading decrypted binary: ${ev.filename}. SHA256: ${ev.hash}`)}>⬇ Download</button>
          {!ev.courtAdmissible && (
            <button className="btn btn-success btn-sm" style={{ fontSize: '0.7rem', padding: '0.25rem 0.625rem' }} onClick={() => onMarkAdmissible(ev.id)}>
              ⚖ Admit
            </button>
          )}
        </div>

        {/* Chain of custody toggle */}
        <button
          className="btn btn-ghost btn-sm"
          style={{ marginTop: 8, width: '100%', justifyContent: 'center', fontSize: '0.75rem' }}
          onClick={() => setExpanded(!expanded)}
        >
          {expanded ? '▲ Hide' : '▼ Chain of Custody'} ({ev.custody.length})
        </button>

        {expanded && (
          <div style={{ marginTop: 8, padding: '0.75rem', background: 'rgba(255,255,255,0.02)', borderRadius: 8 }}>
            <CustodyTimeline custody={ev.custody} />
          </div>
        )}
      </div>
    </div>
  );
}

export default function EvidenceReviewPage() {
  const [evidence, setEvidence] = useState(MOCK_EVIDENCE);
  const [filterType, setFilterType] = useState('');
  const [filterVerified, setFilterVerified] = useState('');
  const [search, setSearch] = useState('');

  const filtered = evidence.filter(e => {
    if (filterType && e.type !== filterType) return false;
    if (filterVerified === 'verified' && !e.verified) return false;
    if (filterVerified === 'unverified' && e.verified) return false;
    if (filterVerified === 'admissible' && !e.courtAdmissible) return false;
    if (search && !e.caseId.includes(search.toUpperCase()) && !e.filename.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  function markAdmissible(id) {
    setEvidence(prev => prev.map(e => e.id === id ? { ...e, courtAdmissible: true, custody: [...e.custody, { who: 'Reviewing Officer', when: new Date().toLocaleString('en-IN'), action: 'Marked Court-Admissible' }] } : e));
  }

  return (
    <div className="animate-in">
      <div className="page-header">
        <div>
          <h2 className="page-title">🔐 Evidence Review & Vault</h2>
          <p className="page-subtitle">AES-256 encrypted — SHA-256 tamper-proof verification — Chain of custody logs</p>
        </div>
        <button className="btn btn-primary btn-sm">📤 Upload Evidence</button>
      </div>

      {/* Stats */}
      <div className="grid-4 mb-6">
        {[
          { label: 'Total Evidence', value: evidence.length, icon: '📁', color: 'var(--text)' },
          { label: 'Hash Verified', value: evidence.filter(e => e.verified).length, icon: '✅', color: 'var(--green)' },
          { label: 'Pending Review', value: evidence.filter(e => !e.courtAdmissible).length, icon: '⏳', color: 'var(--warning)' },
          { label: 'Court-Admissible', value: evidence.filter(e => e.courtAdmissible).length, icon: '⚖', color: 'var(--purple)' },
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

      {/* Grid */}
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
    </div>
  );
}
