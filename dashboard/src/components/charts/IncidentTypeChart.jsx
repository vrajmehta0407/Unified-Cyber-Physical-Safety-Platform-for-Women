import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

const COLORS = ['#2D6BFF', '#8B5CF6', '#00E5A0', '#FFB547', '#FF4545'];

export default function IncidentTypeChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={250}>
      <PieChart>
        <Pie data={data} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={80} label>
          {data.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
        </Pie>
        <Tooltip contentStyle={{ background: 'var(--input-bg)', border: '1px solid var(--input-border)', borderRadius: 'var(--border-radius-sm)', color: 'var(--text)' }} />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
}
