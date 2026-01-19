import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user's orders
  Future<List<Order>> getUserOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (
                name,
                image_url,
                price
              )
            ),
            order_timeline (*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => _parseOrder(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // Get single order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (
                name,
                image_url,
                price
              )
            ),
            order_timeline (*)
          ''')
          .eq('id', orderId)
          .single();

      return _parseOrder(response);
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);

      // Add timeline entry
      await _supabase.from('order_timeline').insert({
        'order_id': orderId,
        'status': 'cancelled',
        'timestamp': DateTime.now().toIso8601String(),
        'note': 'Order cancelled by customer',
      });
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Reorder (create new order from existing)
  Future<String> reorder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      
      // Create new order with same items
      final newOrderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': _supabase.auth.currentUser!.id,
            'status': 'pending',
            'subtotal': order.subtotal,
            'discount': 0,
            'shipping_fee': order.shippingFee,
            'total': order.subtotal + order.shippingFee,
            'shipping_address': order.shippingAddress,
            'payment_method': order.paymentMethod,
          })
          .select()
          .single();

      final newOrderId = newOrderResponse['id'] as String;

      // Insert order items
      for (final item in order.items) {
        await _supabase.from('order_items').insert({
          'order_id': newOrderId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'size': item.size,
        });
      }

      return newOrderId;
    } catch (e) {
      throw Exception('Failed to reorder: $e');
    }
  }

  // Track shipment (GHN/GHTK integration)
  Future<Map<String, dynamic>> trackShipment(String trackingNumber, String provider) async {
    try {
      // TODO: Integrate with actual GHN/GHTK API
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'tracking_number': trackingNumber,
        'provider': provider,
        'status': 'in_transit',
        'estimated_delivery': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'current_location': 'Distribution Center - Ho Chi Minh City',
      };
    } catch (e) {
      throw Exception('Failed to track shipment: $e');
    }
  }

  // Helper to parse order from JSON
  Order _parseOrder(Map<String, dynamic> json) {
    final items = (json['order_items'] as List).map((item) {
      final product = item['products'];
      return OrderItem(
        productId: item['product_id'] as String,
        productName: product['name'] as String,
        productImage: product['image_url'] as String,
        price: (item['price'] as num).toDouble(),
        quantity: item['quantity'] as int,
        size: item['size'] as String?,
      );
    }).toList();

    final timeline = (json['order_timeline'] as List).map((t) {
      return OrderTimeline.fromJson(t);
    }).toList();

    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      items: items,
      timeline: timeline,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as String,
      trackingNumber: json['tracking_number'] as String?,
      shippingProvider: json['shipping_provider'] as String?,
      paymentMethod: json['payment_method'] as String,
    );
  }
}
