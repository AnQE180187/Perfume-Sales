import api from '@/lib/axios';

export const authService = {
    async login(credentials: any) {
        const response = await api.post('/auth/login', credentials);
        return response.data;
    },
    async register(data: any) {
        const response = await api.post('/auth/register', data);
        return response.data;
    },
    async refresh() {
        const response = await api.post('/auth/refresh');
        return response.data;
    }
};
