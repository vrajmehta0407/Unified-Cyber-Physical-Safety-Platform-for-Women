import { useEffect, useState } from 'react';
import api from '../../config/api';

export default function UserManagementPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    api.get('/users/list')
      .then(({ data }) => { setUsers(data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const filtered = users.filter((u) =>
    u.name.toLowerCase().includes(search.toLowerCase()) ||
    u.mobile.includes(search) ||
    (u.email || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <h2>User Management</h2>
        <span style={{ color: 'var(--text-secondary)' }}>{users.length} total users</span>
      </div>

      <div className="card" style={{ marginBottom: '1rem', padding: '0.75rem 1rem' }}>
        <input
          type="text"
          placeholder="🔍 Search by name, mobile, or email..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{
            width: '100%', background: 'transparent', border: 'none', outline: 'none',
            color: 'var(--text-primary)', fontSize: '0.95rem',
          }}
        />
      </div>

      <div className="card">
        {loading ? (
          <p style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-secondary)' }}>Loading users...</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '2px solid var(--border)', textAlign: 'left' }}>
                <th style={{ padding: '0.75rem' }}>Name</th>
                <th style={{ padding: '0.75rem' }}>Mobile</th>
                <th style={{ padding: '0.75rem' }}>Email</th>
                <th style={{ padding: '0.75rem' }}>Role</th>
                <th style={{ padding: '0.75rem' }}>Joined</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((u) => (
                <tr key={u.id} style={{ borderBottom: '1px solid var(--border)' }}>
                  <td style={{ padding: '0.75rem', fontWeight: 500 }}>{u.name}</td>
                  <td style={{ padding: '0.75rem', color: 'var(--text-secondary)' }}>{u.mobile}</td>
                  <td style={{ padding: '0.75rem', color: 'var(--text-secondary)' }}>{u.email || '—'}</td>
                  <td style={{ padding: '0.75rem' }}>
                    <span className={`badge badge-${u.role === 'admin' ? 'high' : u.role === 'police' ? 'medium' : 'low'}`}>
                      {u.role}
                    </span>
                  </td>
                  <td style={{ padding: '0.75rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                    {new Date(u.created_at).toLocaleDateString('en-IN')}
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr><td colSpan={5} style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-secondary)' }}>No users match your search</td></tr>
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
