import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { sosService, incidentService } from '../../services/incidentService';

export const fetchActiveSos = createAsyncThunk('sos/fetchActive', async (_, { rejectWithValue }) => {
  try {
    const { data } = await sosService.getActive();
    return data;
  } catch (err) {
    return rejectWithValue(err.response?.data?.detail || 'Failed to load SOS alerts');
  }
});

export const dispatchSos = createAsyncThunk('sos/dispatch', async (id, { dispatch, rejectWithValue }) => {
  try {
    const { data } = await incidentService.update(id, { status: 'responding' });
    dispatch(updateAlertStatus({ id, status: 'RESPONDING' }));
    return data;
  } catch (err) {
    // Local fallback for mock data
    dispatch(updateAlertStatus({ id, status: 'RESPONDING' }));
    return rejectWithValue(err.response?.data?.detail || 'Failed to dispatch unit');
  }
});

export const resolveSos = createAsyncThunk('sos/resolve', async (id, { dispatch, rejectWithValue }) => {
  try {
    const { data } = await incidentService.update(id, { status: 'resolved' });
    dispatch(updateAlertStatus({ id, status: 'RESOLVED' }));
    return data;
  } catch (err) {
    // Local fallback for mock data
    dispatch(updateAlertStatus({ id, status: 'RESOLVED' }));
    return rejectWithValue(err.response?.data?.detail || 'Failed to resolve SOS');
  }
});

const formatTime = (iso) => {
  const diff = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'Just now';
  if (mins < 60) return `${mins} min ago`;
  return `${Math.floor(mins / 60)} hr ago`;
};

const sosSlice = createSlice({
  name: 'sos',
  initialState: { activeAlerts: [], loading: false, error: null },
  reducers: {
    addAlert: (state, action) => {
      state.activeAlerts.unshift(action.payload);
    },
    removeAlert: (state, action) => {
      state.activeAlerts = state.activeAlerts.filter((a) => a.id !== action.payload);
    },
    updateAlertStatus: (state, action) => {
      const { id, status } = action.payload;
      const alert = state.activeAlerts.find((a) => a.id === id);
      if (alert) {
        alert.status = status;
      }
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchActiveSos.pending, (state) => { state.loading = true; })
      .addCase(fetchActiveSos.fulfilled, (state, action) => {
        state.loading = false;
        state.activeAlerts = action.payload.map((inc) => ({
          id: inc.id,
          user: inc.user_name,
          mobile: inc.user_mobile,
          lat: inc.lat,
          lng: inc.lng,
          priority: inc.is_silent ? 'medium' : 'high',
          time: formatTime(inc.created_at),
          status: inc.status.toUpperCase(),
        }));
      })
      .addCase(fetchActiveSos.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export const { addAlert, removeAlert, updateAlertStatus } = sosSlice.actions;
export default sosSlice.reducer;
