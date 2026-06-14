import { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { login, clearError } from '../../store/slices/authSlice';
import { useNavigate, useLocation } from 'react-router-dom';

export default function LoginPage() {
  const [mobile, setMobile] = useState('9999999999');
  const [password, setPassword] = useState('police123');
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const location = useLocation();
  const { loading, error } = useSelector((s) => s.auth);

  const from = location.state?.from?.pathname || '/';

  const handleSubmit = async (e) => {
    e.preventDefault();
    dispatch(clearError());
    const result = await dispatch(login({ mobile, password }));
    if (login.fulfilled.match(result)) {
      if (!['police', 'admin'].includes(result.payload.user.role)) {
        dispatch(clearError());
        alert('Access denied. Police or admin account required.');
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        return;
      }
      navigate(from, { replace: true });
    }
  };

  return (
    <div style={{
      minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'linear-gradient(135deg, #0f0a1a, #1a1230)',
    }}>
      <form onSubmit={handleSubmit} className="card" style={{ width: '400px' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <span style={{ fontSize: '3rem' }}>🛡️</span>
          <h1 style={{ marginTop: '0.5rem', background: 'linear-gradient(135deg, #7c3aed, #ec4899)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            CyberShield
          </h1>
          <p style={{ color: 'var(--text-secondary)' }}>Police & Admin Portal</p>
        </div>
        {error && (
          <div style={{ background: 'rgba(239,68,68,0.15)', color: '#ef4444', padding: '0.75rem', borderRadius: '8px', marginBottom: '1rem', fontSize: '0.875rem' }}>
            {typeof error === 'string' ? error : 'Login failed'}
          </div>
        )}
        <div style={{ marginBottom: '1rem' }}>
          <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.875rem' }}>Mobile Number</label>
          <input value={mobile} onChange={(e) => setMobile(e.target.value)} style={inputStyle} placeholder="9999999999" required />
        </div>
        <div style={{ marginBottom: '1.5rem' }}>
          <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.875rem' }}>Password</label>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} style={inputStyle} required />
        </div>
        <button type="submit" className="btn-primary" style={{ width: '100%' }} disabled={loading}>
          {loading ? 'Signing in...' : 'Login'}
        </button>
        <div style={{ marginTop: '1rem', fontSize: '0.75rem', color: 'var(--text-secondary)', textAlign: 'center' }}>
          <div>👮 Police: 9999999999 / police123</div>
          <div style={{ marginTop: '4px' }}>⚙️ Admin: 9000000001 / admin123</div>
        </div>
      </form>
    </div>
  );
}

const inputStyle = {
  width: '100%', padding: '0.75rem', borderRadius: '8px',
  border: '1px solid var(--border)', background: 'var(--bg-primary)', color: 'var(--text-primary)',
};
