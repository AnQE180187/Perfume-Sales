import { supabaseAdmin } from '../supabaseAdmin';

export const UserService = {
    // Update user scent preferences from quiz results
    async updateScentPreferences(userId: string, preferences: any) {
        const { data, error } = await supabaseAdmin
            .from('profiles')
            .update({ scent_preferences: preferences })
            .eq('id', userId)
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    // Wishlist (Favourite Products)
    async toggleFavourite(userId: string, productId: string) {
        // Check if exists
        const { data: existing } = await supabaseAdmin
            .from('favourite_products')
            .select('*')
            .eq('user_id', userId)
            .eq('product_id', productId)
            .single();

        if (existing) {
            await supabaseAdmin
                .from('favourite_products')
                .delete()
                .eq('user_id', userId)
                .eq('product_id', productId);
            return { status: 'removed' };
        } else {
            await supabaseAdmin
                .from('favourite_products')
                .insert({ user_id: userId, product_id: productId });
            return { status: 'added' };
        }
    },

    // Addresses
    async getAddresses(userId: string) {
        const { data, error } = await supabaseAdmin
            .from('user_addresses')
            .select('*')
            .eq('user_id', userId)
            .order('is_default', { ascending: false });

        if (error) throw error;
        return data;
    },

    // Loyalty History
    async getLoyaltyLogs(userId: string) {
        const { data, error } = await supabaseAdmin
            .from('loyalty_logs')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data;
    }
};
