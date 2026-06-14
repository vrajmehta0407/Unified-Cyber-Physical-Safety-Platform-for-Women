import './Sidebar.css';
import { NavLink } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { logout } from '../../store/slices/authSlice';
import useAuth from '../../hooks/useAuth';

const NAV_SECTIONS = [
  {
    label: 'Command',
    items: [
      { to: '/', label: 'Command Center', icon: '⌖', end: true },
      { to: '/sos', label: 'Live SOS Monitor', icon: '🚨', badge: 'live' },
      { to: '/incidents', label: 'All Incidents', icon: '📋' },
    ],
  },
  {
    label: 'Case Management',
    items: [
      { to: '/complaints', label: 'Cyber Complaints', icon: '💻' },
      { to: '/evidence', label: 'Evidence Vault', icon: '🔐' },
      { to: '/analytics', label: 'Analytics', icon: '📊' },
    ],
  },
  {
    label: 'Tools',
    items: [
      { to: '/zones', label: 'Unsafe Zones', icon: '🗺️' },
      { to: '/broadcast', label: 'Broadcast Advisory', icon: '📡' },
      { to: '/cctns', label: 'CCTNS Integration', icon: '🔗' },
      { to: '/erss', label: 'ERSS 112', icon: '📞' },
    ],
  },
];

const ADMIN_ITEMS = [
  { to: '/admin', label: 'Admin Panel', icon: '⚙️', end: true },
  { to: '/admin/users', label: 'User Management', icon: '👥' },
  { to: '/admin/system', label: 'System Health', icon: '🖥️' },
  { to: '/admin/content', label: 'Content Mgmt', icon: '📰' },
];

export default function Sidebar() {
  const dispatch = useDispatch();
  const { user } = useAuth();
  const isAdmin = user?.role === 'admin';

  const initials = user?.name
    ? user.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
    : 'CS';

  const roleLabelMap = {
    admin: 'Administrator',
    police: 'Police Officer',
    cyber_cell: 'Cyber Cell Officer',
    officer: 'Field Officer',
  };
  const roleLabel = roleLabelMap[user?.role] ?? 'Officer';

  function handleLogout() {
    dispatch(logout());
    window.location.href = '/login';
  }

  return (
    <aside className="sidebar">
      {/* ─── Brand ─── */}
      <div className="sidebar-brand">
        <div className="brand-shield">🛡️</div>
        <div className="brand-text">
          <div className="brand-name">CyberShield</div>
          <div className="brand-sub">Police Command Center</div>
        </div>
      </div>

      {/* ─── Officer profile ─── */}
      <div className="officer-card">
        <div className="officer-avatar">{initials}</div>
        <div className="officer-info">
          <div className="officer-name">{user?.name ?? 'Officer'}</div>
          <div className="officer-badge">
            {user?.badge ? `Badge #${user.badge}` : 'AHM-CCC-2026'}
          </div>
        </div>
        <span className="role-chip">{roleLabel}</span>
      </div>

      {/* ─── Navigation ─── */}
      <nav className="sidebar-nav">
        {NAV_SECTIONS.map(section => (
          <div key={section.label} className="nav-section">
            <div className="nav-section-label">{section.label}</div>
            {section.items.map(item => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                className={({ isActive }) =>
                  `nav-link${isActive ? ' active' : ''}`
                }
              >
                <span className="nav-icon">{item.icon}</span>
                <span className="nav-label">{item.label}</span>
                {item.badge === 'live' && (
                  <span className="nav-live-badge">
                    <span className="dot dot-pulse" />
                    LIVE
                  </span>
                )}
              </NavLink>
            ))}
          </div>
        ))}

        {isAdmin && (
          <div className="nav-section">
            <div className="nav-section-label">Admin</div>
            {ADMIN_ITEMS.map(item => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                className={({ isActive }) =>
                  `nav-link${isActive ? ' active' : ''}`
                }
              >
                <span className="nav-icon">{item.icon}</span>
                <span className="nav-label">{item.label}</span>
              </NavLink>
            ))}
          </div>
        )}
      </nav>

      {/* ─── Footer ─── */}
      <div className="sidebar-footer">
        <div className="emergency-contact">
          <span>🆘</span>
          <div>
            <div style={{ fontSize: '0.75rem', fontWeight: 600 }}>Cyber Helpline</div>
            <div style={{ fontSize: '0.8125rem', color: 'var(--accent)', fontWeight: 700 }}>1930</div>
          </div>
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <span>⇤</span> Logout
        </button>
      </div>
    </aside>
  );
}
