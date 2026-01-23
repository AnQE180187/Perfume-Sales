import { apiClient } from '../api-client';

export const OrderService = {
    // Create a new order (Online, POS, or Mobile App)
    async createOrder(payload: {
        user_id?: string;
        customer_info?: any;
        staff_id?: string;
        channel: 'website' | 'pos' | 'mobile_app' | 'shopee';
        items: Array<{ variant_id: string; quantity: number; unit_price: number }>;
        shipping_address?: string;
        phone?: string;
        payment_method?: string;
        promotion_id?: string;
        shipping_fee?: number;
        total_amount?: number;
        discount_amount?: number;
        final_amount?: number;
    }) {
        // Transform payload to match backend DTO (CreateOrderDto only has shippingAddress and phone)
        const orderData: any = {};
        
        if (payload.shipping_address) {
            orderData.shippingAddress = payload.shipping_address;
        }
        if (payload.phone) {
            orderData.phone = payload.phone;
        }

        // Backend creates order from cart, so we don't need to send items
        const response = await apiClient.createOrder(orderData);
        if (response.error) throw new Error(response.error);
        return response.data;
    },

    // Update order status (Staff/Admin)
    async updateStatus(orderId: string, newStatus: string, changedBy?: string, note?: string) {
        // TODO: Implement order status update endpoint in backend
        throw new Error('Order status update not yet implemented in backend');
    },

    // Get user order history
    async getOrderHistory(userId: string) {
        const response = await apiClient.getOrders();
        if (response.error) throw new Error(response.error);
        return response.data || [];
    }
};
