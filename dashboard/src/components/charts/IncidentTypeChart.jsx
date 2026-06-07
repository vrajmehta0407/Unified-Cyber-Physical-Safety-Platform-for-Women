import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

const COLORS = ['#7c3aed', '#ec4899', '#ef4444', '#eab308', '#22c55e'];

export default function IncidentTypeChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={250}>
      <PieChart>
        <Pie data={data} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={80} label>
          {data.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
        </Pie>
        <Tooltip contentStyle={{ background: '#221a3a', border: '1px solid #2d2450' }} />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
}
