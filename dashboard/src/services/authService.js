import api from '../config/api';

export const authService = {
  login: (mobile, password) => api.post('/auth/login', { mobile, password }),
  register: (payload) => api.post('/auth/register', payload),
  sendOtp: (mobile) => api.post('/auth/otp/send', { mobile }),
  verifyOtp: (mobile, otp) => api.post('/auth/otp/verify', { mobile, otp }),
  getMe: () => api.get('/auth/me'),
  getProfile: () => api.get('/users/profile'),
};
