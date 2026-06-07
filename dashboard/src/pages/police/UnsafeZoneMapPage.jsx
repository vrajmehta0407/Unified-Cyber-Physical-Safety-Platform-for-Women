import { useEffect, useState } from 'react';
import { zoneService } from '../../services/incidentService';
import { MapContainer, TileLayer, Circle, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

const AHMEDABAD_CENTER = [23.0225, 72.5714];

const ZONE_COORDS = {
  'Maninagar': [23.0005, 72.6040],
  'Navrangpura': [23.0382, 72.5600],
  'Satellite': [23.0160, 72.5271],
  'Vastrapur': [23.0350, 72.5190],
  'Bapunagar': [23.0450, 72.6200],
};

const RISK_COLORS = {
  high: '#ef4444',
  medium: '#eab308',
  low: '#22c55e',
};

export default function UnsafeZoneMapPage() {
  const [data, setData] = useState(null);

  useEffect(() => {
    zoneService.getUnsafeZones().then(({ data }) => setData(data));
  }, []);

  const zones = data?.zones || [];
  const stats = data?.statistics || {};

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>Unsafe Zone Analytics — Ahmedabad</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1rem', marginBottom: '1.5rem' }}>
        <div className="card"><p>High Risk</p><h2 style={{ color: 'var(--accent-red)' }}>{stats.high_risk_areas || 0}</h2></div>
        <div className="card"><p>Medium Risk</p><h2 style={{ color: 'var(--accent-yellow)' }}>{stats.medium_risk_areas || 0}</h2></div>
        <div className="card"><p>Safe Zones</p><h2 style={{ color: 'var(--accent-green)' }}>{stats.low_risk_areas || 0}</h2></div>
        <div className="card"><p>Total Incidents</p><h2>{stats.total_incidents || 0}</h2></div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1rem' }}>
        <div className="card" style={{ padding: 0, overflow: 'hidden', borderRadius: '12px', minHeight: '450px' }}>
          <MapContainer center={AHMEDABAD_CENTER} zoom={12} style={{ height: '450px', width: '100%' }}>
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            {zones.map((zone) => {
              const coords = ZONE_COORDS[zone.name] || AHMEDABAD_CENTER;
              const color = RISK_COLORS[zone.risk] || RISK_COLORS.low;
              const radius = zone.risk === 'high' ? 800 : zone.risk === 'medium' ? 600 : 400;
              return (
                <Circle
                  key={zone.name}
                  center={coords}
                  radius={radius}
                  pathOptions={{ color, fillColor: color, fillOpacity: 0.25, weight: 2 }}
                >
                  <Popup>
                    <div style={{ color: '#1a1a2e' }}>
                      <strong>{zone.name}</strong><br />
                      Risk: <span style={{ color, fontWeight: 700 }}>{zone.risk.toUpperCase()}</span><br />
                      Incidents: {zone.incidents}
                    </div>
                  </Popup>
                </Circle>
              );
            })}
          </MapContainer>
        </div>

        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Top Hotspots</h3>
          {[...zones].sort((a, b) => b.incidents - a.incidents).map((z, i) => (
            <div key={z.name} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem 0', borderBottom: '1px solid var(--border)' }}>
              <span>{i + 1}. {z.name}</span>
              <span className={`badge badge-${z.risk === 'high' ? 'high' : z.risk === 'medium' ? 'medium' : 'low'}`}>{z.incidents}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
