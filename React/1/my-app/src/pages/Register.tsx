import React, { useState } from 'react';
import { Container, Box, Typography, Paper, Alert } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { CustomInput } from '../ui/CustomInput';
import { CustomButton } from '../ui/CustomButton';
import { postRequest } from '../services/api';
import { setUser, setToken } from '../store/slices/authSlice';
import { IRegisterRequest, ILoginResponse } from '../types';

export const Register: React.FC = () => {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [formData, setFormData] = useState<IRegisterRequest>({
    email: '',
    password: '',
    firstName: '',
    lastName: '',
  });
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    try {
      const response = await postRequest<ILoginResponse, IRegisterRequest>(
        '/auth/register',
        formData
      );
      dispatch(setUser(response.user));
      dispatch(setToken(response.token));
      navigate('/dashboard');
    } catch (err) {
      setError('Ошибка регистрации. Попробуйте другой email.');
    }
  };

  return (
    <Container component="main" maxWidth="xs">
      <Box sx={{ marginTop: 8, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <Paper elevation={3} sx={{ p: 4, width: '100%' }}>
          <Typography component="h1" variant="h5" textAlign="center" gutterBottom>
            Регистрация
          </Typography>
          
          {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
          
          <Box component="form" onSubmit={handleSubmit}>
            <CustomInput
              margin="normal"
              required
              fullWidth
              label="Имя"
              value={formData.firstName}
              onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
            />
            <CustomInput
              margin="normal"
              required
              fullWidth
              label="Фамилия"
              value={formData.lastName}
              onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
            />
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
              tooltip="Создать новый аккаунт"
            >
              Зарегистрироваться
            </CustomButton>
            <CustomButton
              fullWidth
              variant="text"
              onClick={() => navigate('/login')}
              tooltip="Войти в существующий аккаунт"
            >
              Уже есть аккаунт? Войти
            </CustomButton>
          </Box>
        </Paper>
      </Box>
    </Container>
  );
};