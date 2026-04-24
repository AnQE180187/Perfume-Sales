import { getAccessToken, getPhoneNumber, getUserInfo, login } from 'zmp-sdk/apis';
import axiosClient, { setAccessToken } from './axiosClient';

export const authService = {
  /**
   * Performs Zalo login, fetches Zalo access token + phone number,
   * and sends them to the backend to create/link our system JWT.
   */
  async loginWithEmail(email: string, password: string):Promise<any> {
    const data: any = await axiosClient.post('/auth/login', { email, password });
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
    const data: any = await axiosClient.post('/auth/register', payload);
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

  async loginZalo(): Promise<any> {
    try {
      // Đảm bảo session đã được khởi tạo
      await login({});
      // Gọi Zalo SDK lấy thông tin người dùng
      const zaloUser = await getUserInfo({ avatarType: "normal" });
      const { id, name, avatar } = zaloUser.userInfo;
      const token = await getAccessToken();

      // Gửi thông tin lên backend để tạo/liên kết tài khoản
      const payload = {
        provider: 'zalo',
        providerId: id,
        fullName: name,
        avatarUrl: avatar,
        token: token,
      };

      const data: any = await axiosClient.post('/auth/social-login', payload);

      if (data && data.accessToken) {
        setAccessToken(data.accessToken);
        if (data.refreshToken) {
          localStorage.setItem('refreshToken', data.refreshToken);
        }
        return data.user;
      }
      return null;
    } catch (error: any) {
      console.error("Zalo Login Error:", error);
      throw error;
    }
  },

  /**
   * Silently re-authenticate using the stored refresh token.
   * Called on app boot if user has previously logged in.
   */
  async silentReLogin(): Promise<any> {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) return null;
    try {
      const data: any = await axiosClient.post('/auth/refresh', { refreshToken });
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

