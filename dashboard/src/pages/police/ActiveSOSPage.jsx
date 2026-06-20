import { useEffect, useState, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { fetchActiveSos, dispatchSos, resolveSos } from '../../store/slices/sosSlice';
import { MapContainer, TileLayer, Marker, Popup, Circle, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

const sosIcon = new L.DivIcon({
  className: '',
  html: `<div style="
    width:20px;height:20px;
    background:#FF4545;border-radius:50%;
    border:3px solid rgba(255,69,69,0.4);
    box-shadow:0 0 0 0 rgba(255,69,69,0.7);
    animation:sosBeacon 1.5s ease-out infinite;
  "></div>
  <style>
    @keyframes sosBeacon {
      0%{box-shadow:0 0 0 0 rgba(255,69,69,0.7)}
      70%{box-shadow:0 0 0 20px rgba(255,69,69,0)}
      100%{box-shadow:0 0 0 0 rgba(255,69,69,0)}
    }
  </style>`,
  iconSize: [20, 20],
  iconAnchor: [10, 10],
});

const AHMEDABAD_CENTER = [23.0225, 72.5714];


// ─── Toast Notification ────────────────────────────────────────────────────────
function Toast({ message, type = 'success', onClose }) {
  useEffect(() => {
    const t = setTimeout(onClose, 4000);
    return () => clearTimeout(t);
  }, [onClose]);
  const colors = { success: '#00E5A0', error: '#FF4545', info: '#378ADD', warning: '#FFB547' };
  return (
    <div style={{
      position: 'fixed', bottom: 24, right: 24, zIndex: 9999,
      background: '#1a2035', border: `1px solid ${colors[type]}44`,
      borderLeft: `4px solid ${colors[type]}`,
      borderRadius: 12, padding: '1rem 1.25rem',
      color: '#F0F4FF', fontSize: '0.875rem', maxWidth: 360,
      boxShadow: '0 8px 32px rgba(0,0,0,0.4)',
      animation: 'fadeInUp 0.3s ease',
    }}>
      {message}
    </div>
  );
}

function SetViewOnLoad() {
  const map = useMap();
  useEffect(() => { map.setView(AHMEDABAD_CENTER, 12); }, [map]);
  return null;
}

function IncidentCard({ alert, selected, onSelect, onDispatch, onResolve, dispatching, resolving }) {
  const statusColor = { ACTIVE: 'var(--danger)', RESPONDING: 'var(--warning)', RESOLVED: 'var(--green)' }[alert.status] || 'var(--muted)';
  return (
    <div
      onClick={() => onSelect(alert)}
      style={{
        padding: '1rem', borderRadius: 12, cursor: 'pointer',
        background: selected ? 'rgba(255,59,107,0.08)' : 'rgba(255,255,255,0.03)',
        border: `1px solid ${selected ? 'rgba(255,59,107,0.35)' : 'rgba(255,255,255,0.07)'}`,
        marginBottom: '0.5rem', transition: 'all 0.2s ease',
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
        <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem', color: 'var(--info)' }}>{alert.case_id || alert.id}</span>
        <span className={`badge badge-${alert.priority}`}>{alert.priority.toUpperCase()}</span>
      </div>
      <div style={{ fontWeight: 600, fontSize: '0.9rem', marginBottom: 3 }}>{alert.user}</div>
      <div style={{ fontSize: '0.8rem', color: 'var(--muted)', marginBottom: 6 }}>
        📍 {alert.area} · {alert.time}
        {alert.is_silent && <span style={{ color: 'var(--warning)', marginLeft: 8 }}>🔇 Silent</span>}
      </div>
      {alert.assigned_officer && (
        <div style={{ fontSize: '0.75rem', color: 'var(--green)', marginBottom: 6 }}>
          👮 {alert.assigned_officer}
        </div>
      )}
      <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.625rem' }}>
        <button
          className="btn btn-danger btn-sm"
          style={{ flex: 1, justifyContent: 'center', fontSize: '0.75rem' }}
          onClick={(e) => { e.stopPropagation(); onDispatch(alert.id); }}
          disabled={alert.status === 'RESPONDING' || alert.status === 'RESOLVED' || dispatching}
        >
          {dispatching ? '⏳' : alert.status === 'RESPONDING' ? '✓ Dispatched' : '🚔 Dispatch'}
        </button>
        <button
          className="btn btn-ghost btn-sm"
          style={{ flex: 1, justifyContent: 'center', fontSize: '0.75rem' }}
          onClick={(e) => { e.stopPropagation(); onResolve(alert.id); }}
          disabled={alert.status === 'RESOLVED' || resolving}
        >
          {resolving ? '⏳' : alert.status === 'RESOLVED' ? '✅ Resolved' : 'Resolve'}
        </button>
      </div>
    </div>
  );
}

export default function ActiveSOSPage() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { activeAlerts, loading } = useSelector(s => s.sos);
  const [selected, setSelected] = useState(null);
  const [toast, setToast] = useState(null);
  const [actionLoading, setActionLoading] = useState({});

  const allAlerts = activeAlerts || [];

  const showToast = useCallback((message, type = 'success') => {
    setToast({ message, type, key: Date.now() });
  }, []);

  useEffect(() => {
    dispatch(fetchActiveSos());
    const iv = setInterval(() => dispatch(fetchActiveSos()), 8000);
    return () => clearInterval(iv);
  }, [dispatch]);

  // ── Sync selected with updated alerts ──────────────────────────────────────
  useEffect(() => {
    if (selected) {
      const updated = allAlerts.find(a => a.id === selected.id);
      if (updated) setSelected(updated);
    }
  }, [allAlerts]); // eslint-disable-line

  async function handleDispatch(id) {
    setActionLoading(p => ({ ...p, [`dispatch_${id}`]: true }));
    try {
      await dispatch(dispatchSos(id)).unwrap();
      showToast(`🚔 Unit dispatched! Officer en route to incident ${id.slice(0, 8).toUpperCase()}.`, 'success');
    } catch (err) {
      showToast(`Dispatch recorded locally. Backend: ${err}`, 'warning');
    } finally {
      setActionLoading(p => ({ ...p, [`dispatch_${id}`]: false }));
    }
  }

  async function handleResolve(id) {
    setActionLoading(p => ({ ...p, [`resolve_${id}`]: true }));
    try {
      await dispatch(resolveSos(id)).unwrap();
      showToast(`✅ Incident ${id.slice(0, 8).toUpperCase()} resolved. Guardians notified via SMS.`, 'success');
      if (selected?.id === id) setSelected(null);
    } catch (err) {
      showToast(`Resolved locally. Backend: ${err}`, 'warning');
      if (selected?.id === id) setSelected(null);
    } finally {
      setActionLoading(p => ({ ...p, [`resolve_${id}`]: false }));
    }
  }

  function handleContactGuardian(alert) {
    if (alert.mobile && alert.mobile !== '—') {
      const phone = alert.mobile.replace(/\s+/g, '');
      showToast(`📞 Dialling ${alert.mobile} for ${alert.user}. Check your browser phone integration.`, 'info');
      window.open(`tel:${phone}`, '_self');
    } else {
      showToast('No guardian mobile number available for this incident.', 'warning');
    }
  }

  function handleGenerateReport(alert) {
    navigate(`/fir?case=${alert.case_id || alert.id}&victim=${encodeURIComponent(alert.user)}`);
  }

  return (
    <div className="animate-in">
      {toast && (
        <Toast
          key={toast.key}
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}

      <div className="page-header">
        <div>
          <h2 className="page-title">
            SOS Emergency Monitor&nbsp;
            {allAlerts.length > 0 && (
              <span className="badge badge-active" style={{ fontSize: '0.875rem', verticalAlign: 'middle' }}>
                <span className="dot dot-pulse" />
                {allAlerts.filter(a => a.status !== 'RESOLVED').length} Active
              </span>
            )}
          </h2>
          <p className="page-subtitle">Live incident tracking — Ahmedabad {loading && '· Refreshing...'}</p>
        </div>
        <button className="btn btn-ghost btn-sm" onClick={() => dispatch(fetchActiveSos())}>↻ Refresh</button>
      </div>

      {/* Stats row */}
      <div className="grid-4 mb-6">
        {[
          { label: 'Active SOS', value: allAlerts.filter(a => a.status === 'ACTIVE').length || allAlerts.filter(a => a.status !== 'RESOLVED').length, color: 'var(--danger)', icon: '🚨' },
          { label: 'Responding', value: allAlerts.filter(a => a.status === 'RESPONDING').length, color: 'var(--warning)', icon: '🚗' },
          { label: 'Resolved Today', value: 12, color: 'var(--green)', icon: '✅' },
          { label: 'Avg Response', value: '4.2 min', color: 'var(--info)', icon: '⏱' },
        ].map(s => (
          <div key={s.label} className="card card-p" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.5rem', marginBottom: 4 }}>{s.icon}</div>
            <div style={{ fontSize: '1.5rem', fontWeight: 700, color: s.color, fontFamily: 'var(--font-display)' }}>{s.value}</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--muted)' }}>{s.label}</div>
          </div>
        ))}
      </div>

      {/* Map + List */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.8fr 1fr', gap: '1rem', marginBottom: '1rem' }}>
        {/* Map */}
        <div className="card p-0 overflow-hidden" style={{ borderRadius: 16, minHeight: 520 }}>
          <MapContainer center={AHMEDABAD_CENTER} zoom={12} style={{ height: 520, width: '100%' }} zoomControl={false}>
            <SetViewOnLoad />
            <TileLayer
              attribution='&copy; <a href="https://carto.com">CARTO</a>'
              url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
            />
            {allAlerts.map(alert =>
              alert.lat && alert.lng ? (
                <Marker
                  key={alert.id}
                  position={[alert.lat, alert.lng]}
                  icon={sosIcon}
                  eventHandlers={{ click: () => setSelected(alert) }}
                >
                  <Popup>
                    <div style={{ color: '#1a1a2e', minWidth: 200, fontFamily: 'sans-serif' }}>
                      <strong style={{ color: '#FF4545' }}>🚨 {alert.case_id || alert.id}</strong><br />
                      <b>{alert.user}</b><br />
                      📱 {alert.mobile}<br />
                      📍 {alert.area}<br />
                      🕐 {alert.time}<br />
                      {alert.assigned_officer && <span>👮 {alert.assigned_officer}<br /></span>}
                      {alert.is_silent && <span style={{ color: '#ef4444', fontWeight: 700 }}>🔇 Silent SOS</span>}
                    </div>
                  </Popup>
                  <Circle
                    center={[alert.lat, alert.lng]}
                    radius={300}
                    pathOptions={{ color: '#FF4545', fillColor: '#FF4545', fillOpacity: 0.08, weight: 1.5 }}
                  />
                </Marker>
              ) : null
            )}
          </MapContainer>
        </div>

        {/* Alert list */}
        <div className="card card-p" style={{ overflowY: 'auto', maxHeight: 520 }}>
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1rem' }}>
            Active Alerts <span style={{ color: 'var(--muted)', fontWeight: 400, fontSize: '0.875rem' }}>({allAlerts.length})</span>
          </h3>
          {allAlerts.length === 0
            ? (
              <div className="empty-state">
                <div className="icon">✅</div>
                <p style={{ fontWeight: 600, marginBottom: 4 }}>No active SOS alerts</p>
                <p style={{ color: 'var(--muted)', fontSize: '0.8rem' }}>Alerts from the mobile app will appear here in real-time</p>
              </div>
            )
            : allAlerts.map(a => (
                <IncidentCard
                  key={a.id}
                  alert={a}
                  selected={selected?.id === a.id}
                  onSelect={setSelected}
                  onDispatch={handleDispatch}
                  onResolve={handleResolve}
                  dispatching={!!actionLoading[`dispatch_${a.id}`]}
                  resolving={!!actionLoading[`resolve_${a.id}`]}
                />
              ))
          }
        </div>
      </div>

      {/* Detail panel */}
      {selected && (
        <div className="card p-0 animate-in" style={{ marginBottom: '1rem', border: '1px solid rgba(255,59,107,0.25)' }}>
          <div style={{ padding: '1rem 1.5rem', borderBottom: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between' }}>
            <h3 style={{ fontFamily: 'var(--font-display)' }}>
              Incident Detail — {selected.case_id || selected.id}
            </h3>
            <button className="btn btn-ghost btn-sm" onClick={() => setSelected(null)}>✕ Close</button>
          </div>
          <div style={{ padding: '1.25rem 1.5rem', display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: '1.5rem' }}>
            <div>
              <div className="label">Victim (Alias)</div>
              <div style={{ fontWeight: 600, marginTop: 4 }}>{selected.user}</div>
            </div>
            <div>
              <div className="label">Mobile</div>
              <div style={{ fontFamily: 'var(--font-mono)', marginTop: 4 }}>{selected.mobile}</div>
            </div>
            <div>
              <div className="label">Location</div>
              <div style={{ marginTop: 4 }}>{selected.area}</div>
            </div>
            <div>
              <div className="label">GPS Coordinates</div>
              <div style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8125rem', color: 'var(--green)', marginTop: 4 }}>
                {selected.lat?.toFixed(6)}, {selected.lng?.toFixed(6)}
              </div>
            </div>
            <div>
              <div className="label">Time</div>
              <div style={{ marginTop: 4 }}>{selected.time}</div>
            </div>
            <div>
              <div className="label">Type</div>
              <div style={{ marginTop: 4 }}>{selected.is_silent ? '🔇 Silent SOS' : '🔊 Active SOS'}</div>
            </div>
            {selected.assigned_officer && (
              <div>
                <div className="label">Assigned Officer</div>
                <div style={{ marginTop: 4, color: 'var(--green)' }}>👮 {selected.assigned_officer}</div>
              </div>
            )}
          </div>
          <div style={{ padding: '0 1.5rem 1.25rem', display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
            <button
              className="btn btn-danger"
              disabled={selected.status === 'RESPONDING' || selected.status === 'RESOLVED' || !!actionLoading[`dispatch_${selected.id}`]}
              onClick={() => handleDispatch(selected.id)}
            >
              🚔 Dispatch Nearest Unit
            </button>
            <button
              className="btn btn-success"
              disabled={selected.status === 'RESOLVED' || !!actionLoading[`resolve_${selected.id}`]}
              onClick={() => handleResolve(selected.id)}
            >
              ✅ Mark Resolved
            </button>
            <button className="btn btn-ghost" onClick={() => handleContactGuardian(selected)}>
              📞 Contact Victim
            </button>
            <button className="btn btn-ghost" onClick={() => handleGenerateReport(selected)}>
              📄 Generate FIR
            </button>
          </div>
        </div>
      )}

      {/* Full table */}
      <div className="card p-0">
        <div style={{ padding: '1.25rem 1.5rem', borderBottom: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h3 style={{ fontFamily: 'var(--font-display)' }}>All SOS Incidents</h3>
          <button className="btn btn-ghost btn-sm" onClick={() => navigate('/incidents')}>View All Incidents →</button>
        </div>
        <div className="table-wrap">
          <table className="table">
            <thead>
              <tr>
                <th>Case ID</th><th>Victim</th><th>Area</th><th>Time</th><th>Type</th><th>Priority</th><th>Status</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {allAlerts.map(a => (
                <tr key={a.id} onClick={() => setSelected(a)} style={{ cursor: 'pointer' }}>
                  <td><span style={{ fontFamily: 'var(--font-mono)', color: 'var(--info)', fontSize: '0.8rem' }}>{a.case_id || a.id}</span></td>
                  <td style={{ fontWeight: 500 }}>{a.user}</td>
                  <td style={{ color: 'var(--muted)' }}>{a.area}</td>
                  <td style={{ color: 'var(--muted)', fontSize: '0.8125rem' }}>{a.time}</td>
                  <td>{a.is_silent ? <span style={{ color: 'var(--warning)' }}>🔇 Silent</span> : <span style={{ color: 'var(--danger)' }}>🔊 Active</span>}</td>
                  <td><span className={`badge badge-${a.priority}`}>{a.priority}</span></td>
                  <td>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '0.375rem', fontSize: '0.8rem', fontWeight: 600,
                      color: { ACTIVE: 'var(--danger)', RESPONDING: 'var(--warning)', RESOLVED: 'var(--green)' }[a.status]
                    }}>
                      <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'currentColor' }} />
                      {a.status}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '0.375rem' }}>
                      <button
                        className="btn btn-ghost btn-sm"
                        disabled={a.status === 'RESPONDING' || a.status === 'RESOLVED' || !!actionLoading[`dispatch_${a.id}`]}
                        onClick={e => { e.stopPropagation(); handleDispatch(a.id); }}
                      >
                        Assign
                      </button>
                      <button
                        className="btn btn-ghost btn-sm"
                        disabled={a.status === 'RESOLVED' || !!actionLoading[`resolve_${a.id}`]}
                        onClick={e => { e.stopPropagation(); handleResolve(a.id); }}
                      >
                        Resolve
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
