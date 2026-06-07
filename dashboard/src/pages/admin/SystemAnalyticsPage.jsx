import { useEffect, useState } from 'react';
import StatCard from '../../components/cards/StatCard';
import api from '../../config/api';

export default function SystemAnalyticsPage() {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    api.get('/analytics/dashboard').then(({ data }) => setStats(data)).catch(() => {});
  }, []);

  const metrics = [
    { label: 'API Uptime', value: '99.9%', icon: '🟢' },
    { label: 'Avg Response Time', value: '45ms', icon: '⚡' },
    { label: 'Requests Today', value: '2,847', icon: '📡' },
    { label: 'Error Rate', value: '0.12%', icon: '🛡️' },
  ];

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>System Analytics</h2>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1rem', marginBottom: '1.5rem' }}>
        <StatCard title="Total Incidents" value={stats?.active_incidents ?? '—'} icon="🚨" color="var(--accent-red)" />
        <StatCard title="Total Reports" value={stats?.total_reports ?? '—'} icon="📝" color="var(--accent-pink)" />
        <StatCard title="Evidence Stored" value={stats?.total_evidence ?? '—'} icon="📎" color="var(--accent-green)" />
        <StatCard title="Users" value={stats?.total_users ?? '—'} icon="👥" color="var(--accent-purple)" />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '1.5rem' }}>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Performance Metrics</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            {metrics.map((m) => (
              <div key={m.label} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0.75rem', background: 'var(--bg-secondary)', borderRadius: '8px' }}>
                <span>{m.icon} {m.label}</span>
                <span style={{ fontWeight: 700, color: 'var(--accent-green)' }}>{m.value}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Database Summary</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            {[
              { table: 'users', rows: stats?.total_users ?? 0 },
              { table: 'incidents', rows: stats?.active_incidents ?? 0 },
              { table: 'cyber_reports', rows: stats?.total_reports ?? 0 },
              { table: 'evidence', rows: stats?.total_evidence ?? 0 },
              { table: 'notifications', rows: '—' },
              { table: 'audit_logs', rows: '—' },
            ].map((t) => (
              <div key={t.table} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem 0.75rem', borderBottom: '1px solid var(--border)' }}>
                <code style={{ fontSize: '0.875rem' }}>{t.table}</code>
                <span style={{ color: 'var(--text-secondary)' }}>{t.rows} rows</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
