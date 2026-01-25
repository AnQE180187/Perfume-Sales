import { useAuthStore } from '@/store/auth.store';
import { authService } from '@/services/auth.service';
import { useRouter } from 'next/navigation';

export const useAuth = () => {
    const { user, token, setAuth, logout: clearAuth } = useAuthStore();
    const router = useRouter();

    const login = async (credentials: any) => {
        try {
            const data = await authService.login(credentials);
            setAuth(data.user, data.token);
            localStorage.setItem('token', data.token);
            return data;
        } catch (error) {
            throw error;
        }
    };

    const register = async (userData: any) => {
        try {
            const data = await authService.register(userData);
            setAuth(data.user, data.token);
            localStorage.setItem('token', data.token);
            return data;
        } catch (error) {
            throw error;
        }
    };

    const logout = () => {
        clearAuth();
        router.push('/logout');
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
