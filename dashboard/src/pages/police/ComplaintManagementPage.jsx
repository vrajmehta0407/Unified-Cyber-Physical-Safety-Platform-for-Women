import { useEffect, useState } from 'react';
import { reportService } from '../../services/incidentService';

export default function ComplaintManagementPage() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    reportService.getAll()
      .then(({ data }) => setReports(data))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>Cyber Complaints</h2>
      <div className="card">
        {loading ? <p>Loading...</p> : reports.length === 0 ? (
          <p style={{ color: 'var(--text-secondary)' }}>No complaints yet</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border)', textAlign: 'left' }}>
                <th style={{ padding: '0.75rem' }}>ID</th>
                <th style={{ padding: '0.75rem' }}>Category</th>
                <th style={{ padding: '0.75rem' }}>Description</th>
                <th style={{ padding: '0.75rem' }}>Status</th>
              </tr>
            </thead>
            <tbody>
              {reports.map((r) => (
                <tr key={r.id} style={{ borderBottom: '1px solid var(--border)' }}>
                  <td style={{ padding: '0.75rem', fontSize: '0.8rem' }}>{String(r.id).slice(0, 8)}...</td>
                  <td style={{ padding: '0.75rem' }}>{r.category}</td>
                  <td style={{ padding: '0.75rem', maxWidth: '300px' }}>{r.description?.slice(0, 80)}...</td>
                  <td style={{ padding: '0.75rem' }}>{r.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
