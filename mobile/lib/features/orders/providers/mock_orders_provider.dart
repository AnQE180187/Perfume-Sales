import '../models/order.dart';

/// Mock Orders Provider
/// 
/// Provides realistic mock order data for UI development
/// when Supabase backend is not available.
/// 
/// Enable via: AppConfig.useMockOrders = true
class MockOrdersProvider {
  static List<Order> getMockOrders() {
    final now = DateTime.now();
    
    return [
      // ACTIVE ORDER 1 - Out for Delivery
      Order(
        id: '1',
        orderNumber: 'ORDER #88219',
        createdAt: now,
        status: OrderStatus.outForDelivery,
        items: [
          OrderItem(
            productId: 'prod_1',
            productName: 'Midnight Oud',
            productImage: 'https://images.unsplash.com/photo-1541544181051-e46607bc22a4?w=400',
            price: 145.00,
            quantity: 1,
            size: '50ml',
          ),
        ],
        timeline: [
          OrderTimeline(
            status: OrderStatus.outForDelivery,
            timestamp: now,
            note: 'Out for delivery',
          ),
        ],
        subtotal: 145.00,
        discount: 0,
        shippingFee: 0,
        total: 145.00,
        shippingAddress: '123 Main St, New York, NY 10001',
        trackingNumber: 'TRK123456789',
        shippingProvider: 'GHN',
        paymentMethod: 'Cash on Delivery',
      ),
      
      // ACTIVE ORDER 2 - Shipped
      Order(
        id: '2',
        orderNumber: 'ORDER #88245',
        createdAt: now.subtract(const Duration(days: 2)),
        status: OrderStatus.shipped,
        items: [
          OrderItem(
            productId: 'prod_2',
            productName: 'AI Essence No. 5',
            productImage: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=400',
            price: 185.00,
            quantity: 1,
            size: '100ml',
          ),
        ],
        timeline: [
          OrderTimeline(
            status: OrderStatus.shipped,
            timestamp: now.subtract(const Duration(days: 1)),
            note: 'Package shipped',
          ),
        ],
        subtotal: 185.00,
        discount: 0,
        shippingFee: 0,
        total: 185.00,
        shippingAddress: '456 Park Ave, Los Angeles, CA 90001',
        trackingNumber: 'TRK987654321',
        shippingProvider: 'GHTK',
        paymentMethod: 'Cash on Delivery',
      ),
      
      // COMPLETED ORDER 1 - Delivered (NOT reviewed)
      Order(
        id: '3',
        orderNumber: 'ORDER #88200',
        createdAt: now.subtract(const Duration(days: 5)),
        status: OrderStatus.delivered,
        items: [
          OrderItem(
            productId: 'prod_3',
            productName: 'Rose Lumière',
            productImage: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=400',
            price: 165.00,
            quantity: 1,
            size: '75ml',
          ),
        ],
        timeline: [
          OrderTimeline(
            status: OrderStatus.delivered,
            timestamp: now.subtract(const Duration(days: 3)),
            note: 'Successfully delivered',
          ),
        ],
        subtotal: 165.00,
        discount: 0,
        shippingFee: 0,
        total: 165.00,
        shippingAddress: '789 Ocean Blvd, Miami, FL 33101',
        trackingNumber: 'TRK111222333',
        shippingProvider: 'GHN',
        paymentMethod: 'Credit Card',
      ),
      
      // COMPLETED ORDER 2 - Delivered (REVIEWED)
      Order(
        id: '4',
        orderNumber: 'ORDER #88180',
        createdAt: now.subtract(const Duration(days: 10)),
        status: OrderStatus.delivered,
        items: [
          OrderItem(
            productId: 'prod_4',
            productName: 'Citrus Bloom',
            productImage: 'https://images.unsplash.com/photo-1615634260167-c8cdede054de?w=400',
            price: 135.00,
            quantity: 1,
            size: '50ml',
          ),
        ],
        timeline: [
          OrderTimeline(
            status: OrderStatus.delivered,
            timestamp: now.subtract(const Duration(days: 8)),
            note: 'Successfully delivered',
          ),
        ],
        subtotal: 135.00,
        discount: 0,
        shippingFee: 0,
        total: 135.00,
        shippingAddress: '321 Broadway, New York, NY 10007',
        trackingNumber: 'TRK444555666',
        shippingProvider: 'GHTK',
        paymentMethod: 'PayPal',
      ),
      
      // COMPLETED ORDER 3 - Cancelled
      Order(
        id: '5',
        orderNumber: 'ORDER #88092',
        createdAt: now.subtract(const Duration(days: 15)),
        status: OrderStatus.cancelled,
        items: [
          OrderItem(
            productId: 'prod_5',
            productName: 'Floral Musk',
            productImage: 'https://images.unsplash.com/photo-1587017539504-67cfbddac569?w=400',
            price: 155.00,
            quantity: 1,
            size: '30ml',
          ),
        ],
        timeline: [
          OrderTimeline(
            status: OrderStatus.cancelled,
            timestamp: now.subtract(const Duration(days: 14)),
            note: 'Order cancelled by customer',
          ),
        ],
        subtotal: 155.00,
        discount: 0,
        shippingFee: 0,
        total: 155.00,
        shippingAddress: '999 Sunset Blvd, Los Angeles, CA 90028',
        trackingNumber: null,
        shippingProvider: null,
        paymentMethod: 'Credit Card',
      ),
    ];
  }
  
  /// Simulate network delay for realistic UX
  static Future<List<Order>> getMockOrdersAsync() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return getMockOrders();
  }
  
  /// Get orders filtered by status
  static List<Order> getActiveOrders() {
    return getMockOrders().where((order) => 
      order.status == OrderStatus.shipped || 
      order.status == OrderStatus.outForDelivery
    ).toList();
  }
  
  static List<Order> getCompletedOrders() {
    return getMockOrders().where((order) => 
      order.status == OrderStatus.delivered || 
      order.status == OrderStatus.cancelled
    ).toList();
  }
}
