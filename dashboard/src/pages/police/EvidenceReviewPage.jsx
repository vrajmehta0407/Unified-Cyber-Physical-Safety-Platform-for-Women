import { useEffect, useState } from 'react';
import { evidenceService } from '../../services/incidentService';

export default function EvidenceReviewPage() {
  const [evidence, setEvidence] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    evidenceService.getAll()
      .then(({ data }) => setEvidence(data))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>Evidence Review</h2>
      <div className="card">
        {loading ? <p>Loading...</p> : evidence.length === 0 ? (
          <p style={{ color: 'var(--text-secondary)' }}>No evidence uploaded yet</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border)', textAlign: 'left' }}>
                <th style={{ padding: '0.75rem' }}>Hash (SHA-256)</th>
                <th style={{ padding: '0.75rem' }}>Type</th>
                <th style={{ padding: '0.75rem' }}>Uploaded</th>
                <th style={{ padding: '0.75rem' }}>Status</th>
              </tr>
            </thead>
            <tbody>
              {evidence.map((e) => (
                <tr key={e.id} style={{ borderBottom: '1px solid var(--border)' }}>
                  <td style={{ padding: '0.75rem', fontFamily: 'monospace', fontSize: '0.75rem' }}>{e.hash?.slice(0, 20)}...</td>
                  <td style={{ padding: '0.75rem' }}>{e.mime_type}</td>
                  <td style={{ padding: '0.75rem' }}>{new Date(e.timestamp).toLocaleString()}</td>
                  <td style={{ padding: '0.75rem' }}><span className="badge badge-low">Encrypted</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
