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
  const { user } = useSelector((state: RootState) => state.auth);
  const { posts, products } = useSelector((state: RootState) => state.data);
  const [analytics, setAnalytics] = useState<IAnalyticsData | null>(null);

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        const data = await getRequest<IAnalyticsData>('/analytics');
        setAnalytics(data);
      } catch (error) {
        // Если нет эндпоинта, показываем локальные данные
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
       