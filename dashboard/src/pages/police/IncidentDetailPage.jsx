import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { incidentService } from '../../services/incidentService';

export default function IncidentDetailPage() {
  const { id } = useParams();
  const [incident, setIncident] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    incidentService.getById(id).then(({ data }) => {
      setIncident(data);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, [id]);

  if (loading) return <p>Loading...</p>;
  if (!incident) return <p>Incident not found</p>;

  return (
    <div>
      <h2 style={{ marginBottom: '0.5rem' }}>{String(incident.id).slice(0, 13)}...</h2>
      <p style={{ color: 'var(--text-secondary)', marginBottom: '1.5rem' }}>
        {incident.type} · {incident.status} · {incident.user_name}
      </p>
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1rem' }}>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Location</h3>
          <p>📍 {incident.lat}, {incident.lng}</p>
          <p style={{ marginTop: '0.5rem', color: 'var(--text-secondary)' }}>Mobile: {incident.user_mobile}</p>
          <p style={{ color: 'var(--text-secondary)' }}>Silent SOS: {incident.is_silent ? 'Yes' : 'No'}</p>
        </div>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Case Actions</h3>
          <button
            className="btn-primary"
            style={{ width: '100%', marginBottom: '0.5rem' }}
            onClick={async () => {
              await incidentService.update(id, { status: 'resolved' });
              setIncident({ ...incident, status: 'resolved' });
            }}
          >
            Mark Resolved
          </button>
          <button
            className="btn-primary"
            style={{ width: '100%' }}
            onClick={async () => {
              await incidentService.update(id, { status: 'in_progress' });
              setIncident({ ...incident, status: 'in_progress' });
            }}
          >
            Mark In Progress
          </button>
        </div>
      </div>
    </div>
  );
}
