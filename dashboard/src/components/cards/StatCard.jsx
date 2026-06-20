export default function StatCard({ title, label, value, icon, color = 'var(--accent)' }) {
  const displayTitle = title || label; // Handle both prop names used in different pages
  return (
    <div className="card stat-card" style={{ background: 'var(--card-bg)', border: '1px solid var(--card-border)', borderRadius: 'var(--border-radius)', padding: '1.5rem' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          <p style={{ color: 'var(--secondary)', fontSize: '0.875rem', marginBottom: '0.5rem', fontFamily: 'var(--font-mono)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>{displayTitle}</p>
          <h3 style={{ fontSize: '2rem', fontWeight: 700, fontFamily: 'var(--font-body)' }}>{value}</h3>
        </div>
        <span style={{ fontSize: '1.5rem', color: color, background: `color-mix(in srgb, ${color} 15%, transparent)`, padding: '0.75rem', borderRadius: 'var(--border-radius-sm)' }}>{icon}</span>
      </div>
    </div>
  );
}
