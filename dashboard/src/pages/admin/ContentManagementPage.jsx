import { useEffect, useState } from 'react';
import api from '../../config/api';

export default function ContentManagementPage() {
  const [articles, setArticles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [lang, setLang] = useState('en');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ title: '', body: '', category: '', language: 'en' });
  const [saving, setSaving] = useState(false);

  const loadArticles = () => {
    setLoading(true);
    api.get('/awareness/articles', { params: { language: lang } })
      .then(({ data }) => { setArticles(data); setLoading(false); })
      .catch(() => setLoading(false));
  };

  useEffect(() => { loadArticles(); }, [lang]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await api.post('/awareness/articles', { ...form, language: lang });
      setShowForm(false);
      setForm({ title: '', body: '', category: '', language: 'en' });
      loadArticles();
    } catch (err) {
      alert(err.response?.data?.detail || 'Failed to create article');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete this article?')) return;
    try {
      await api.delete(`/awareness/articles/${id}`);
      loadArticles();
    } catch (err) {
      alert('Failed to delete');
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <h2>Content Management</h2>
        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <select
            value={lang}
            onChange={(e) => setLang(e.target.value)}
            style={{ background: 'var(--bg-card)', color: 'var(--text-primary)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.5rem 1rem' }}
          >
            <option value="en">English</option>
            <option value="hi">Hindi</option>
            <option value="gu">Gujarati</option>
          </select>
          <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
            {showForm ? 'Cancel' : '+ New Article'}
          </button>
        </div>
      </div>

      {showForm && (
        <form onSubmit={handleSubmit} className="card" style={{ marginBottom: '1.5rem' }}>
          <h3 style={{ marginBottom: '1rem' }}>Create Article</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            <input
              type="text" placeholder="Article Title" required value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.75rem', color: 'var(--text-primary)' }}
            />
            <input
              type="text" placeholder="Category (e.g. Cyber Safety)" value={form.category}
              onChange={(e) => setForm({ ...form, category: e.target.value })}
              style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.75rem', color: 'var(--text-primary)' }}
            />
            <textarea
              placeholder="Article body..." required rows={5} value={form.body}
              onChange={(e) => setForm({ ...form, body: e.target.value })}
              style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.75rem', color: 'var(--text-primary)', resize: 'vertical' }}
            />
            <button type="submit" className="btn-primary" disabled={saving} style={{ alignSelf: 'flex-start' }}>
              {saving ? 'Publishing...' : 'Publish Article'}
            </button>
          </div>
        </form>
      )}

      <div className="card">
        {loading ? (
          <p style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-secondary)' }}>Loading articles...</p>
        ) : articles.length === 0 ? (
          <p style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-secondary)' }}>No articles in {lang === 'en' ? 'English' : lang === 'hi' ? 'Hindi' : 'Gujarati'}</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {articles.map((a) => (
              <div key={a.id} style={{ padding: '1rem', background: 'var(--bg-secondary)', borderRadius: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div style={{ flex: 1 }}>
                  <h4 style={{ marginBottom: '0.25rem' }}>{a.title}</h4>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>
                    {a.category || 'General'} · {new Date(a.created_at).toLocaleDateString('en-IN')}
                  </p>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                    {a.body.length > 150 ? a.body.slice(0, 150) + '…' : a.body}
                  </p>
                </div>
                <button className="btn-danger" onClick={() => handleDelete(a.id)} style={{ marginLeft: '1rem', padding: '0.4rem 0.75rem', fontSize: '0.8rem' }}>
                  Delete
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
