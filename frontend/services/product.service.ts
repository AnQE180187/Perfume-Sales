import api from '@/lib/axios';

export interface Product {
    id: string;
    name: string;
    slug: string;
    price: number;
    currency: string;
    description?: string;
    gender?: string;
    longevity?: string;
    concentration?: string;
    isActive: boolean;
    brand: { id: number; name: string };
    category?: { id: number; name: string };
    scentFamily?: { id: number; name: string };
    images: { id: number; url: string; order: number }[];
    inventory?: { quantity: number };
}

export const productService = {
    async list(query?: any) {
        const response = await api.get('/products', { params: query });
        return response.data; // { data: Product[], meta: { total, pages, etc } }
    },

    async getById(id: string) {
        const response = await api.get(`/products/${id}`);
        return response.data;
    },

    // Admin/Staff methods
    async adminList(query?: any) {
        const response = await api.get('/admin/products', { params: query });
        return response.data;
    },

    async create(data: any) {
        const response = await api.post('/admin/products', data);
        return response.data;
    },

    async update(id: string, data: any) {
        const response = await api.patch(`/admin/products/${id}`, data);
        return response.data;
    },

    async remove(id: string) {
        const response = await api.delete(`/admin/products/${id}`);
        return response.data;
    },

    async uploadImages(productId: string, formData: FormData) {
        const response = await api.post(`/admin/products/${productId}/images`, formData, {
            headers: {
                'Content-Type': 'multipart/form-data',
            },
        });
        return response.data;
    },

    async deleteImage(productId: string, imageId: number) {
        const response = await api.delete(`/admin/products/${productId}/images/${imageId}`);
        return response.data;
    }
};
