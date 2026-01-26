import api from '@/lib/axios';

// Backend returns { accessToken, refreshToken }
export const authService = {
    async login(credentials: { email: string; password: string }) {
        const { data } = await api.post<{ accessToken: string; refreshToken: string }>('/auth/login', credentials);
        return data;
    },
    async register(payload: { email: string; password: string; full_name?: string; fullName?: string; phone?: string }) {
        const { data } = await api.post<{ accessToken: string; refreshToken: string }>('/auth/register', {
            email: payload.email,
            password: payload.password,
            fullName: payload.fullName ?? payload.full_name ?? undefined,
            phone: payload.phone || undefined,
        });
        return data;
    },
    async refresh(refreshToken: string) {
        const { data } = await api.post<{ accessToken: string; refreshToken: string }>('/auth/refresh', { refreshToken });
        return data;
    },
};
