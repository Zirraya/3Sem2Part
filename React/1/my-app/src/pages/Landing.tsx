import React from 'react';
import { Container, Typography, Box, Button, Grid, Card, CardContent } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { CustomButton } from '../ui/CustomButton';

export const Landing: React.FC = () => {
  const navigate = useNavigate();

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4, textAlign: 'center' }}>
        <Typography variant="h2" component="h1" gutterBottom>
          Добро пожаловать!
        </Typography>
        <Typography sx={{ mb: 2 }} color="text.secondary">
          Ваш универсальный инструмент для управления данными
        </Typography>
        
        <Box sx={{ mt: 4, display: 'flex', gap: 2, justifyContent: 'center' }}>
          <CustomButton
            variant="contained"
            size="large"
            onClick={() => navigate('/login')}
            tooltip="Войти в существующий аккаунт"
          >
            Войти
          </CustomButton>
          <CustomButton
            variant="outlined"
            size="large"
            onClick={() => navigate('/register')}
            tooltip="Создать новый аккаунт"
          >
            Регистрация
          </CustomButton>
        </Box>
      </Box>

      <Grid container spacing={4} sx={{ mt: 4 }}>
        {features.map((feature, index) => (
          <Grid size={{ xs: 12, md: 4 }}>
            <Card>
              <CardContent>
                <Typography variant="h5" gutterBottom>
                  {feature.title}
                </Typography>
                <Typography color="text.secondary">
                  {feature.description}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
};

const features = [
  {
    title: 'Управление данными',
    description: 'Полный CRUD функционал для работы с вашими данными',
  },
  {
    title: 'Безопасность',
    description: 'Надежная авторизация и защита персональных данных',
  },
  {
    title: 'Аналитика',
    description: 'Детальная статистика и отчеты по вашей деятельности',
  },
];