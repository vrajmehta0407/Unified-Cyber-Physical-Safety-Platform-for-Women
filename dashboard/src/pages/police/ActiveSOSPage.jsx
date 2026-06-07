import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { fetchActiveSos } from '../../store/slices/sosSlice';
import { MapContainer, TileLayer, Marker, Popup, Circle } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

/* Fix default marker icons in bundled environments */
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

const sosIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34],
});

const AHMEDABAD_CENTER = [23.0225, 72.5714];

export default function ActiveSOSPage() {
  const dispatch = useDispatch();
  const { activeAlerts, loading } = useSelector((s) => s.sos);

  useEffect(() => {
    dispatch(fetchActiveSos());
    const interval = setInterval(() => dispatch(fetchActiveSos()), 15000);
    return () => clearInterval(interval);
  }, [dispatch]);

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>Live SOS Map</h2>
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1rem' }}>
        <div className="card" style={{ padding: 0, overflow: 'hidden', borderRadius: '12px', minHeight: '500px' }}>
          <MapContainer center={AHMEDABAD_CENTER} zoom={12} style={{ height: '500px', width: '100%' }}>
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            {activeAlerts.map((alert) => (
              alert.lat && alert.lng ? (
                <Marker key={alert.id} position={[alert.lat, alert.lng]} icon={sosIcon}>
                  <Popup>
                    <div style={{ color: '#1a1a2e' }}>
                      <strong>🚨 SOS — {alert.user}</strong><br />
                      📱 {alert.mobile}<br />
                      📍 {alert.lat}, {alert.lng}<br />
                      🕐 {alert.time}<br />
                      {alert.is_silent && <span style={{ color: '#ef4444' }}>🔇 Silent SOS</span>}
                    </div>
                  </Popup>
                  <Circle center={[alert.lat, alert.lng]} radius={300} pathOptions={{ color: '#ef4444', fillColor: '#ef4444', fillOpacity: 0.15 }} />
                </Marker>
              ) : null
            ))}
          </MapContainer>
        </div>

        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Active Alerts ({activeAlerts.length}) {loading ? '...' : ''}</h3>
          {activeAlerts.length === 0 ? (
            <p style={{ color: 'var(--text-secondary)' }}>No active SOS</p>
          ) : activeAlerts.map((alert) => (
            <div key={alert.id} style={{ padding: '1rem 0', borderBottom: '1px solid var(--border)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <strong>{alert.user}</strong>
                <span className={`badge badge-${alert.priority}`}>{alert.priority}</span>
              </div>
              <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginTop: '0.25rem' }}>
                📍 {alert.lat}, {alert.lng} · {alert.time}
              </p>
              <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>{alert.mobile}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
