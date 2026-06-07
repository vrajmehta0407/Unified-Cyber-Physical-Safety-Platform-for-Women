import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import sosReducer from './slices/sosSlice';
import incidentReducer from './slices/incidentSlice';
import analyticsReducer from './slices/analyticsSlice';
import reportReducer from './slices/reportSlice';
import evidenceReducer from './slices/evidenceSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    sos: sosReducer,
    incidents: incidentReducer,
    analytics: analyticsReducer,
    reports: reportReducer,
    evidence: evidenceReducer,
  },
});
