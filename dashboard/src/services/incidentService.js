import api from '../config/api';

export const sosService = {
  getActive: () => api.get('/sos/active'),
};

export const incidentService = {
  getAll: () => api.get('/incidents/'),
  getById: (id) => api.get(`/incidents/${id}`),
  update: (id, data) => api.patch(`/incidents/${id}`, data),
};

export const reportService = {
  getAll: () => api.get('/reports/'),
};

export const evidenceService = {
  getAll: () => api.get('/evidence/list'),
};

export const integrationService = {
  getCctns: (reportId) => api.get(`/integrations/cctns/${reportId}`),
  getErss: () => api.get('/integrations/erss/active'),
};

export const zoneService = {
  getUnsafeZones: (city = 'Ahmedabad') => api.get('/ai/unsafe-zone', { params: { city } }),
};

export const analyticsService = {
  getDashboard: () => api.get('/analytics/dashboard'),
};
