import api from '@/lib/axios';

export const userService = {
    async getProfile() {
        const response = await api.get('/users/profile');
        return response.data;
    },
    async updateProfile(data: any) {
        const response = await api.put('/users/profile', data);
        return response.data;
    },
    async getAllUsers() {
        const response = await api.get('/admin/users');
        return response.data;
    }
};
