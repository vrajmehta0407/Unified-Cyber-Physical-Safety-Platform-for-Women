import './PageLayout.css';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import useAuth from '../../hooks/useAuth';

function Navbar() {
  const { user } = useAuth();
  const now = new Date();
  const timeStr = now.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' });
  const dateStr = now.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });

  return (
    <header className="topbar">
      <div className="topbar-left">
        <div className="breadcrumb-pill">
          <span className="dot dot-green" />
          <span style={{ fontSize: '0.8125rem', color: 'var(--muted)' }}>
            Ahmedabad Cyber Crime Cell
          </span>
          <span style={{ color: 'var(--card-border)' }}>·</span>
          <span style={{ fontSize: '0.8125rem', fontWeight: 600 }}>Command Center</span>
        </div>
      </div>
      <div className="topbar-right">
        <div className="time-display">
          <span style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>{dateStr}</span>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.875rem', fontWeight: 600, color: 'var(--green)' }}>{timeStr}</span>
        </div>
        <div className="topbar-divider" />
        <button className="icon-btn" title="Notifications">
          <span>🔔</span>
          <span className="notif-dot" />
        </button>
        <div className="topbar-avatar" title={user?.name ?? 'Profile'}>
          {user?.name?.[0]?.toUpperCase() ?? 'O'}
        </div>
        <button 
          className="btn btn-ghost btn-sm" 
          style={{ marginLeft: '0.5rem', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '0.8rem', padding: '0.375rem 0.75rem' }}
          onClick={() => {
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            window.location.href = '/login';
          }}
        >
          <span>⇤</span> Logout
        </button>
      </div>
    </header>
  );
}

export default function PageLayout() {
  return (
    <div className="layout">
      <Sidebar />
      <div className="main-wrap">
        <Navbar />
        <main className="main-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
