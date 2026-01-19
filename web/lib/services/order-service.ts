import { supabaseAdmin } from '../supabaseAdmin';

export const OrderService = {
    // Create a new order (Online, POS, or Mobile App)
    async createOrder(payload: {
        user_id?: string;
        customer_info?: any;
        staff_id?: string;
        channel: 'website' | 'pos' | 'mobile_app' | 'shopee';
        items: Array<{ variant_id: string; quantity: number; unit_price: number }>;
        shipping_address?: any;
        payment_method: string;
        promotion_id?: string;
        shipping_fee: number;
        total_amount: number;
        discount_amount: number;
        final_amount: number;
    }) {
        // 1. Check stock for all variants
        for (const item of payload.items) {
            const { data: variant, error: vError } = await supabaseAdmin
                .from('product_variants')
                .select('stock, sku')
                .eq('id', item.variant_id)
                .single();

            if (vError || !variant || variant.stock < item.quantity) {
                throw new Error(`Insufficient stock for product ${variant?.sku || item.variant_id}`);
            }
        }

        // 2. Insert Order Header
        const { data: order, error: orderError } = await supabaseAdmin
            .from('orders')
            .insert({
                user_id: payload.user_id,
                customer_info: payload.customer_info,
                staff_id: payload.staff_id,
                channel: payload.channel,
                total_amount: payload.total_amount,
                discount_amount: payload.discount_amount,
                shipping_fee: payload.shipping_fee,
                final_amount: payload.final_amount,
                payment_method: payload.payment_method,
                shipping_address: payload.shipping_address,
                promotion_id: payload.promotion_id
            })
            .select()
            .single();

        if (orderError) throw orderError;

        // 3. Insert Order Items (Triggers will handle stock deduction and logging)
        const orderItems = payload.items.map(item => ({
            order_id: order.id,
            variant_id: item.variant_id,
            quantity: item.quantity,
            unit_price: item.unit_price,
            subtotal: item.unit_price * item.quantity
        }));

        const { error: itemsError } = await supabaseAdmin.from('order_items').insert(orderItems);
        if (itemsError) throw itemsError;

        return order;
    },

    // Update order status (Staff/Admin)
    async updateStatus(orderId: string, newStatus: string, changedBy?: string, note?: string) {
        const { data, error } = await supabaseAdmin
            .from('orders')
            .update({ status: newStatus })
            .eq('id', orderId)
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    // Get user order history
    async getOrderHistory(userId: string) {
        const { data, error } = await supabaseAdmin
            .from('orders')
            .select(`
        *,
        items:order_items(
          *,
          variant:product_variants(
            volume_ml,
            product:products(name, main_image_url)
          )
        )
      `)
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data;
    }
};
