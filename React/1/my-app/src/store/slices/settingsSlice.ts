import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { IAppSettingsState } from '../../types';

const initialState: IAppSettingsState = {
  isLoading: false,
  errorModal: {
    isOpen: false,
    message: '',
    statusCode: undefined,
  },
  loadingOverlay: {
    isVisible: false,
    requestId: null,
  },
};

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    startLoading: (state, action: PayloadAction<string>) => {
      state.loadingOverlay.isVisible = true;
      state.loadingOverlay.requestId = action.payload;
      state.isLoading = true;
    },
    stopLoading: (state) => {
      state.loadingOverlay.isVisible = false;
      state.loadingOverlay.requestId = null;
      state.isLoading = false;
    },
    showError: (
      state,
      action: PayloadAction<{ message: string; statusCode?: number }>
    ) => {
      state.errorModal = {
        isOpen: true,
        message: action.payload.message,
        statusCode: action.payload.statusCode,
      };
    },
    hideError: (state) => {
      state.errorModal.isOpen = false;
      state.errorModal.message = '';
      state.errorModal.statusCode = undefined;
    },
  },
});

export const { startLoading, stopLoading, showError, hideError } =
  settingsSlice.actions;
export default settingsSlice.reducer;