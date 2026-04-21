import React, { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Grid,
  Card,
  CardContent,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow
} from '@mui/material';
import { useSelector } from 'react-redux';
import { RootState } from '../store/store';
import { getRequest } from '../services/api';

interface IAnalyticsData {
  totalUsers: number;
  totalPosts: number;
  totalProducts: number;
  recentActivity: IActivity[];
}

interface IActivity {
  id: number;
  type: 'post' | 'product';
  action: 'created' | 'updated' | 'deleted';
  title: string;
  timestamp: string;
}

export const AnalyticsPage: React.FC = () => {
  const { posts, products } = useSelector((state: RootState) => state.data);
  const [analytics, setAnalytics] = useState<IAnalyticsData | null>(null);

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        const data = await getRequest<IAnalyticsData>('/analytics');
        setAnalytics(data);
      } catch (error) {
        setAnalytics({
          totalUsers: 1,
          totalPosts: posts.length,
          totalProducts: products.length,
          recentActivity: []
        });
      }
    };
    fetchAnalytics();
  }, [posts.length, products.length]);

  const stats = [
    { title: 'Пользователей', value: analytics?.totalUsers || 0, color: '#1976d2' },
    { title: 'Постов', value: analytics?.totalPosts || posts.length, color: '#2e7d32' },
    { title: 'Товаров', value: analytics?.totalProducts || products.length, color: '#ed6c02' },
  ];

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" gutterBottom>
          Аналитика
        </Typography>
        <Typography color="text.secondary" sx={{ mb: 4 }}>
          Общая статистика вашей активности
        </Typography>

        <Grid container spacing={3} sx={{ mb: 4 }}>
          {stats.map((stat, index) => (
            <Grid size={{ xs: 12, md: 4 }} key={index}>
              <Card>
                <CardContent>
                  <Typography color="text.secondary" gutterBottom>
                    {stat.title}
                  </Typography>
                  <Typography variant="h3" sx={{ color: stat.color }}>
                    {stat.value}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        <Typography variant="h5" gutterBottom sx={{ mt: 4 }}>
          Последние действия
        </Typography>
        
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Тип</TableCell>
                <TableCell>Действие</TableCell>
                <TableCell>Название</TableCell>
                <TableCell>Дата</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {analytics?.recentActivity.length === 0 && (
                <TableRow>
                  <TableCell colSpan={4} align="center">
                    Нет данных об активности
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>
    </Container>
  );
};