import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { analyticsService } from '../../services/incidentService';

export const fetchDashboardStats = createAsyncThunk('analytics/fetchDashboard', async (_, { rejectWithValue }) => {
  try {
    const { data } = await analyticsService.getDashboard();
    return data;
  } catch (err) {
    return rejectWithValue(err.response?.data?.detail || 'Failed to load stats');
  }
});

const analyticsSlice = createSlice({
  name: 'analytics',
  initialState: {
    stats: { activeSOS: 0, cyberComplaints: 0, totalIncidents: 0, activeOfficers: 0 },
    trend: [
      { month: 'Jan', count: 78 }, { month: 'Feb', count: 92 },
      { month: 'Mar', count: 85 }, { month: 'Apr', count: 110 },
      { month: 'May', count: 95 }, { month: 'Jun', count: 88 },
    ],
    categories: [
      { name: 'Harassment', value: 30 }, { name: 'Cyber Fraud', value: 25 },
      { name: 'Stalking', value: 15 }, { name: 'Blackmail', value: 10 },
      { name: 'Others', value: 20 },
    ],
    loading: false,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchDashboardStats.fulfilled, (state, action) => {
        state.stats = {
          activeSOS: action.payload.active_sos,
          cyberComplaints: action.payload.cyber_complaints,
          totalIncidents: action.payload.total_incidents,
          activeOfficers: action.payload.active_officers,
        };
      });
  },
});

export default analyticsSlice.reducer;
