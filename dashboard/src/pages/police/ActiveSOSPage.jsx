import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
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

const MOCK_ALERTS = [
  { id: 'INC-0892', user: 'Victim #2892', mobile: '+91 98XXX XXXXX', lat: 23.0390, lng: 72.5580, time: '2m ago', priority: 'critical', is_silent: false, status: 'ACTIVE', area: 'Navrangpura' },
  { id: 'INC-0891', user: 'Victim #2891', mobile: '+91 97XXX XXXXX', lat: 23.0056, lng: 72.5888, time: '12m ago', priority: 'high', is_silent: true, status: 'RESPONDING', area: 'Maninagar' },
  { id: 'INC-0890', user: 'Victim #2890', mobile: '+91 96XXX XXXXX', lat: 23.0560, lng: 72.5350, time: '28m ago', priority: 'medium', is_silent: false, status: 'RESPONDING', area: 'Satellite' },
];

function SetViewOnLoad() {
  const map = useMap();
  useEffect(() => {
    map.setView(AHMEDABAD_CENTER, 12);
  }, [map]);
  return null;
}

function IncidentCard({ alert, selected, onSelect, onDispatch, onResolve }) {
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
        <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem', color: 'var(--info)' }}>{alert.id}</span>
        <span className={`badge badge-${alert.priority}`}>{alert.priority.toUpperCase()}</span>
      </div>
      <div style={{ fontWeight: 600, fontSize: '0.9rem', marginBottom: 3 }}>{alert.user}</div>
      <div style={{ fontSize: '0.8rem', color: 'var(--muted)', marginBottom: 6 }}>
        📍 {alert.area} · {alert.time}
        {alert.is_silent && <span style={{ color: 'var(--warning)', marginLeft: 8 }}>🔇 Silent</span>}
      </div>
      <div style={{ display: 'flex', gap: '0.5rem' }}>
        <span style={{ display: 'flex', alignItems: 'center', gap: '0.375rem', fontSize: '0.75rem', color: statusColor, fontWeight: 600 }}>
          <span style={{ width: 7, height: 7, borderRadius: '50%', background: statusColor }} />
          {alert.status}
        </span>
      </div>
      <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.625rem' }}>
        <button
          className="btn btn-danger btn-sm"
          style={{ flex: 1, justifyContent: 'center', fontSize: '0.75rem' }}
          onClick={(e) => {
            e.stopPropagation();
            onDispatch(alert.id);
          }}
          disabled={alert.status === 'RESPONDING' || alert.status === 'RESOLVED'}
        >
          {alert.status === 'RESPONDING' ? 'Dispatched' : 'Dispatch Unit'}
        </button>
        <button
          className="btn btn-ghost btn-sm"
          style={{ flex: 1, justifyContent: 'center', fontSize: '0.75rem' }}
          onClick={(e) => {
            e.stopPropagation();
            onResolve(alert.id);
          }}
          disabled={alert.status === 'RESOLVED'}
        >
          {alert.status === 'RESOLVED' ? 'Resolved' : 'Resolve'}
        </button>
      </div>
    </div>
  );
}

export default function ActiveSOSPage() {
  const dispatch = useDispatch();
  const { activeAlerts, loading } = useSelector(s => s.sos);
  const [selected, setSelected] = useState(null);

  const allAlerts = activeAlerts?.length ? activeAlerts : MOCK_ALERTS;

  useEffect(() => {
    dispatch(fetchActiveSos());
    const iv = setInterval(() => dispatch(fetchActiveSos()), 15000);
    return () => clearInterval(iv);
  }, [dispatch]);

  return (
    <div className="animate-in">
      <div className="page-header">
        <div>
          <h2 className="page-title">
            SOS Emergency Monitor&nbsp;
            {allAlerts.length > 0 && (
              <span className="badge badge-active" style={{ fontSize: '0.875rem', verticalAlign: 'middle' }}>
                <span className="dot dot-pulse" />
                {allAlerts.length} Active
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
          { label: 'Active SOS', value: allAlerts.filter(a => a.status === 'ACTIVE').length || allAlerts.length, color: 'var(--danger)', icon: '🚨' },
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
          <MapContainer
            center={AHMEDABAD_CENTER}
            zoom={12}
            style={{ height: 520, width: '100%' }}
            zoomControl={false}
          >
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
                      <strong style={{ color: '#FF4545' }}>🚨 {alert.id}</strong><br />
                      <b>{alert.user}</b><br />
                      📱 {alert.mobile}<br />
                      📍 {alert.area}<br />
                      🕐 {alert.time}<br />
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
            ? <div className="empty-state"><div className="icon">✅</div><p>No active SOS alerts</p></div>
            : allAlerts.map(a => (
                <IncidentCard
                  key={a.id}
                  alert={a}
                  selected={selected?.id === a.id}
                  onSelect={setSelected}
                  onDispatch={(id) => dispatch(dispatchSos(id))}
                  onResolve={(id) => dispatch(resolveSos(id))}
                />
              ))
          }
        </div>
      </div>

      {/* Detail table */}
      {selected && (
        <div className="card p-0 animate-in" style={{ marginBottom: '1rem', border: '1px solid rgba(255,59,107,0.25)' }}>
          <div style={{ padding: '1rem 1.5rem', borderBottom: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between' }}>
            <h3 style={{ fontFamily: 'var(--font-display)' }}>Incident Detail — {selected.id}</h3>
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
          </div>
          <div style={{ padding: '0 1.5rem 1.25rem', display: 'flex', gap: '0.75rem' }}>
            <button className="btn btn-danger" onClick={() => { dispatch(dispatchSos(selected.id)); alert(`🚨 Emergency Unit Dispatched to ${selected.area} coordinates: ${selected.lat?.toFixed(6)}, ${selected.lng?.toFixed(6)}`); }}>🚔 Dispatch Nearest Unit</button>
            <button className="btn btn-success" onClick={() => { dispatch(resolveSos(selected.id)); alert(`✅ SOS Alert ${selected.id} has been marked as RESOLVED.`); }}>✅ Mark Resolved</button>
            <button className="btn btn-ghost" onClick={() => alert(`📞 Dialing Guardian for ${selected.user}: +91 99999 12345`)}>📞 Contact Guardian</button>
            <button className="btn btn-ghost" onClick={() => alert(`📄 Cyber Crime Incident report generated and signed digitally. Hash logged to CCTNS.`)}>📄 Generate Report</button>
          </div>
        </div>
      )}

      {/* Full table */}
      <div className="card p-0">
        <div style={{ padding: '1.25rem 1.5rem', borderBottom: '1px solid var(--card-border)' }}>
          <h3 style={{ fontFamily: 'var(--font-display)' }}>All SOS Incidents</h3>
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
                  <td><span style={{ fontFamily: 'var(--font-mono)', color: 'var(--info)', fontSize: '0.8rem' }}>{a.id}</span></td>
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
                      <button className="btn btn-ghost btn-sm" onClick={e => { e.stopPropagation(); dispatch(dispatchSos(a.id)); alert(`👮 Case ${a.id} assigned to Cyber Crime Cell Officer Sharma (Badge #AHM-CCC-2026)`); }}>Assign</button>
                      <button className="btn btn-ghost btn-sm" onClick={e => { e.stopPropagation(); dispatch(resolveSos(a.id)); alert(`✅ Case ${a.id} status updated to RESOLVED.`); }}>Resolve</button>
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
