import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { fetchDashboardStats } from '../../store/slices/analyticsSlice';
import { fetchActiveSos } from '../../store/slices/sosSlice';

const ACTIVITY_FEED = [
  { id: 1, icon: '🚨', iconBg: 'rgba(255,69,69,0.15)', title: 'SOS Alert Activated', desc: 'Victim near Navrangpura, Ahmedabad', time: '2m ago', caseId: 'INC-2026-0892', type: 'sos' },
  { id: 2, icon: '💻', iconBg: 'rgba(139,92,246,0.15)', title: 'Deepfake Complaint Filed', desc: 'Category: Deepfake Abuse — AI-manipulated video', time: '8m ago', caseId: 'CYB-AHM-0441', type: 'complaint' },
  { id: 3, icon: '🔐', iconBg: 'rgba(0,229,160,0.12)', title: 'Evidence Uploaded', desc: '3 screenshots + 1 video (hash verified ✓)', time: '15m ago', caseId: 'CYB-AHM-0439', type: 'evidence' },
  { id: 4, icon: '👤', iconBg: 'rgba(255,181,71,0.15)', title: 'Fake Profile Report', desc: 'Instagram impersonation of local businesswoman', time: '22m ago', caseId: 'CYB-AHM-0438', type: 'complaint' },
  { id: 5, icon: '✅', iconBg: 'rgba(0,229,160,0.12)', title: 'SOS Resolved', desc: 'Incident closed — victim confirmed safe', time: '35m ago', caseId: 'INC-2026-0891', type: 'resolved' },
  { id: 6, icon: '📡', iconBg: 'rgba(77,166,255,0.15)', title: 'Advisory Broadcast Sent', desc: 'SIM Swap fraud alert — 1,247 users notified', time: '1h ago', caseId: 'BCT-2026-047', type: 'broadcast' },
];

const RECENT_COMPLAINTS = [
  { id: 'CYB-AHM-0441', category: 'Deepfake Abuse', icon: '🤖', victim: 'Victim #2892', filed: '14 Jun, 11:18', priority: 'critical', status: 'under-review' },
  { id: 'CYB-AHM-0440', category: 'SIM Swap Fraud', icon: '📱', victim: 'Victim #2891', filed: '14 Jun, 10:45', priority: 'high', status: 'submitted' },
  { id: 'CYB-AHM-0439', category: 'Financial Fraud', icon: '💸', victim: 'Victim #2890', filed: '14 Jun, 09:30', priority: 'high', status: 'assigned' },
  { id: 'CYB-AHM-0438', category: 'Fake Profile', icon: '👤', victim: 'Victim #2889', filed: '14 Jun, 08:15', priority: 'medium', status: 'investigation' },
  { id: 'CYB-AHM-0437', category: 'Cyberstalking', icon: '🔍', victim: 'Victim #2888', filed: '13 Jun, 22:50', priority: 'high', status: 'assigned' },
];

function StatCard({ title, value, icon, iconBg, accentColor, trend, isPulsing, subtitle }) {
  return (
    <div
      className="stat-card animate-in"
      style={{ '--accent-color': accentColor, '--icon-bg': iconBg }}
    >
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div className="icon-wrap">
          <span style={{ fontSize: '1.25rem' }}>{icon}</span>
        </div>
        {isPulsing && value > 0 && (
          <span className="badge badge-active" style={{ gap: '0.375rem' }}>
            <span className="dot dot-pulse" />
            ACTIVE
          </span>
        )}
      </div>
      <div>
        <div className="label">{title}</div>
        <div className="value" style={{ color: accentColor ?? 'var(--text)' }}>
          {value ?? <span className="shimmer" style={{ display: 'inline-block', width: 60, height: 32, borderRadius: 8 }} />}
        </div>
        {subtitle && <div style={{ fontSize: '0.75rem', color: 'var(--muted)', marginTop: 2 }}>{subtitle}</div>}
      </div>
      {trend && (
        <div className={`trend ${trend > 0 ? 'trend-up' : 'trend-down'}`}>
          {trend > 0 ? '↑' : '↓'} {Math.abs(trend)}% vs last week
        </div>
      )}
    </div>
  );
}

function ActivityFeedItem({ item }) {
  return (
    <div className="feed-item animate-in">
      <div className="feed-icon" style={{ background: item.iconBg }}>
        {item.icon}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap' }}>
          <span style={{ fontWeight: 600, fontSize: '0.875rem' }}>{item.title}</span>
          <span className="badge badge-submitted" style={{ fontSize: '0.65rem', padding: '0.125rem 0.5rem' }}>
            {item.caseId}
          </span>
        </div>
        <div style={{ fontSize: '0.8125rem', color: 'var(--muted)', marginTop: 2 }}>{item.desc}</div>
      </div>
      <div style={{ fontSize: '0.75rem', color: 'var(--muted)', whiteSpace: 'nowrap', flexShrink: 0 }}>{item.time}</div>
    </div>
  );
}

export default function PoliceDashboard() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { stats } = useSelector(s => s.analytics);
  const { activeAlerts } = useSelector(s => s.sos);
  const [lastUpdated, setLastUpdated] = useState(new Date());

  useEffect(() => {
    dispatch(fetchDashboardStats());
    dispatch(fetchActiveSos());
    const interval = setInterval(() => {
      dispatch(fetchDashboardStats());
      dispatch(fetchActiveSos());
      setLastUpdated(new Date());
    }, 30000);
    return () => clearInterval(interval);
  }, [dispatch]);

  const activeSOS = activeAlerts?.length ?? stats?.activeSOS ?? 0;

  return (
    <div className="animate-in">
      {/* ─── Header ─── */}
      <div className="page-header">
        <div>
          <h2 className="page-title">Command Center</h2>
          <p className="page-subtitle">
            Ahmedabad Cyber Crime Cell — Live Operations ·&nbsp;
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.75rem', color: 'var(--green)' }}>
              Updated {lastUpdated.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
            </span>
          </p>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
          <button className="btn btn-ghost btn-sm" onClick={() => navigate('/broadcast')}>
            📡 Broadcast Advisory
          </button>
          <button className="btn btn-primary btn-sm" onClick={() => navigate('/sos')}>
            🚨 Live SOS Monitor
          </button>
        </div>
      </div>

      {/* ─── KPI Cards ─── */}
      <div className="grid-4 mb-6">
        <StatCard
          title="Active SOS Alerts"
          value={activeSOS}
          icon="🚨"
          iconBg="rgba(255,69,69,0.15)"
          accentColor="var(--danger)"
          isPulsing
          subtitle="Requires immediate response"
        />
        <StatCard
          title="Open Cyber Complaints"
          value={stats?.cyberComplaints ?? 47}
          icon="💻"
          iconBg="rgba(139,92,246,0.15)"
          accentColor="var(--purple)"
          trend={12}
          subtitle="Across all categories"
        />
        <StatCard
          title="Evidence Pending Review"
          value={stats?.pendingEvidence ?? 23}
          icon="🔬"
          iconBg="rgba(255,181,71,0.15)"
          accentColor="var(--warning)"
          subtitle="Awaiting officer review"
        />
        <StatCard
          title="Cases Closed This Month"
          value={stats?.closedThisMonth ?? 89}
          icon="✅"
          iconBg="rgba(0,229,160,0.12)"
          accentColor="var(--green)"
          trend={8}
          subtitle="June 2026"
        />
      </div>

      {/* ─── Main content: 60/40 grid ─── */}
      <div style={{ display: 'grid', gridTemplateColumns: '3fr 2fr', gap: '1rem', marginBottom: '1rem' }}>
        {/* LEFT: Recent Activity Feed */}
        <div className="card card-p">
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1rem' }}>
            <h3 style={{ fontFamily: 'var(--font-display)' }}>Recent Activity</h3>
            <span style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>Last 2 hours</span>
          </div>
          {ACTIVITY_FEED.map(item => (
            <ActivityFeedItem key={item.id} item={item} />
          ))}
        </div>

        {/* RIGHT: Quick Actions */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div className="card card-p">
            <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: '1rem' }}>Quick Actions</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.625rem' }}>
              {[
                { label: 'Assign Unassigned Cases', icon: '👮', desc: '6 cases awaiting assignment', to: '/complaints', color: 'var(--accent)' },
                { label: 'View Active SOS', icon: '🚨', desc: `${activeSOS} active alert${activeSOS !== 1 ? 's' : ''}`, to: '/sos', color: 'var(--danger)' },
                { label: 'Review Evidence', icon: '🔐', desc: '23 items pending review', to: '/evidence', color: 'var(--warning)' },
                { label: 'Broadcast Advisory', icon: '📡', desc: 'Alert users in your area', to: '/broadcast', color: 'var(--green)' },
                { label: 'Download Daily Report', icon: '📄', desc: 'PDF report for 14 Jun 2026', to: '#', color: 'var(--info)' },
              ].map(action => (
                <button
                  key={action.label}
                  className="btn btn-ghost w-full"
                  style={{ justifyContent: 'flex-start', gap: '0.75rem', padding: '0.75rem 1rem', textAlign: 'left' }}
                  onClick={() => action.to !== '#' && navigate(action.to)}
                >
                  <span style={{
                    width: 36, height: 36, background: action.color + '22',
                    border: `1px solid ${action.color}44`,
                    borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: '1rem', flexShrink: 0
                  }}>{action.icon}</span>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: '0.875rem', fontWeight: 600, color: 'var(--text)' }}>{action.label}</div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>{action.desc}</div>
                  </div>
                  <span style={{ color: 'var(--muted)', fontSize: '0.75rem' }}>›</span>
                </button>
              ))}
            </div>
          </div>

          {/* Status Summary */}
          <div className="card card-p">
            <h4 style={{ fontFamily: 'var(--font-display)', marginBottom: '0.875rem' }}>System Status</h4>
            {[
              { label: 'API Backend', status: 'Operational', color: 'var(--green)' },
              { label: 'Firebase Realtime DB', status: 'Operational', color: 'var(--green)' },
              { label: 'FCM Notifications', status: 'Operational', color: 'var(--green)' },
              { label: 'Evidence Vault', status: 'Operational', color: 'var(--green)' },
              { label: 'AI Engine', status: 'Degraded', color: 'var(--warning)' },
            ].map(s => (
              <div key={s.label} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0.5rem 0', borderBottom: '1px solid rgba(255,255,255,0.04)' }}>
                <span style={{ fontSize: '0.8125rem', color: 'var(--muted)' }}>{s.label}</span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '0.375rem', fontSize: '0.75rem', color: s.color, fontWeight: 600 }}>
                  <span style={{ width: 6, height: 6, borderRadius: '50%', background: s.color, display: 'inline-block' }} />
                  {s.status}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ─── Recent Complaints table ─── */}
      <div className="card p-0">
        <div style={{ padding: '1.25rem 1.5rem', borderBottom: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h3 style={{ fontFamily: 'var(--font-display)' }}>Recent Cyber Complaints</h3>
          <button className="btn btn-ghost btn-sm" onClick={() => navigate('/complaints')}>View All →</button>
        </div>
        <div className="table-wrap">
          <table className="table">
            <thead>
              <tr>
                <th>Complaint #</th>
                <th>Category</th>
                <th>Victim</th>
                <th>Filed</th>
                <th>Priority</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {RECENT_COMPLAINTS.map(c => (
                <tr key={c.id} style={{ cursor: 'pointer' }} onClick={() => navigate('/complaints')}>
                  <td>
                    <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8125rem', color: 'var(--info)' }}>
                      {c.id}
                    </span>
                  </td>
                  <td>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <span>{c.icon}</span>
                      <span style={{ fontSize: '0.875rem' }}>{c.category}</span>
                    </span>
                  </td>
                  <td style={{ color: 'var(--muted)', fontSize: '0.875rem' }}>{c.victim}</td>
                  <td style={{ color: 'var(--muted)', fontSize: '0.8125rem', fontFamily: 'var(--font-mono)' }}>{c.filed}</td>
                  <td><span className={`badge badge-${c.priority}`}>{c.priority.charAt(0).toUpperCase() + c.priority.slice(1)}</span></td>
                  <td><span className={`badge badge-${c.status}`}>{c.status.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}</span></td>
                  <td>
                    <button className="btn btn-ghost btn-sm" onClick={e => { e.stopPropagation(); navigate('/complaints'); }}>
                      Review
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
