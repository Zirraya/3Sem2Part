import React from 'react';
import { Backdrop, CircularProgress, Typography, Box } from '@mui/material';

export const LoadingOverlay: React.FC = () => {
  return (
    <Backdrop
      sx={{
        color: '#fff',
        zIndex: (theme) => theme.zIndex.drawer + 1,
        flexDirection: 'column',
        gap: 2
      }}
      open={true}
    >
      <CircularProgress color="inherit" />
      <Typography variant="h6">Загрузка...</Typography>
    </Backdrop>
  );
};