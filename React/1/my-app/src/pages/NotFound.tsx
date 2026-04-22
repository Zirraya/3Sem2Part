import React from 'react';
import { Container, Typography, Box, Button } from '@mui/material';
import { useNavigate } from 'react-router-dom';

export const NotFound: React.FC = () => {
  const navigate = useNavigate();

  return (
    <Container maxWidth="md">
      <Box sx={{ textAlign: 'center', my: 8 }}>
        <Typography variant="h1" component="h1" gutterBottom>
          404
        </Typography>
        <Typography variant="h4" gutterBottom>
          Страница не найдена
        </Typography>
        <Typography color="text.secondary" variant="body1" gutterBottom>
          Запрашиваемая страница не существует или была перемещена.
        </Typography>
        <Button variant="contained" onClick={() => navigate('/')}>
          На главную
        </Button>
      </Box>
    </Container>
  );
};