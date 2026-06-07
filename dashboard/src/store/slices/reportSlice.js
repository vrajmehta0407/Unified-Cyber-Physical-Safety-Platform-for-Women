import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { reportService } from '../../services/incidentService';

export const fetchReports = createAsyncThunk('reports/fetchAll', async (_, { rejectWithValue }) => {
  try {
    const { data } = await reportService.getAll();
    return data;
  } catch (err) {
    return rejectWithValue(err.response?.data?.detail || 'Failed to fetch reports');
  }
});

const reportSlice = createSlice({
  name: 'reports',
  initialState: {
    reports: [],
    loading: false,
    error: null,
  },
  reducers: {
    clearReportError: (state) => { state.error = null; },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchReports.pending, (state) => { state.loading = true; state.error = null; })
      .addCase(fetchReports.fulfilled, (state, action) => { state.loading = false; state.reports = action.payload; })
      .addCase(fetchReports.rejected, (state, action) => { state.loading = false; state.error = action.payload; });
  },
});

export const { clearReportError } = reportSlice.actions;
export default reportSlice.reducer;
