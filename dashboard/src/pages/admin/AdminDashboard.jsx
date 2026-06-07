import { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import StatCard from '../../components/cards/StatCard';
import api from '../../config/api';

export default function AdminDashboard() {
  const { user } = useSelector((s) => s.auth);
  const [stats, setStats] = useState(null);
  const [recentUsers, setRecentUsers] = useState([]);

  useEffect(() => {
    api.get('/analytics/dashboard').then(({ data }) => setStats(data)).catch(() => {});
    api.get('/users/list').then(({ data }) => setRecentUsers(data.slice(0, 8))).catch(() => {});
  }, []);

  return (
    <div>
      <h2 style={{ marginBottom: '0.5rem' }}>Admin Dashboard</h2>
      <p style={{ color: 'var(--text-secondary)', marginBottom: '1.5rem' }}>
        Welcome back, {user?.name || 'Admin'}
      </p>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1rem', marginBottom: '1.5rem' }}>
        <StatCard title="Total Users" value={stats?.total_users ?? '—'} icon="👥" color="var(--accent-purple)" />
        <StatCard title="Active Incidents" value={stats?.active_incidents ?? '—'} icon="🚨" color="var(--accent-red)" />
        <StatCard title="Reports Filed" value={stats?.total_reports ?? '—'} icon="📝" color="var(--accent-pink)" />
        <StatCard title="Evidence Items" value={stats?.total_evidence ?? '—'} icon="📎" color="var(--accent-green)" />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Recent Users</h3>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border)', textAlign: 'left' }}>
                <th style={{ padding: '0.5rem' }}>Name</th>
                <th style={{ padding: '0.5rem' }}>Mobile</th>
                <th style={{ padding: '0.5rem' }}>Role</th>
              </tr>
            </thead>
            <tbody>
              {recentUsers.map((u) => (
                <tr key={u.id} style={{ borderBottom: '1px solid var(--border)' }}>
                  <td style={{ padding: '0.5rem' }}>{u.name}</td>
                  <td style={{ padding: '0.5rem', color: 'var(--text-secondary)' }}>{u.mobile}</td>
                  <td style={{ padding: '0.5rem' }}>
                    <span className={`badge badge-${u.role === 'admin' ? 'high' : u.role === 'police' ? 'medium' : 'low'}`}>
                      {u.role}
                    </span>
                  </td>
                </tr>
              ))}
              {recentUsers.length === 0 && (
                <tr><td colSpan={3} style={{ padding: '1rem', textAlign: 'center', color: 'var(--text-secondary)' }}>No users found</td></tr>
              )}
            </tbody>
          </table>
        </div>

        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>System Health</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {[
              { label: 'Backend API', status: 'Operational', color: 'var(--accent-green)' },
              { label: 'AI Engine', status: 'Operational', color: 'var(--accent-green)' },
              { label: 'Database', status: 'Operational', color: 'var(--accent-green)' },
              { label: 'WebSocket', status: 'Operational', color: 'var(--accent-green)' },
            ].map((svc) => (
              <div key={svc.label} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.75rem', background: 'var(--bg-secondary)', borderRadius: '8px' }}>
                <span>{svc.label}</span>
                <span style={{ color: svc.color, fontWeight: 600 }}>● {svc.status}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
