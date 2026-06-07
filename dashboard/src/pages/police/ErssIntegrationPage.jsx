import { useEffect, useState } from 'react';
import { integrationService } from '../../services/incidentService';

export default function ErssIntegrationPage() {
  const [dispatches, setDispatches] = useState([]);

  useEffect(() => {
    integrationService.getErss().then(({ data }) => setDispatches(data.active_dispatches || []));
  }, []);

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>ERSS 112 Integration</h2>
      {dispatches.map((d) => (
        <div key={d.incident_id} className="card" style={{ marginBottom: '1rem' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3>{d.incident_id}</h3>
              <p style={{ color: 'var(--text-secondary)' }}>{d.emergency_type?.replace('_', ' ')}</p>
              <p>📍 {d.location?.lat}, {d.location?.lng}</p>
              <p>Team: {d.rescue_team}</p>
            </div>
            <div style={{ textAlign: 'right' }}>
              <span className="badge badge-high">{d.status}</span>
              <p style={{ marginTop: '0.5rem' }}>ETA: {d.eta_minutes} min</p>
              <p>{d.distance_km} km away</p>
            </div>
          </div>
          <button className="btn-primary" style={{ marginTop: '1rem' }}>Track Response</button>
        </div>
      ))}
    </div>
  );
}
