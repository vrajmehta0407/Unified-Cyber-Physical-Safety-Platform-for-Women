import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { evidenceService } from '../../services/incidentService';

export const fetchEvidence = createAsyncThunk('evidence/fetchAll', async (_, { rejectWithValue }) => {
  try {
    const { data } = await evidenceService.getAll();
    return data;
  } catch (err) {
    return rejectWithValue(err.response?.data?.detail || 'Failed to fetch evidence');
  }
});

const evidenceSlice = createSlice({
  name: 'evidence',
  initialState: {
    items: [],
    loading: false,
    error: null,
  },
  reducers: {
    clearEvidenceError: (state) => { state.error = null; },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchEvidence.pending, (state) => { state.loading = true; state.error = null; })
      .addCase(fetchEvidence.fulfilled, (state, action) => { state.loading = false; state.items = action.payload; })
      .addCase(fetchEvidence.rejected, (state, action) => { state.loading = false; state.error = action.payload; });
  },
});

export const { clearEvidenceError } = evidenceSlice.actions;
export default evidenceSlice.reducer;
