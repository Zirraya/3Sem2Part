import React from 'react';
import { Outlet } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../store/store';
import { Modal, Box, Typography, Button } from '@mui/material';
import { hideError } from '../store/slices/settingsSlice';
import LoadingOverlay from '../components/LoadingOverlay';

const modalStyle = {
  position: 'absolute' as const,
  top: '50%',
  left: '50%',
  transform: 'translate(-50%, -50%)',
  width: 400,
  bgcolor: 'background.paper',
  boxShadow: 24,
  p: 4,
  borderRadius: 2,
};

export const CommonWrapper: React.FC = () => {
  const dispatch = useDispatch();
  const { loadingOverlay, errorModal } = useSelector(
    (state: RootState) => state.settings
  );

  return (
    <>
      {loadingOverlay.isVisible && <LoadingOverlay />}
      
      <Modal open={errorModal.isOpen} onClose={() => dispatch(hideError())}>
        <Box sx={modalStyle}>
          <Typography variant="h6" component="h2" color="error">
            Ошибка
          </Typography>
          <Typography sx={{ mt: 2 }}>
            {errorModal.message}
          </Typography>
          {errorModal.statusCode && (
            <Typography variant="caption" color="text.secondary">
              Код ошибки: {errorModal.statusCode}
            </Typography>
          )}
          <Button
            onClick={() => dispatch(hideError())}
            sx={{ mt: 2 }}
            variant="contained"
          >
            Закрыть
          </Button>
        </Box>
      </Modal>
      
      <Outlet />
    </>
  );
};