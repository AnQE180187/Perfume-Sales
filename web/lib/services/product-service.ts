import { apiClient } from '../api-client';

export const ProductService = {
    // Get all active products with nested details
    async getProducts(filters?: { gender?: string; brand_id?: string; category_id?: string }) {
        const response = await apiClient.getProducts({
            gender: filters?.gender,
            brandId: filters?.brand_id,
            categoryId: filters?.category_id,
        });
        if (response.error) throw new Error(response.error);
        return response.data || [];
    },

    // Get single product by slug or ID
    async getProductDetail(idOrSlug: string) {
        const response = await apiClient.getProduct(idOrSlug);
        if (response.error) throw new Error(response.error);
        return response.data;
    },

    // Semantic Search (Requires pgvector match_products function)
    async searchSemantic(queryText: string) {
        // TODO: Implement semantic search endpoint in backend
        // For now, use regular product search
        const response = await apiClient.getProducts();
        if (response.error) throw new Error(response.error);
        // Simple text matching for now
        const products = response.data || [];
        const lowerQuery = queryText.toLowerCase();
        return products.filter((p: any) => 
            p.name?.toLowerCase().includes(lowerQuery) ||
            p.description?.toLowerCase().includes(lowerQuery)
        );
    }
};
