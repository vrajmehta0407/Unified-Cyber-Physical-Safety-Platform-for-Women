import { useSelector } from 'react-redux';
import useAuth from '../../hooks/useAuth';

export default function Navbar() {
  const { user } = useAuth();
  const activeSosCount = useSelector((s) => s.sos.activeAlerts.length);

  return (
    <header style={{
      padding: '1rem 1.5rem',
      borderBottom: '1px solid var(--border)',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      background: 'var(--bg-secondary)',
    }}>
      <div>
        <h2 style={{ fontSize: '1.125rem' }}>Ahmedabad City Police</h2>
        <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Cyber Crime Branch — Live Command Center</p>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
        <span className={`badge ${activeSosCount > 0 ? 'badge-high' : 'badge-low'}`}>
          ● {activeSosCount} Active SOS
        </span>
        <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
          {user?.name || 'Officer'}
        </span>
      </div>
    </header>
  );
}
