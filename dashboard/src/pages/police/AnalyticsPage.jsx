import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { fetchDashboardStats } from '../../store/slices/analyticsSlice';
import { analyticsService } from '../../services/incidentService';
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from 'recharts';

// Fallback data for when API is unavailable
const FALLBACK_MONTHLY = [
  { month: 'Jul \'25', count: 34 }, { month: 'Aug \'25', count: 41 },
  { month: 'Sep \'25', count: 38 }, { month: 'Oct \'25', count: 52 },
  { month: 'Nov \'25', count: 61 }, { month: 'Dec \'25', count: 78 },
  { month: 'Jan \'26', count: 65 }, { month: 'Feb \'26', count: 73 },
  { month: 'Mar \'26', count: 89 }, { month: 'Apr \'26', count: 95 },
  { month: 'May \'26', count: 108 }, { month: 'Jun \'26', count: 47 },
];

const FALLBACK_CATEGORIES = [
  { name: 'Financial Fraud', value: 28, color: '#FFB547' },
  { name: 'Fake Profile', value: 18, color: '#FF3B6B' },
  { name: 'Cyberstalking', value: 15, color: '#8B5CF6' },
  { name: 'Deepfake Abuse', value: 12, color: '#00E5A0' },
  { name: 'SIM Swap', value: 10, color: '#4DA6FF' },
  { name: 'Phishing', value: 9, color: '#F97316' },
  { name: 'Others', value: 8, color: '#7B8DB0' },
];

const FALLBACK_RESOLUTION = [
  { category: 'Financial Fraud', days: 14.2 },
  { category: 'Deepfake Abuse', days: 21.5 },
  { category: 'Cyberstalking', days: 9.8 },
  { category: 'SIM Swap', days: 6.3 },
  { category: 'Fake Profile', days: 12.1 },
  { category: 'Phishing', days: 4.7 },
  { category: 'Online Harassment', days: 8.4 },
];

const FALLBACK_PLATFORMS = [
  { name: 'Instagram', count: 89, pct: 32 },
  { name: 'WhatsApp', count: 72, pct: 26 },
  { name: 'Telegram', count: 41, pct: 15 },
  { name: 'Facebook', count: 34, pct: 12 },
  { name: 'Phone Call', count: 22, pct: 8 },
  { name: 'Email', count: 19, pct: 7 },
];

const FALLBACK_OFFENDERS = [
  { username: '@suspicious_acc_01', platform: 'Instagram', reports: 7, risk: 94 },
  { username: 'unknown_caller_x', platform: 'Phone', reports: 5, risk: 82 },
  { username: '@fake_nri_2026', platform: 'Facebook', reports: 4, risk: 76 },
];

const CHART_TOOLTIP_STYLE = {
  backgroundColor: '#141929',
  border: '1px solid rgba(255,255,255,0.08)',
  borderRadius: 10,
  color: '#F0F4FF',
  fontFamily: 'Inter, sans-serif',
  fontSize: '0.8125rem',
};

export default function AnalyticsPage() {
  const dispatch = useDispatch();
  const { stats } = useSelector(s => s.analytics);

  const [monthlyTrend, setMonthlyTrend] = useState(FALLBACK_MONTHLY);
  const [categories, setCategories] = useState(FALLBACK_CATEGORIES);
  const [resolutionTime, setResolutionTime] = useState(FALLBACK_RESOLUTION);
  const [platforms, setPlatforms] = useState(FALLBACK_PLATFORMS);
  const [offenders, setOffenders] = useState(FALLBACK_OFFENDERS);
  const [totalComplaints, setTotalComplaints] = useState(0);
  const [loadingCharts, setLoadingCharts] = useState(true);

  useEffect(() => {
    dispatch(fetchDashboardStats());
    fetchComprehensive();
  }, [dispatch]);

  async function fetchComprehensive() {
    try {
      const { data } = await analyticsService.getComprehensive();
      if (data.monthly_trend?.length > 0) setMonthlyTrend(data.monthly_trend);
      if (data.crime_categories?.length > 0) setCategories(data.crime_categories);
      if (data.resolution_time?.length > 0) setResolutionTime(data.resolution_time);
      if (data.platforms?.length > 0) setPlatforms(data.platforms);
      if (data.repeat_offenders?.length > 0) setOffenders(data.repeat_offenders);
      setTotalComplaints(data.total_complaints || 0);
    } catch {
      // Graceful fallback to hardcoded data
    } finally {
      setLoadingCharts(false);
    }
  }

  function exportCSV() {
    const rows = [['Category', 'Count']];
    categories.forEach(c => rows.push([c.name, c.raw_count || c.value]));
    const csv = rows.map(r => r.join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'cybershield_analytics.csv';
    a.click();
    URL.revokeObjectURL(url);
  }

  return (
    <div className="animate-in">
      <div className="page-header">
        <div>
          <h2 className="page-title">📊 Crime Analytics & Intelligence</h2>
          <p className="page-subtitle">Ahmedabad Cyber Crime Cell — Real-time Analytics Dashboard</p>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <button className="btn btn-ghost btn-sm" onClick={exportCSV}>📊 Export CSV</button>
          <button className="btn btn-ghost btn-sm" onClick={() => window.print()}>📄 Export PDF</button>
        </div>
      </div>

      {/* KPI Row */}
      <div className="grid-4 mb-6">
        {[
          { label: 'Total Complaints', value: totalComplaints || stats?.cyberComplaints || 0, icon: '📋', color: 'var(--text)' },
          { label: 'Active SOS', value: stats?.activeSOS || 0, icon: '🚨', color: 'var(--danger)' },
          { label: 'Total Incidents', value: stats?.totalIncidents || 0, icon: '📈', color: 'var(--warning)' },
          { label: 'Active Officers', value: stats?.activeOfficers || 0, icon: '👮', color: 'var(--green)' },
        ].map(s => (
          <div key={s.label} className="card card-p">
            <div style={{ fontSize: '1.5rem', marginBottom: 6 }}>{s.icon}</div>
            <div style={{ fontSize: '1.75rem', fontWeight: 700, color: s.color, fontFamily: 'var(--font-display)', lineHeight: 1 }}>{s.value}</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--muted)', marginTop: 4 }}>{s.label}</div>
          </div>
        ))}
      </div>

      {/* Row 2: Line + Donut */}
      <div className="grid-2 mb-6">
        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>Monthly Complaint Trend</h3>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={monthlyTrend}>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
              <XAxis dataKey="month" tick={{ fill: '#7B8DB0', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#7B8DB0', fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={CHART_TOOLTIP_STYLE} />
              <Line type="monotone" dataKey="count" stroke="#FF3B6B" strokeWidth={2.5} dot={{ fill: '#FF3B6B', strokeWidth: 2, r: 4 }} activeDot={{ r: 6 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>Crime Category Distribution</h3>
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie data={categories} cx="50%" cy="50%" innerRadius={55} outerRadius={90} paddingAngle={3} dataKey="value">
                {categories.map((entry, i) => (
                  <Cell key={i} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip contentStyle={CHART_TOOLTIP_STYLE} formatter={(v) => [`${v}%`, 'Share']} />
            </PieChart>
          </ResponsiveContainer>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem', marginTop: 8 }}>
            {categories.map(c => (
              <span key={c.name} style={{ display: 'flex', alignItems: 'center', gap: '0.3rem', fontSize: '0.7rem', color: 'var(--muted)' }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: c.color, display: 'inline-block' }} />
                {c.name}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* Row 3: Bar chart + Platform list */}
      <div className="grid-2 mb-6">
        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>Avg Resolution Time by Category (days)</h3>
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={resolutionTime} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" horizontal={false} />
              <XAxis type="number" tick={{ fill: '#7B8DB0', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis type="category" dataKey="category" tick={{ fill: '#7B8DB0', fontSize: 10 }} axisLine={false} tickLine={false} width={110} />
              <Tooltip contentStyle={CHART_TOOLTIP_STYLE} formatter={v => [`${v} days`]} />
              <Bar dataKey="days" fill="#8B5CF6" radius={[0, 4, 4, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>Top Reported Platforms</h3>
          {platforms.length > 0 ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.875rem' }}>
              {platforms.map((p, i) => (
                <div key={p.name}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6, fontSize: '0.875rem' }}>
                    <span style={{ fontWeight: 500 }}>{p.name}</span>
                    <span style={{ color: 'var(--muted)' }}>{p.count} reports <span style={{ color: 'var(--accent)' }}>({p.pct}%)</span></span>
                  </div>
                  <div className="progress-bar">
                    <div className="progress-fill" style={{ width: `${p.pct}%`, background: i < 3 ? 'linear-gradient(90deg,#FF3B6B,#8B5CF6)' : 'linear-gradient(90deg,#4DA6FF,#00E5A0)' }} />
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div style={{ textAlign: 'center', color: 'var(--muted)', padding: '2rem', fontSize: '0.875rem' }}>
              No platform data yet. File reports with accused details.
            </div>
          )}
        </div>
      </div>

      {/* Row 4: Repeat offenders */}
      <div className="grid-2">
        <div className="card p-0">
          <div style={{ padding: '1.25rem', borderBottom: '1px solid var(--card-border)' }}>
            <h3 style={{ fontFamily: 'var(--font-display)' }}>🔁 Repeat Offender Detection</h3>
          </div>
          {offenders.length > 0 ? (
            <table className="table">
              <thead>
                <tr>
                  <th>Account</th><th>Platform</th><th>Reports</th><th>Risk Score</th>
                </tr>
              </thead>
              <tbody>
                {offenders.map(r => (
                  <tr key={r.username}>
                    <td><span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem' }}>{r.username}</span></td>
                    <td style={{ color: 'var(--muted)', fontSize: '0.875rem' }}>{r.platform}</td>
                    <td>
                      <span style={{ background: 'rgba(255,59,107,0.12)', border: '1px solid rgba(255,59,107,0.25)', borderRadius: 6, padding: '0.2rem 0.625rem', fontSize: '0.8rem', fontWeight: 700, color: 'var(--accent)' }}>
                        {r.reports}×
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div className="progress-bar" style={{ width: 60 }}>
                          <div className="progress-fill" style={{ width: `${r.risk}%`, background: r.risk > 80 ? 'var(--danger)' : r.risk > 60 ? 'var(--warning)' : 'var(--green)' }} />
                        </div>
                        <span style={{ fontSize: '0.8rem', fontWeight: 700, color: r.risk > 80 ? 'var(--danger)' : r.risk > 60 ? 'var(--warning)' : 'var(--green)' }}>{r.risk}</span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <div style={{ textAlign: 'center', color: 'var(--muted)', padding: '2rem', fontSize: '0.875rem' }}>
              No repeat offenders detected yet. File more reports to build intelligence.
            </div>
          )}
        </div>

        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>📊 Status Breakdown</h3>
          {stats && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {[
                { label: 'Active SOS Alerts', value: stats.activeSOS, color: 'var(--danger)' },
                { label: 'Total Complaints', value: stats.cyberComplaints, color: 'var(--warning)' },
                { label: 'Total Incidents', value: stats.totalIncidents, color: 'var(--info)' },
                { label: 'Active Officers', value: stats.activeOfficers, color: 'var(--green)' },
              ].map(s => (
                <div key={s.label} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.625rem 0.875rem', background: 'rgba(255,255,255,0.02)', borderRadius: 8 }}>
                  <span style={{ fontSize: '0.875rem', color: 'var(--muted)' }}>{s.label}</span>
                  <span style={{ fontWeight: 700, fontFamily: 'var(--font-display)', color: s.color, fontSize: '1.1rem' }}>{s.value}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
