export default function StatCard({ title, value, icon, color = 'var(--accent-purple)' }) {
  return (
    <div className="card stat-card">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>{title}</p>
          <h3 style={{ fontSize: '2rem', fontWeight: 700 }}>{value}</h3>
        </div>
        <span style={{ fontSize: '1.5rem', background: `${color}22`, padding: '0.5rem', borderRadius: '8px' }}>{icon}</span>
      </div>
    </div>
  );
}
