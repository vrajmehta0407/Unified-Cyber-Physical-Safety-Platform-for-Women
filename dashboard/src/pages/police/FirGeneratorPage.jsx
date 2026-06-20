import { useState, useEffect, useRef } from 'react';
import { useSearchParams } from 'react-router-dom';
import api from '../../config/api';

const STATUS_LABELS = {
  draft: { label: 'Draft', color: '#7B8DB0' },
  'under-review': { label: 'Under Review', color: '#FFB547' },
  signed: { label: 'Signed', color: '#378ADD' },
  submitted: { label: 'Submitted to Court', color: '#00E5A0' },
};

export default function FirGeneratorPage() {
  const [searchParams] = useSearchParams();
  const preloadId = searchParams.get('report_id');

  const [complaints, setComplaints] = useState([]);
  const [selectedId, setSelectedId] = useState(preloadId || '');
  const [complaint, setComplaint] = useState(null);
  const [firStatus, setFirStatus] = useState('draft');
  const [officerNote, setOfficerNote] = useState('');
  const [generating, setGenerating] = useState(false);
  const [loading, setLoading] = useState(false);
  const [pdfUrl, setPdfUrl] = useState(null);
  const [nccrpXml, setNccrpXml] = useState(null);
  const [signature, setSignature] = useState('');
  const [toast, setToast] = useState(null);
  const canvasRef = useRef(null);
  const isDrawing = useRef(false);

  function showToast(msg, type = 'success') {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3500);
  }

  // Load complaint list
  useEffect(() => {
    api.get('/reports/').then(r => {
      setComplaints(r.data || []);
    }).catch(() => {});
  }, []);

  // Load selected complaint
  useEffect(() => {
    if (!selectedId) { setComplaint(null); return; }
    setLoading(true);
    api.get(`/reports/${selectedId}`)
      .then(r => {
        setComplaint(r.data);
        setFirStatus(r.data.fir_status || 'draft');
      })
      .catch(() => showToast('Could not load complaint', 'error'))
      .finally(() => setLoading(false));
  }, [selectedId]);

  async function handleGenerate() {
    if (!selectedId) return;
    setGenerating(true);
    setPdfUrl(null);
    try {
      const r = await api.post(`/reports/${selectedId}/fir`, {}, {
        responseType: 'blob',
      });
      const blob = new Blob([r.data], { type: 'application/pdf' });
      const url = URL.createObjectURL(blob);
      setPdfUrl(url);
      setFirStatus('under-review');
      showToast('FIR PDF generated successfully!');
    } catch {
      showToast('PDF generation failed', 'error');
    } finally {
      setGenerating(false);
    }
  }

  function handleDownload() {
    if (!pdfUrl || !complaint) return;
    const a = document.createElement('a');
    a.href = pdfUrl;
    a.download = `FIR_${complaint.complaint_number || selectedId}.pdf`;
    a.click();
  }

  function buildNccrpXml() {
    if (!complaint) return;
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<NCCRP_FIR>
  <Header>
    <Version>1.0</Version>
    <Source>CyberShield-AHM</Source>
    <GeneratedAt>${new Date().toISOString()}</GeneratedAt>
  </Header>
  <Complaint>
    <ComplaintNumber>${complaint.complaint_number}</ComplaintNumber>
    <Category>${complaint.category}</Category>
    <Status>${complaint.status}</Status>
    <Priority>${complaint.priority}</Priority>
    <Description><![CDATA[${complaint.description}]]></Description>
    <FiledAt>${complaint.created_at}</FiledAt>
  </Complaint>
  <Accused>
    <Platform>${complaint.accused_platform || ''}</Platform>
    <Username>${complaint.accused_username || ''}</Username>
    <Phone>${complaint.accused_phone || ''}</Phone>
  </Accused>
  <Officer>
    <Note><![CDATA[${officerNote}]]></Note>
    <FIRStatus>${firStatus}</FIRStatus>
    <Signature>${signature}</Signature>
  </Officer>
</NCCRP_FIR>`;
    const blob = new Blob([xml], { type: 'application/xml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `NCCRP_${complaint.complaint_number}.xml`;
    a.click();
    showToast('NCCRP XML exported!');
  }

  // Signature canvas
  function startDraw(e) {
    isDrawing.current = true;
    const ctx = canvasRef.current?.getContext('2d');
    if (!ctx) return;
    ctx.beginPath();
    const rect = canvasRef.current.getBoundingClientRect();
    ctx.moveTo(e.clientX - rect.left, e.clientY - rect.top);
  }
  function draw(e) {
    if (!isDrawing.current) return;
    const ctx = canvasRef.current?.getContext('2d');
    if (!ctx) return;
    const rect = canvasRef.current.getBoundingClientRect();
    ctx.lineTo(e.clientX - rect.left, e.clientY - rect.top);
    ctx.strokeStyle = '#F0F4FF';
    ctx.lineWidth = 2;
    ctx.stroke();
  }
  function endDraw() {
    isDrawing.current = false;
    if (canvasRef.current) {
      setSignature(canvasRef.current.toDataURL());
    }
  }
  function clearSig() {
    const ctx = canvasRef.current?.getContext('2d');
    if (!ctx) return;
    ctx.clearRect(0, 0, canvasRef.current.width, canvasRef.current.height);
    setSignature('');
  }

  const statusInfo = STATUS_LABELS[firStatus] || STATUS_LABELS.draft;

  return (
    <div style={{ padding: '2rem', maxWidth: 1100, margin: '0 auto' }}>
      {/* Toast */}
      {toast && (
        <div style={{
          position: 'fixed', top: 24, right: 24, zIndex: 9999,
          background: toast.type === 'error' ? '#FF4545' : '#00E5A0',
          color: '#0A0F1E', padding: '0.75rem 1.5rem',
          borderRadius: 10, fontWeight: 700, fontSize: '0.9rem',
          boxShadow: '0 4px 20px rgba(0,0,0,0.4)',
          animation: 'slideIn 0.3s ease',
        }}>
          {toast.type === 'error' ? '✗' : '✓'} {toast.msg}
        </div>
      )}

      {/* Page Header */}
      <div style={{ marginBottom: '2rem' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '0.5rem' }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12,
            background: 'rgba(255,59,107,0.15)', display: 'flex',
            alignItems: 'center', justifyContent: 'center', fontSize: '1.5rem',
          }}>📄</div>
          <div>
            <h1 style={{ margin: 0, fontSize: '1.5rem', fontFamily: 'var(--font-display)', color: 'var(--text)' }}>
              FIR Generator
            </h1>
            <p style={{ margin: 0, fontSize: '0.875rem', color: 'var(--muted)' }}>
              Generate, sign and export First Information Reports in standard Ahmedabad Police format
            </p>
          </div>
          {complaint && (
            <div style={{
              marginLeft: 'auto', padding: '0.35rem 0.9rem',
              borderRadius: 20, fontWeight: 700, fontSize: '0.78rem',
              background: statusInfo.color + '22', color: statusInfo.color,
              border: `1px solid ${statusInfo.color}44`,
            }}>
              {statusInfo.label}
            </div>
          )}
        </div>
      </div>

      {/* Complaint Selector */}
      <div className="glass-card" style={{ padding: '1.5rem', marginBottom: '1.5rem' }}>
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'flex-end', flexWrap: 'wrap' }}>
          <div style={{ flex: 1, minWidth: 280 }}>
            <label style={{ fontSize: '0.78rem', color: 'var(--muted)', fontWeight: 600, display: 'block', marginBottom: 6 }}>
              SELECT COMPLAINT
            </label>
            <select
              value={selectedId}
              onChange={e => setSelectedId(e.target.value)}
              style={{
                width: '100%', padding: '0.6rem 1rem',
                background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
                borderRadius: 8, color: 'var(--text)', fontSize: '0.9rem',
                fontFamily: 'var(--font-mono)',
              }}
            >
              <option value="">-- Select a complaint --</option>
              {complaints.map(c => (
                <option key={c.id} value={c.id}>
                  {c.complaint_number} · {c.category} · {c.status}
                </option>
              ))}
            </select>
          </div>
          <button
            onClick={handleGenerate}
            disabled={!selectedId || generating}
            style={{
              padding: '0.6rem 1.5rem', background: 'var(--accent)',
              color: '#fff', border: 'none', borderRadius: 8,
              fontWeight: 700, fontSize: '0.9rem', cursor: 'pointer',
              opacity: (!selectedId || generating) ? 0.5 : 1,
              display: 'flex', alignItems: 'center', gap: 8,
              transition: 'all 0.3s ease',
            }}
          >
            {generating ? (
              <><span style={{ animation: 'spin 1s linear infinite', display: 'inline-block' }}>⟳</span> Generating...</>
            ) : (
              <>📄 Generate FIR PDF</>
            )}
          </button>
        </div>
      </div>

      {loading && (
        <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--muted)' }}>
          <div style={{ fontSize: '2rem', animation: 'spin 1s linear infinite', display: 'inline-block' }}>⟳</div>
          <p>Loading complaint data...</p>
        </div>
      )}

      {complaint && !loading && (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>

          {/* Left: Complaint Detail */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            <div className="glass-card" style={{ padding: '1.5rem' }}>
              <h3 style={{ margin: '0 0 1rem', fontFamily: 'var(--font-display)', fontSize: '1rem', color: 'var(--text)' }}>
                📋 Complaint Details
              </h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                {[
                  ['Case Number', complaint.complaint_number],
                  ['Category', complaint.category],
                  ['Status', complaint.status],
                  ['Priority', complaint.priority],
                  ['Filed On', complaint.created_at ? new Date(complaint.created_at).toLocaleString('en-IN') : '—'],
                ].map(([label, val]) => (
                  <div key={label} style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.05)', paddingBottom: '0.5rem' }}>
                    <span style={{ fontSize: '0.8rem', color: 'var(--muted)' }}>{label}</span>
                    <span style={{
                      fontSize: '0.85rem', fontWeight: 600,
                      fontFamily: label === 'Case Number' ? 'var(--font-mono)' : 'inherit',
                      color: label === 'Case Number' ? 'var(--accent)' : 'var(--text)',
                    }}>{val || '—'}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="glass-card" style={{ padding: '1.5rem' }}>
              <h3 style={{ margin: '0 0 1rem', fontFamily: 'var(--font-display)', fontSize: '1rem', color: 'var(--text)' }}>
                📝 Incident Description
              </h3>
              <p style={{ fontSize: '0.875rem', color: 'var(--muted)', lineHeight: 1.7, margin: 0 }}>
                {complaint.description || 'No description provided.'}
              </p>
            </div>

            {(complaint.accused_platform || complaint.accused_username) && (
              <div className="glass-card" style={{ padding: '1.5rem' }}>
                <h3 style={{ margin: '0 0 1rem', fontFamily: 'var(--font-display)', fontSize: '1rem', color: 'var(--text)' }}>
                  🎯 Accused Details
                </h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                  {[
                    ['Platform', complaint.accused_platform],
                    ['Username', complaint.accused_username],
                    ['Phone', complaint.accused_phone],
                    ['Profile URL', complaint.accused_profile_url],
                  ].filter(([, v]) => v).map(([label, val]) => (
                    <div key={label} style={{ display: 'flex', gap: '1rem' }}>
                      <span style={{ fontSize: '0.8rem', color: 'var(--muted)', width: 100 }}>{label}:</span>
                      <span style={{ fontSize: '0.85rem', color: 'var(--text)', fontWeight: 600 }}>{val}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Right: Officer Actions */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            {/* FIR Status */}
            <div className="glass-card" style={{ padding: '1.5rem' }}>
              <h3 style={{ margin: '0 0 1rem', fontFamily: 'var(--font-display)', fontSize: '1rem', color: 'var(--text)' }}>
                ⚖️ FIR Status
              </h3>
              <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                {Object.entries(STATUS_LABELS).map(([key, { label, color }]) => (
                  <button
                    key={key}
                    onClick={() => setFirStatus(key)}
                    style={{
                      padding: '0.4rem 0.9rem', borderRadius: 20,
                      border: `2px solid ${firStatus === key ? color : 'transparent'}`,
                      background: firStatus === key ? color + '22' : 'rgba(255,255,255,0.04)',
                      color: firStatus === key ? color : 'var(--muted)',
                      fontWeight: 700, fontSize: '0.78rem', cursor: 'pointer',
                      transition: 'all 0.2s ease',
                    }}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>

            {/* Officer Note */}
            <div className="glass-card" style={{ padding: '1.5rem' }}>
              <h3 style={{ margin: '0 0 1rem', fontFamily: 'var(--font-display)', fontSize: '1rem', color: 'var(--text)' }}>
                🖊️ Officer Notes (Internal)
              </h3>
              <textarea
                value={officerNote}
                onChange={e => setOfficerNote(e.target.value)}
                placeholder="Add internal investigation notes, observations, or instructions..."
                rows={5}
                style={{
                  width: '100%', padding: '0.75rem', resize: 'vertical',
                  background: 'rgba(255,255,255,0.04)',
                  border: '1px solid rgba(255,255,255,0.1)',
                  borderRadius: 8, color: 'var(--text)', fontSize: '0.875rem',
                  fontFamily: 'var(--font-body)', lineHeight: 1.6,
                  boxSizing: 'border-box',
                }}
              />
            </div>

            {/* Digital Signature */}
            <div className="glass-card" style={{ padding: '1.5rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                <h3 style={{ margin: 0, fontFamily: 'var(--font-display)', fontSize: '1rem', color: 'var(--text)' }}>
                  ✍️ Digital Signature
                </h3>
                <button
                  onClick={clearSig}
                  style={{
                    fontSize: '0.75rem', color: 'var(--muted)', background: 'none',
                    border: 'none', cursor: 'pointer', textDecoration: 'underline',
                  }}
                >
                  Clear
                </button>
              </div>
              <canvas
                ref={canvasRef}
                width={340}
                height={100}
                onMouseDown={startDraw}
                onMouseMove={draw}
                onMouseUp={endDraw}
                onMouseLeave={endDraw}
                style={{
                  border: '1px dashed rgba(255,255,255,0.2)',
                  borderRadius: 8, cursor: 'crosshair',
                  display: 'block', width: '100%', touchAction: 'none',
                  background: 'rgba(255,255,255,0.02)',
                }}
              />
              <p style={{ fontSize: '0.72rem', color: 'var(--muted)', margin: '0.5rem 0 0' }}>
                Draw your signature above
              </p>
            </div>

            {/* Action Buttons */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {pdfUrl && (
                <button
                  onClick={handleDownload}
                  style={{
                    padding: '0.75rem 1.5rem',
                    background: 'linear-gradient(135deg, var(--accent), #c0284a)',
                    color: '#fff', border: 'none', borderRadius: 10,
                    fontWeight: 700, fontSize: '0.95rem', cursor: 'pointer',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                    boxShadow: '0 4px 16px rgba(255,59,107,0.35)',
                    transition: 'transform 0.2s ease',
                  }}
                  onMouseEnter={e => e.target.style.transform = 'translateY(-1px)'}
                  onMouseLeave={e => e.target.style.transform = 'none'}
                >
                  ⬇️ Download FIR PDF
                </button>
              )}
              {!pdfUrl && (
                <button
                  onClick={handleGenerate}
                  disabled={generating}
                  style={{
                    padding: '0.75rem 1.5rem',
                    background: 'linear-gradient(135deg, var(--accent), #c0284a)',
                    color: '#fff', border: 'none', borderRadius: 10,
                    fontWeight: 700, fontSize: '0.95rem', cursor: 'pointer',
                    opacity: generating ? 0.6 : 1,
                    display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                    transition: 'all 0.2s ease',
                  }}
                >
                  {generating ? '⟳ Generating...' : '📄 Generate FIR PDF'}
                </button>
              )}
              <button
                onClick={buildNccrpXml}
                style={{
                  padding: '0.75rem 1.5rem',
                  background: 'rgba(55,138,221,0.15)',
                  color: '#378ADD', border: '1px solid rgba(55,138,221,0.3)',
                  borderRadius: 10, fontWeight: 700, fontSize: '0.95rem', cursor: 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                  transition: 'all 0.2s ease',
                }}
              >
                🔗 Export NCCRP XML
              </button>
              <button
                onClick={() => showToast('WhatsApp share initiated via Twilio')}
                style={{
                  padding: '0.75rem 1.5rem',
                  background: 'rgba(0,229,160,0.1)',
                  color: 'var(--green)', border: '1px solid rgba(0,229,160,0.2)',
                  borderRadius: 10, fontWeight: 700, fontSize: '0.95rem', cursor: 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                  transition: 'all 0.2s ease',
                }}
              >
                📱 Share via WhatsApp
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Empty state */}
      {!complaint && !loading && (
        <div style={{
          textAlign: 'center', padding: '5rem 2rem',
          background: 'rgba(255,255,255,0.02)',
          borderRadius: 16, border: '1px dashed rgba(255,255,255,0.1)',
        }}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>📄</div>
          <h3 style={{ fontFamily: 'var(--font-display)', color: 'var(--text)', marginBottom: '0.5rem' }}>
            Select a Complaint
          </h3>
          <p style={{ color: 'var(--muted)', maxWidth: 400, margin: '0 auto' }}>
            Choose a complaint from the dropdown above to generate its FIR in standard Ahmedabad Police format, sign it digitally, and export to NCCRP XML.
          </p>
        </div>
      )}

      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes slideIn { from { transform: translateX(20px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        .glass-card {
          background: rgba(255,255,255,0.04);
          border: 1px solid rgba(255,255,255,0.08);
          border-radius: 14px;
          backdrop-filter: blur(12px);
        }
      `}</style>
    </div>
  );
}
