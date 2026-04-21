import React, { useEffect, useState } from 'react';
import { Container, Typography, Box, Grid, Paper, Card, CardContent } from '@mui/material';
import { useSelector } from 'react-redux';
import { RootState } from '../store/store';
import { getRequest } from '../services/api';
import { CustomButton } from '../ui/CustomButton';

interface IStats {
  totalPosts: number;
  totalComments: number;
  totalProducts: number;
  lastLogin: string;
}

export const Dashboard: React.FC = () => {
  const { user } = useSelector((state: RootState) => state.auth);
  const [stats, setStats] = useState<IStats | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      const data = await getRequest<IStats>('/dashboard/stats');
      setStats(data);
    };
    fetchStats();
  }, []);

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" gutterBottom>
          Добро пожаловать, {user?.firstName} {user?.lastName}!
        </Typography>
        <Typography color="text.secondary" paragraph>
          Ваша роль: {user?.role === 'admin' ? 'Администратор' : 'Пользователь'}
        </Typography>
      </Box>

      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" gutterBottom>
                Всего постов
              </Typography>
              <Typography variant="h3">
                {stats?.totalPosts || 0}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" gutterBottom>
                Комментариев
              </Typography>
              <Typography variant="h3">
                {stats?.totalComments || 0}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" gutterBottom>
                Товаров
              </Typography>
              <Typography variant="h3">
                {stats?.totalProducts || 0}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Container>
  );
};