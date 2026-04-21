export interface IUser {
  id: number;
  email: string;
  firstName: string;
  lastName: string;
  role: 'user' | 'admin';
  createdAt: string;
}

export interface IAuthState {
  user: IUser | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export interface IAppSettingsState {
  isLoading: boolean;
  errorModal: {
    isOpen: boolean;
    message: string;
    statusCode?: number;
  };
  loadingOverlay: {
    isVisible: boolean;
    requestId: string | null;
  };
}

export interface ILoginRequest {
  email: string;
  password: string;
}

export interface IRegisterRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

export interface ILoginResponse {
  user: IUser;
  token: string;
}

export interface IApiError {
  message: string;
  statusCode: number;
}