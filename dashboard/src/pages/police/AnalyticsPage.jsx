import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { fetchDashboardStats } from '../../store/slices/analyticsSlice';
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
} from 'recharts';

const MONTHLY_TREND = [
  { month: 'Jul \'25', count: 34 }, { month: 'Aug \'25', count: 41 },
  { month: 'Sep \'25', count: 38 }, { month: 'Oct \'25', count: 52 },
  { month: 'Nov \'25', count: 61 }, { month: 'Dec \'25', count: 78 },
  { month: 'Jan \'26', count: 65 }, { month: 'Feb \'26', count: 73 },
  { month: 'Mar \'26', count: 89 }, { month: 'Apr \'26', count: 95 },
  { month: 'May \'26', count: 108 }, { month: 'Jun \'26', count: 47 },
];

const CRIME_CATEGORIES = [
  { name: 'Financial Fraud', value: 28, color: '#FFB547' },
  { name: 'Fake Profile', value: 18, color: '#FF3B6B' },
  { name: 'Cyberstalking', value: 15, color: '#8B5CF6' },
  { name: 'Deepfake Abuse', value: 12, color: '#00E5A0' },
  { name: 'SIM Swap', value: 10, color: '#4DA6FF' },
  { name: 'Phishing', value: 9, color: '#F97316' },
  { name: 'Others', value: 8, color: '#7B8DB0' },
];

const RESOLUTION_TIME = [
  { category: 'Financial Fraud', days: 14.2 },
  { category: 'Deepfake Abuse', days: 21.5 },
  { category: 'Cyberstalking', days: 9.8 },
  { category: 'SIM Swap', days: 6.3 },
  { category: 'Fake Profile', days: 12.1 },
  { category: 'Phishing', days: 4.7 },
  { category: 'Online Harassment', days: 8.4 },
];

const PLATFORMS = [
  { name: 'Instagram', count: 89, pct: 32 },
  { name: 'WhatsApp', count: 72, pct: 26 },
  { name: 'Telegram', count: 41, pct: 15 },
  { name: 'Facebook', count: 34, pct: 12 },
  { name: 'Phone Call', count: 22, pct: 8 },
  { name: 'Email', count: 19, pct: 7 },
];

const REPEAT_OFFENDERS = [
  { username: '@suspicious_acc_01', platform: 'Instagram', reports: 7, risk: 94 },
  { username: 'unknown_caller_x', platform: 'Phone', reports: 5, risk: 82 },
  { username: '@fake_nri_2026', platform: 'Facebook', reports: 4, risk: 76 },
  { username: 'scam_invest_pro', platform: 'WhatsApp', reports: 3, risk: 65 },
  { username: 'phish_domain_xyz', platform: 'Email', reports: 3, risk: 61 },
];

const SOS_RESPONSE = [
  { week: 'W1', avg: 6.2 }, { week: 'W2', avg: 5.1 },
  { week: 'W3', avg: 4.8 }, { week: 'W4', avg: 4.2 },
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

  useEffect(() => {
    dispatch(fetchDashboardStats());
  }, [dispatch]);

  return (
    <div className="animate-in">
      <div className="page-header">
        <div>
          <h2 className="page-title">📊 Crime Analytics & Intelligence</h2>
          <p className="page-subtitle">Ahmedabad Cyber Crime Cell — July 2025 to June 2026</p>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <button className="btn btn-ghost btn-sm" onClick={() => alert('📄 Generating full analytical report PDF with chart data... Download started.')}>📄 Export PDF</button>
          <button className="btn btn-ghost btn-sm" onClick={() => alert('📊 Exporting case details grid to XLSX... Download started.')}>📊 Export Excel</button>
        </div>
      </div>

      {/* KPI Row */}
      <div className="grid-4 mb-6">
        {[
          { label: 'Total Complaints', value: stats?.cyberComplaints ?? 441, icon: '📋', color: 'var(--text)', trend: '+12% YoY' },
          { label: 'Avg Resolution Days', value: '11.4', icon: '⏱', color: 'var(--warning)', trend: '-2.3 days vs last yr' },
          { label: 'Deepfake Cases', value: stats?.deepfakeCases ?? 53, icon: '🤖', color: 'var(--accent)', trend: '+67% YoY' },
          { label: 'SOS Incidents', value: stats?.totalIncidents ?? 127, icon: '🚨', color: 'var(--danger)', trend: '+8% vs Q1' },
        ].map(s => (
          <div key={s.label} className="card card-p">
            <div style={{ fontSize: '1.5rem', marginBottom: 6 }}>{s.icon}</div>
            <div style={{ fontSize: '1.75rem', fontWeight: 700, color: s.color, fontFamily: 'var(--font-display)', lineHeight: 1 }}>{s.value}</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--muted)', marginTop: 4 }}>{s.label}</div>
            <div style={{ fontSize: '0.75rem', color: 'var(--muted)', marginTop: 4 }}>
              <span style={{ color: s.trend.startsWith('-') ? 'var(--green)' : 'var(--accent)' }}>{s.trend}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Row 2: Line + Donut */}
      <div className="grid-2 mb-6">
        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>Monthly Complaint Trend</h3>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={MONTHLY_TREND}>
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
              <Pie data={CRIME_CATEGORIES} cx="50%" cy="50%" innerRadius={55} outerRadius={90} paddingAngle={3} dataKey="value">
                {CRIME_CATEGORIES.map((entry, i) => (
                  <Cell key={i} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip contentStyle={CHART_TOOLTIP_STYLE} formatter={(v) => [`${v}%`, 'Share']} />
            </PieChart>
          </ResponsiveContainer>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem', marginTop: 8 }}>
            {CRIME_CATEGORIES.map(c => (
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
            <BarChart data={RESOLUTION_TIME} layout="vertical">
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
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.875rem' }}>
            {PLATFORMS.map((p, i) => (
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
        </div>
      </div>

      {/* Row 4: Repeat offenders + SOS response */}
      <div className="grid-2">
        <div className="card p-0">
          <div style={{ padding: '1.25rem', borderBottom: '1px solid var(--card-border)' }}>
            <h3 style={{ fontFamily: 'var(--font-display)' }}>🔁 Repeat Offender Detection</h3>
          </div>
          <table className="table">
            <thead>
              <tr>
                <th>Account</th><th>Platform</th><th>Reports</th><th>Risk Score</th>
              </tr>
            </thead>
            <tbody>
              {REPEAT_OFFENDERS.map(r => (
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
        </div>

        <div className="card card-p">
          <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1.25rem' }}>⏱ SOS Response Time (min)</h3>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={SOS_RESPONSE}>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
              <XAxis dataKey="week" tick={{ fill: '#7B8DB0', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#7B8DB0', fontSize: 11 }} axisLine={false} tickLine={false} domain={[0, 10]} />
              <Tooltip contentStyle={CHART_TOOLTIP_STYLE} formatter={v => [`${v} min`, 'Avg Response']} />
              <Line type="monotone" dataKey="avg" stroke="#00E5A0" strokeWidth={2.5} dot={{ fill: '#00E5A0', r: 5 }} />
            </LineChart>
          </ResponsiveContainer>
          <div style={{ textAlign: 'center', marginTop: 8 }}>
            <span style={{ color: 'var(--green)', fontWeight: 700, fontSize: '1.25rem', fontFamily: 'var(--font-display)' }}>4.2 min</span>
            <span style={{ color: 'var(--muted)', fontSize: '0.8rem', marginLeft: 8 }}>current avg · target: &lt;5 min ✅</span>
          </div>
        </div>
      </div>
    </div>
  );
}
