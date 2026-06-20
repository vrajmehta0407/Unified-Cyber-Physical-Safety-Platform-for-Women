import api from '../config/api';

// ─── SOS ──────────────────────────────────────────────────────────────────────
export const sosService = {
  getActive: () => api.get('/sos/active'),
};

// ─── Incidents ────────────────────────────────────────────────────────────────
export const incidentService = {
  getAll:  () => api.get('/incidents/'),
  getById: (id) => api.get(`/incidents/${id}`),
  update:  (id, data) => api.patch(`/incidents/${id}`, data),

  /** Dispatch officer to an SOS — PUT /incidents/{id}/assign */
  assign:  (id, data = {}) => api.put(`/incidents/${id}/assign`, {
    officer_name: data.officer_name || 'Duty Officer',
    ...data,
  }),

  /** Resolve an SOS — PUT /incidents/{id}/resolve */
  resolve: (id, data = {}) => api.put(`/incidents/${id}/resolve`, {
    status: data.status || 'resolved',
    resolution_note: data.resolution_note || null,
  }),
};

// ─── Reports / Complaints ─────────────────────────────────────────────────────
export const reportService = {
  getAll:   () => api.get('/reports/'),
  getById:  (id) => api.get(`/reports/${id}`),
  update:   (id, data) => api.patch(`/reports/${id}`, data),
  getStats: () => api.get('/reports/stats'),

  /** Generate FIR PDF for a report — POST /reports/{id}/fir */
  generateFir: (id, data = {}) => api.post(`/reports/${id}/fir`, data, {
    responseType: 'blob',
  }),

  /** Download previously generated FIR — GET /reports/{id}/fir */
  downloadFir: (id) => api.get(`/reports/${id}/fir`, { responseType: 'blob' }),
};

// ─── Evidence ─────────────────────────────────────────────────────────────────
export const evidenceService = {
  getAll:    () => api.get('/evidence/list'),
  getById:   (id) => api.get(`/evidence/${id}`),
  getCustody:(id) => api.get(`/evidence/${id}/custody`),
  review:    (id, data) => api.patch(`/evidence/${id}`, data),
  upload:    (formData) => api.post('/evidence/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }),
};

// ─── Broadcasts ───────────────────────────────────────────────────────────────
export const broadcastService = {
  getAll:  () => api.get('/broadcasts/'),
  create:  (data) => api.post('/broadcasts/', data),
  delete:  (id) => api.delete(`/broadcasts/${id}`),
};

// ─── Integrations ─────────────────────────────────────────────────────────────
export const integrationService = {
  getCctns: (reportId) => api.get(`/integrations/cctns/${reportId}`),
  getErss:  () => api.get('/integrations/erss/active'),
};

// ─── Zones ────────────────────────────────────────────────────────────────────
export const zoneService = {
  getUnsafeZones: (city = 'Ahmedabad') => api.get('/ai/unsafe-zone', { params: { city } }),
};

// ─── Analytics ────────────────────────────────────────────────────────────────
export const analyticsService = {
  getDashboard:    () => api.get('/analytics/dashboard'),
  getComprehensive:() => api.get('/analytics/comprehensive'),
  getPatterns:     () => api.get('/analytics/patterns'),
  getHourly:       () => api.get('/analytics/hourly'),
};

// ─── Officers ─────────────────────────────────────────────────────────────────
export const officerService = {
  getAll:  () => api.get('/officers/'),
  getById: (id) => api.get(`/officers/${id}`),
  create:  (data) => api.post('/officers/', data),
  update:  (id, data) => api.patch(`/officers/${id}`, data),
  delete:  (id) => api.delete(`/officers/${id}`),
};

// ─── PDF Download Helper ──────────────────────────────────────────────────────
/**
 * Trigger a browser download from a Blob response.
 * Usage: downloadBlob(response.data, 'report.pdf')
 */
export function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}
