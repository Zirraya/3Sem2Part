import React from 'react';
import { Box, Card, CardContent, Typography } from '@mui/material';
import { useSelector } from 'react-redux';
import { RootState } from '../store/store';

export const Dashboard: React.FC = () => {
  const { user } = useSelector((state: RootState) => state.auth);
  const { posts, products } = useSelector((state: RootState) => state.data);

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Добро пожаловать, {user?.firstName} {user?.lastName}!
      </Typography>
      <Typography color="text.secondary" sx={{ mb: 3 }}>
        Ваша роль: {user?.role === 'admin' ? 'Администратор' : 'Пользователь'}
      </Typography>

      <Box sx={{ 
        display: 'flex', 
        gap: 3, 
        flexWrap: 'wrap',
        '& > *': {
          flex: { xs: '1 1 100%', md: '1 1 30%' }
        }
      }}>
        <Card>
          <CardContent>
            <Typography color="text.secondary" gutterBottom>
              Всего постов
            </Typography>
            <Typography variant="h4">
              {posts.length}
            </Typography>
          </CardContent>
        </Card>
        
        <Card>
          <CardContent>
            <Typography color="text.secondary" gutterBottom>
              Всего продуктов
            </Typography>
            <Typography variant="h4">
              {products.length}
            </Typography>
          </CardContent>
        </Card>
        
        <Card>
          <CardContent>
            <Typography color="text.secondary" gutterBottom>
              Статус
            </Typography>
            <Typography variant="h4">
              Активен
            </Typography>
          </CardContent>
        </Card>
      </Box>
    </Box>
  );
};