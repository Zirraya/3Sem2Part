import React, { useState } from 'react';
import { Container, Box, Typography, Paper, Alert } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { CustomInput } from '../ui/CustomInput';
import { CustomButton } from '../ui/CustomButton';
import { postRequest } from '../services/api';
import { setUser, setToken } from '../store/slices/authSlice';
import { ILoginRequest, ILoginResponse } from '../types';

export const Login: React.FC = () => {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [formData, setFormData] = useState<ILoginRequest>({
    email: '',
    password: '',
  });
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    try {
      const response = await postRequest<ILoginResponse, ILoginRequest>(
        '/auth/login',
        formData
      );
      dispatch(setUser(response.user));
      dispatch(setToken(response.token));
      navigate('/dashboard');
    } catch (err) {
      setError('Неверный email или пароль');
    }
  };

  return (
    <Container component="main" maxWidth="xs">
      <Box
        sx={{
          marginTop: 8,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <Paper elevation={3} sx={{ p: 4, width: '100%' }}>
          <Typography component="h1" variant="h5" textAlign="center" gutterBottom>
            Вход в систему
          </Typography>
          
          {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
          
          <Box component="form" onSubmit={handleSubmit}>
            <CustomInput
              margin="normal"
              required
              fullWidth
              label="Email"
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
            />
            <CustomInput
              margin="normal"
              required
              fullWidth
              label="Пароль"
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
            />
            <CustomButton
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              tooltip="Войти в аккаунт"
            >
              Войти
            </CustomButton>
            <CustomButton
              fullWidth
              variant="text"
              onClick={() => navigate('/register')}
              tooltip="Создать новый аккаунт"
            >
              Нет аккаунта? Зарегистрироваться
            </CustomButton>
          </Box>
        </Paper>
      </Box>
    </Container>
  );
};