import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { fetchIncidents } from '../../store/slices/incidentSlice';

export default function IncidentListPage() {
  const dispatch = useDispatch();
  const { list, loading, error } = useSelector((s) => s.incidents);

  useEffect(() => {
    dispatch(fetchIncidents());
  }, [dispatch]);

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>Incident Management</h2>
      {error && <p style={{ color: 'var(--accent-red)', marginBottom: '1rem' }}>{error}</p>}
      <div className="card">
        {loading ? (
          <p>Loading incidents...</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border)', textAlign: 'left' }}>
                <th style={{ padding: '0.75rem' }}>Incident ID</th>
                <th style={{ padding: '0.75rem' }}>Complainant</th>
                <th style={{ padding: '0.75rem' }}>Type</th>
                <th style={{ padding: '0.75rem' }}>Status</th>
                <th style={{ padding: '0.75rem' }}>Priority</th>
                <th style={{ padding: '0.75rem' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {list.map((inc) => (
                <tr key={inc.id} style={{ borderBottom: '1px solid var(--border)' }}>
                  <td style={{ padding: '0.75rem', fontSize: '0.8rem' }}>{String(inc.id).slice(0, 8)}...</td>
                  <td style={{ padding: '0.75rem' }}>{inc.user_name}</td>
                  <td style={{ padding: '0.75rem' }}>{inc.type}</td>
                  <td style={{ padding: '0.75rem' }}>{inc.status}</td>
                  <td style={{ padding: '0.75rem' }}>
                    <span className={`badge badge-${inc.type === 'sos' ? 'high' : 'medium'}`}>
                      {inc.type === 'sos' ? 'high' : 'medium'}
                    </span>
                  </td>
                  <td style={{ padding: '0.75rem' }}>
                    <Link to={`/incidents/${inc.id}`} className="btn-primary" style={{ fontSize: '0.75rem', padding: '0.375rem 0.75rem' }}>View</Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
