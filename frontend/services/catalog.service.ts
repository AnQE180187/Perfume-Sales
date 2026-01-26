import api from '@/lib/axios';

export interface Note {
    id: number;
    name: string;
    description?: string;
    type: 'TOP' | 'MIDDLE' | 'BASE';
    image_url?: string;
}

export interface ProductNote {
    productId: string;
    noteId: number;
    note: Note;
}

export interface Product {
    id: string;
    name: string;
    slug: string;
    description: string;
    price: number;
    currency: string;
    stock: number;
    gender: 'MALE' | 'FEMALE' | 'UNISEX';
    concentration: 'EDP' | 'EDT' | 'EXTRAIT' | 'COLOGNE';
    brand: {
        id: number;
        name: string;
    };
    category?: {
        id: number;
        name: string;
    };
    images: {
        id: number;
        url: string;
        order: number;
    }[];
    notes?: ProductNote[];
}

export interface Category {
    id: number;
    name: string;
    description?: string;
}

export interface Brand {
    id: number;
    name: string;
    description?: string;
}

export const catalogService = {
    async getProducts(params?: { categoryId?: number; brandId?: number; search?: string; skip?: number; take?: number }) {
        const response = await api.get('/products', { params });
        return response.data;
    },

    async getProduct(id: string) {
        const response = await api.get(`/products/${id}`);
        return response.data;
    },

    async getCategories() {
        const response = await api.get('/catalog/categories');
        return response.data;
    },

    async getBrands() {
        const response = await api.get('/catalog/brands');
        return response.data;
    },

    async getScentFamilies() {
        const response = await api.get('/catalog/scent-families');
        return response.data;
    }
};
