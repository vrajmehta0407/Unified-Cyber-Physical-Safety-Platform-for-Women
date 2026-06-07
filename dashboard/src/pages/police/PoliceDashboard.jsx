import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import StatCard from '../../components/cards/StatCard';
import CrimeTrendChart from '../../components/charts/CrimeTrendChart';
import IncidentTypeChart from '../../components/charts/IncidentTypeChart';
import { fetchDashboardStats } from '../../store/slices/analyticsSlice';
import { fetchActiveSos } from '../../store/slices/sosSlice';

export default function PoliceDashboard() {
  const dispatch = useDispatch();
  const { stats, trend, categories } = useSelector((s) => s.analytics);
  const { activeAlerts, loading } = useSelector((s) => s.sos);

  useEffect(() => {
    dispatch(fetchDashboardStats());
    dispatch(fetchActiveSos());
    const interval = setInterval(() => {
      dispatch(fetchDashboardStats());
      dispatch(fetchActiveSos());
    }, 30000);
    return () => clearInterval(interval);
  }, [dispatch]);

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>Dashboard Overview</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1rem', marginBottom: '1.5rem' }}>
        <StatCard title="Active SOS" value={stats.activeSOS} icon="🚨" color="var(--accent-red)" />
        <StatCard title="Cyber Complaints" value={stats.cyberComplaints} icon="💻" />
        <StatCard title="Total Incidents" value={stats.totalIncidents} icon="📊" />
        <StatCard title="Active Officers" value={stats.activeOfficers} icon="👮" color="var(--accent-green)" />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '1.5rem' }}>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Incident Trend</h3>
          <CrimeTrendChart data={trend} />
        </div>
        <div className="card">
          <h3 style={{ marginBottom: '1rem' }}>Top Complaint Categories</h3>
          <IncidentTypeChart data={categories} />
        </div>
      </div>
      <div className="card">
        <h3 style={{ marginBottom: '1rem' }}>Live SOS Alerts {loading ? '(loading...)' : ''}</h3>
        {activeAlerts.length === 0 ? (
          <p style={{ color: 'var(--text-secondary)' }}>No active SOS alerts</p>
        ) : activeAlerts.map((alert) => (
          <div key={alert.id} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.75rem 0', borderBottom: '1px solid var(--border)' }}>
            <div>
              <strong>{alert.user}</strong>
              <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>{alert.mobile} · {alert.time}</p>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>📍 {alert.lat}, {alert.lng}</p>
            </div>
            <span className={`badge badge-${alert.priority}`}>{alert.priority.toUpperCase()}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
