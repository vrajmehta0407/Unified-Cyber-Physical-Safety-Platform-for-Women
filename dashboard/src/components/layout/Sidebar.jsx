import { NavLink } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { logout } from '../../store/slices/authSlice';
import useAuth from '../../hooks/useAuth';
import './Sidebar.css';

const POLICE_ITEMS = [
  { to: '/', label: 'Dashboard', icon: '📊' },
  { to: '/sos', label: 'Live Incidents', icon: '🚨' },
  { to: '/incidents', label: 'Incidents', icon: '📋' },
  { to: '/complaints', label: 'Complaints', icon: '💻' },
  { to: '/evidence', label: 'Evidence', icon: '📎' },
  { to: '/zones', label: 'Unsafe Zones', icon: '🗺️' },
  { to: '/cctns', label: 'CCTNS', icon: '🔗' },
  { to: '/erss', label: 'ERSS 112', icon: '📞' },
  { to: '/analytics', label: 'Analytics', icon: '📈' },
];

const ADMIN_ITEMS = [
  { to: '/admin', label: 'Admin Panel', icon: '⚙️' },
  { to: '/admin/users', label: 'Users', icon: '👥' },
  { to: '/admin/system', label: 'System', icon: '🖥️' },
  { to: '/admin/content', label: 'Content', icon: '📰' },
];

export default function Sidebar() {
  const dispatch = useDispatch();
  const { user } = useAuth();
  const isAdmin = user?.role === 'admin';

  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <span className="brand-icon">🛡️</span>
        <div>
          <h1>CyberShield</h1>
          <p>Police Command Center</p>
        </div>
      </div>
      <nav className="sidebar-nav">
        {POLICE_ITEMS.map((item) => (
          <NavLink key={item.to} to={item.to} end={item.to === '/'} className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            <span>{item.icon}</span> {item.label}
          </NavLink>
        ))}

        {isAdmin && (
          <>
            <div className="nav-divider" />
            {ADMIN_ITEMS.map((item) => (
              <NavLink key={item.to} to={item.to} end={item.to === '/admin'} className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
                <span>{item.icon}</span> {item.label}
              </NavLink>
            ))}
          </>
        )}
      </nav>
      <button className="logout-btn" onClick={() => { dispatch(logout()); window.location.href = '/login'; }}>
        Logout {user?.name ? `(${user.name})` : ''}
      </button>
    </aside>
  );
}
