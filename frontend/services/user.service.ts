import api from '@/lib/axios';

export const userService = {
    async getMe() {
        const response = await api.get('/users/me');
        return response.data;
    },
    async updateMe(data: any) {
        const response = await api.patch('/users/me', data);
        return response.data;
    },
    async getAllUsers() {
        const response = await api.get('/admin/users');
        return response.data;
    }
};
