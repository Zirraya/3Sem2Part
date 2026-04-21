import React from 'react';
import { Container, Typography, Box, Paper, Avatar, Grid } from '@mui/material';
import { useSelector } from 'react-redux';
import { RootState } from '../store/store';
import { CustomButton } from '../ui/CustomButton';
import { useDispatch } from 'react-redux';
import { logout } from '../store/slices/authSlice';
import { useNavigate } from 'react-router-dom';

export const Profile: React.FC = () => {
  const { user } = useSelector((state: RootState) => state.auth);
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const handleLogout = () => {
    dispatch(logout());
    navigate('/');
  };

  return (
    <Container maxWidth="md">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" gutterBottom>
          Личный кабинет
        </Typography>
        
        <Paper sx={{ p: 4, mt: 3 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 4 }}>
            <Avatar sx={{ width: 80, height: 80, bgcolor: 'primary.main', mr: 3 }}>
              {user?.firstName?.[0]}{user?.lastName?.[0]}
            </Avatar>
            <Box>
              <Typography variant="h5">
                {user?.firstName} {user?.lastName}
              </Typography>
              <Typography color="text.secondary">
                {user?.email}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Зарегистрирован: {new Date(user?.createdAt || '').toLocaleDateString()}
              </Typography>
            </Box>
          </Box>

          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" color="text.secondary">Имя</Typography>
              <Typography variant="body1">{user?.firstName}</Typography>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" color="text.secondary">Фамилия</Typography>
              <Typography variant="body1">{user?.lastName}</Typography>
            </Grid>
            <Grid item xs={12}>
              <Typography variant="subtitle2" color="text.secondary">Email</Typography>
              <Typography variant="body1">{user?.email}</Typography>
            </Grid>
            <Grid item xs={12}>
              <Typography variant="subtitle2" color="text.secondary">Роль</Typography>
              <Typography variant="body1">
                {user?.role === 'admin' ? 'Администратор' : 'Пользователь'}
              </Typography>
            </Grid>
          </Grid>

          <Box sx={{ mt: 4, display: 'flex', gap: 2 }}>
            <CustomButton
              variant="contained"
              color="error"
              onClick={handleLogout}
              tooltip="Выйти из аккаунта"
            >
              Выйти
            </CustomButton>
          </Box>
        </Paper>
      </Box>
    </Container>
  );
};