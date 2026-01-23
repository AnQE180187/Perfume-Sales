import { apiClient } from '../api-client';

export const UserService = {
    // Update user scent preferences from quiz results
    async updateScentPreferences(userId: string, preferences: any) {
        // TODO: Add scent preferences endpoint to backend
        // For now, update via profile update
        const response = await apiClient.updateMe({ scentPreferences: preferences });
        if (response.error) throw new Error(response.error);
        return response.data;
    },

    // Wishlist (Favourite Products)
    async toggleFavourite(userId: string, productId: string) {
        // TODO: Implement wishlist endpoints in backend
        // For now, return placeholder
        throw new Error('Wishlist feature not yet implemented in backend');
    },

    // Addresses
    async getAddresses(userId: string) {
        // TODO: Implement addresses endpoint in backend
        // For now, return empty array
        return [];
    },

    // Loyalty History
    async getLoyaltyLogs(userId: string) {
        // TODO: Implement loyalty logs endpoint in backend
        // For now, return empty array
        return [];
    }
};
