import { getAccessToken, getPhoneNumber, getUserInfo, login } from 'zmp-sdk/apis';
import axiosClient, { setAccessToken } from './axiosClient';

export const authService = {
  /**
   * Performs Zalo login, fetches Zalo access token + phone number,
   * and sends them to the backend to create/link our system JWT.
   */
  async loginWithEmail(email: string, password: string):Promise<any> {
    const data = await axiosClient.post('/auth/login', { email, password });
    if (data && data.accessToken) {
      setAccessToken(data.accessToken);
      if (data.refreshToken) {
        localStorage.setItem('refreshToken', data.refreshToken);
      }
      return data.user;
    }
    return null;
  },

  async registerWithEmail(payload: {email: string, password: string, fullName: string, phone?: string}):Promise<any> {
    // Usually register endpoint returns user details or we might need to login after
    const data = await axiosClient.post('/auth/register', payload);
    // If backend auto logs in:
    if (data && data.accessToken) {
      setAccessToken(data.accessToken);
      if (data.refreshToken) {
        localStorage.setItem('refreshToken', data.refreshToken);
      }
      return data.user;
    }
    // Otherwise return success
    return data;
  },

  // Keep existing Zalo login but it won't be used
  async login(): Promise<any> {
    throw new Error('Zalo login is disabled temporarily.');
  },

  /**
   * Silently re-authenticate using the stored refresh token.
   * Called on app boot if user has previously logged in.
   */
  async silentReLogin(): Promise<any> {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) return null;
    try {
      const data = await axiosClient.post('/auth/refresh', { refreshToken });
      if (data && data.accessToken) {
        setAccessToken(data.accessToken);
        if (data.refreshToken) {
          localStorage.setItem('refreshToken', data.refreshToken);
        }
        return data.user;
      }
    } catch {
      localStorage.removeItem('refreshToken');
      localStorage.removeItem('hasLoggedIn');
    }
    return null;
  },

  logout() {
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('hasLoggedIn');
    // Clear in-memory token
    setAccessToken('');
  },
};

