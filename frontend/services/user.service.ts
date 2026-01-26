import api from '@/lib/axios';

// Backend: GET/PATCH /users/me
export const userService = {
    async getMe() {
        const { data } = await api.get('/users/me');
        return data;
    },
    async updateProfile(payload: { fullName?: string; gender?: string; dateOfBirth?: string; address?: string; city?: string; country?: string; avatarUrl?: string; budgetMin?: number; budgetMax?: number }) {
        const { data } = await api.patch('/users/me', payload);
        return data;
    },
};
