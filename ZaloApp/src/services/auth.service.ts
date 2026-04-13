import { getAccessToken, getPhoneNumber, getUserInfo, login } from 'zmp-sdk/apis';
import axiosClient, { setAccessToken } from './axiosClient';

export const authService = {
  /**
   * Performs Zalo login, fetch access token and sends to backend
   * to exchange for our system JWT.
   */
  async login(): Promise<any> {
    try {
      // 1. Zalo Login
      await login({});
      
      // 2. Lấy Access Token của Zalo
      const accessToken = await getAccessToken({});
      
      // 3. Lấy thông tin user cơ bản từ Zalo (được phép sau login)
      const userInfo = await getUserInfo({});

      let phoneToken = '';
      try {
        // Gồm permission: getPhoneNumber
        const phoneData = await getPhoneNumber({});
        phoneToken = phoneData.token;
      } catch (err) {
        console.log('User did not provide phone number');
      }

      // 4. Gửi token lên Backend NestJS để lấy JWT hệ thống
      const data = await axiosClient.post('/auth/social-login', {
        provider: 'zalo',
        token: accessToken,
        providerId: userInfo.userInfo.id,
        avatarUrl: userInfo.userInfo.avatar,
        fullName: userInfo.userInfo.name,
      });

      // 5. Lưu Access Token vào hệ thống axios
      if (data && data.accessToken) {
        setAccessToken(data.accessToken);
        return data.user; // Trả về profile User của backend
      }
      
      return null;
    } catch (error) {
      console.error('Zalo Auth Error', error);
      throw error;
    }
  },
};
