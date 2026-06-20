import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function CrimeTrendChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={250}>
      <LineChart data={data}>
        <CartesianGrid strokeDasharray="3 3" stroke="var(--card-border)" />
        <XAxis dataKey="month" stroke="var(--secondary)" />
        <YAxis stroke="var(--secondary)" />
        <Tooltip contentStyle={{ background: 'var(--input-bg)', border: '1px solid var(--input-border)', borderRadius: 'var(--border-radius-sm)', color: 'var(--text)' }} />
        <Line type="monotone" dataKey="count" stroke="var(--accent)" strokeWidth={3} dot={{ fill: 'var(--info)' }} />
      </LineChart>
    </ResponsiveContainer>
  );
}
