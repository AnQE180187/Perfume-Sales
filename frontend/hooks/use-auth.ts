import { useAuthStore } from '@/store/auth.store';
import { authService } from '@/services/auth.service';
import { userService } from '@/services/user.service';
import { useRouter } from 'next/navigation';

export const useAuth = () => {
    const { user, token, setAuth, logout: clearAuth } = useAuthStore();
    const router = useRouter();

    const login = async (credentials: any) => {
        try {
            const data = await authService.login(credentials);
            const { accessToken } = data;

            // Set token in localStorage for next requests
            localStorage.setItem('token', accessToken);

            // Fetch user profile
            const userData = await userService.getMe();

            setAuth(userData, accessToken);
            return { user: userData, token: accessToken };
        } catch (error) {
            throw error;
        }
    };

    const register = async (userData: any) => {
        try {
            const data = await authService.register(userData);
            const { accessToken } = data;

            localStorage.setItem('token', accessToken);

            // Fetch user profile
            const profile = await userService.getMe();

            setAuth(profile, accessToken);
            return { user: profile, token: accessToken };
        } catch (error) {
            throw error;
        }
    };

    const logout = (shouldRedirect: boolean = true) => {
        clearAuth();
        localStorage.removeItem('token');
        if (shouldRedirect) {
            router.push('/');
        }
    };

    return {
        user,
        token,
        isAuthenticated: !!token,
        login,
        register,
        logout,
    };
};
