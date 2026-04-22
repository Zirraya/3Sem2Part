import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { store } from '../store/store';
import { startLoading, stopLoading, showError } from '../store/slices/settingsSlice';
import { logout } from '../store/slices/authSlice';

const api: AxiosInstance = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

let activeRequests = 0;
let loadingRequestId: string | null = null;

api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    activeRequests++;
    if (activeRequests === 1 && !loadingRequestId) {
      loadingRequestId = Date.now().toString();
      store.dispatch(startLoading(loadingRequestId));
    }

    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    activeRequests--;
    if (activeRequests === 0 && loadingRequestId) {
      store.dispatch(stopLoading());
      loadingRequestId = null;
    }
    return response;
  },
  (error: AxiosError) => {
    activeRequests--;
    if (activeRequests === 0 && loadingRequestId) {
      store.dispatch(stopLoading());
      loadingRequestId = null;
    }

    if (error.response?.status === 401) {
      store.dispatch(logout());
    }

    const errorMessage = error.response?.data as { message?: string };
    store.dispatch(
      showError({
        message: errorMessage?.message || error.message || 'Произошла ошибка',
        statusCode: error.response?.status,
      })
    );

    return Promise.reject(error);
  }
);

// GET метод
export const getRequest = async <T>(url: string): Promise<T> => {
  const response = await api.get<T>(url);
  return response.data;
};

// POST метод
export const postRequest = async <T, D = unknown>(url: string, data?: D): Promise<T> => {
  const response = await api.post<T>(url, data);
  return response.data;
};

// PUT метод
export const putRequest = async <T, D = unknown>(url: string, data?: D): Promise<T> => {
  const response = await api.put<T>(url, data);
  return response.data;
};

// DELETE метод
export const deleteRequest = async <T>(url: string): Promise<T> => {
  const response = await api.delete<T>(url);
  return response.data;
};

// PATCH метод
export const patchRequest = async <T, D = unknown>(url: string, data?: D): Promise<T> => {
  const response = await api.patch<T>(url, data);
  return response.data;
};

export default api;