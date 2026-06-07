import { useEffect, useState } from 'react';
import CrimeTrendChart from '../../components/charts/CrimeTrendChart';
import IncidentTypeChart from '../../components/charts/IncidentTypeChart';
import StatCard from '../../components/cards/StatCard';
import api from '../../config/api';
import { fetchDashboardStats } from '../../store/slices/analyticsSlice';
import { useDispatch, useSelector } from 'react-redux';

export default function AnalyticsPage() {
  const dispatch = useDispatch();
  const { stats } = useSelector((s) => s.analytics);
  const [trend, setTrend] = useState([]);
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    dispatch(fetchDashboardStats());
    api.get('/analytics/patterns').then(({ data }) => {
      setTrend(data.incident_trend || []);
      setCategories((data.crime_categories || []).map((c) => ({ name: c.category, value: c.percentage })));
    }).catch(() => {});
  }, [dispatch]);

  return (
    <div>
      <h2 style={{ marginBottom: '1.5rem' }}>Crime Analytics</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1rem', marginBottom: '1.5rem' }}>
        <StatCard title="Active SOS" value={stats.activeSOS} icon="🔴" color="var(--accent-red)" />
        <StatCard title="Cyber Complaints" value={stats.cyberComplaints} icon="💻" />
        <StatCard title="Total Incidents" value={stats.totalIncidents} icon="📊" />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
        <div className="card"><h3 style={{ marginBottom: '1rem' }}>Incident Trend</h3><CrimeTrendChart data={trend.length ? trend.map((t) => ({ month: t.month, count: t.count })) : [{ month: 'N/A', count: 0 }]} /></div>
        <div className="card"><h3 style={{ marginBottom: '1rem' }}>Crime Categories</h3><IncidentTypeChart data={categories.length ? categories : [{ name: 'N/A', value: 1 }]} /></div>
      </div>
    </div>
  );
}
