import { useEffect, useState } from 'react';
import { integrationService } from '../../services/incidentService';

export default function CctnsIntegrationPage() {
  const [data, setData] = useState(null);

  useEffect(() => {
    integrationService.getCctns('demo-report').then(({ data }) => setData(data));
  }, []);

  if (!data) return <p>Loading CCTNS integration...</p>;

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>CCTNS Integration</h2>
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1rem' }}>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Case Progress</h3>
          {data.steps?.map((step, i) => (
            <div key={step.label} style={{ display: 'flex', gap: '0.75rem', marginBottom: '1rem' }}>
              <div style={{ width: 12, height: 12, borderRadius: '50%', background: step.done ? 'var(--accent-purple)' : 'var(--border)', marginTop: 4 }} />
              <div>
                <p style={{ fontWeight: 500 }}>{step.label}</p>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Step {i + 1}</p>
              </div>
            </div>
          ))}
        </div>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Case Details</h3>
          <p><strong>CCTNS ID:</strong> {data.cctns_id}</p>
          <p><strong>FIR Number:</strong> {data.fir_number}</p>
          <p><strong>Police Station:</strong> {data.police_station}</p>
          <p><strong>Status:</strong> {data.status}</p>
          <p><strong>Assigned IO:</strong> {data.assigned_io}</p>
          <p style={{ marginTop: '0.5rem' }}><strong>Sections:</strong> {data.legal_sections?.join(', ')}</p>
        </div>
      </div>
    </div>
  );
}
