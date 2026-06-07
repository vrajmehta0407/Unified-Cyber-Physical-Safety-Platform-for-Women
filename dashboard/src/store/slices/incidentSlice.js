import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { incidentService } from '../../services/incidentService';

export const fetchIncidents = createAsyncThunk('incidents/fetch', async (_, { rejectWithValue }) => {
  try {
    const { data } = await incidentService.getAll();
    return data;
  } catch (err) {
    return rejectWithValue(err.response?.data?.detail || 'Failed to load incidents');
  }
});

const incidentSlice = createSlice({
  name: 'incidents',
  initialState: { list: [], loading: false, error: null },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchIncidents.pending, (state) => { state.loading = true; state.error = null; })
      .addCase(fetchIncidents.fulfilled, (state, action) => { state.loading = false; state.list = action.payload; })
      .addCase(fetchIncidents.rejected, (state, action) => { state.loading = false; state.error = action.payload; });
  },
});

export default incidentSlice.reducer;
