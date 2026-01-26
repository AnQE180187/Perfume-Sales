import api from '@/lib/axios';

export interface Order {
    id: string;
    orderNumber: string;
    totalAmount: number;
    status: string;
    createdAt: string;
    items: any[];
    shippingAddress: string;
    paymentMethod: string;
}

export const orderService = {
    async create(data: any) {
        const response = await api.post('/orders', data);
        return response.data;
    },

    async getMyOrders() {
        const response = await api.get('/orders/me');
        return response.data;
    },

    async getById(id: string) {
        const response = await api.get(`/orders/${id}`);
        return response.data;
    },

    // Admin methods
    async adminList(query?: any) {
        const response = await api.get('/admin/orders', { params: query });
        return response.data;
    },

    async updateStatus(id: string, status: string) {
        const response = await api.patch(`/admin/orders/${id}/status`, { status });
        return response.data;
    }
};
