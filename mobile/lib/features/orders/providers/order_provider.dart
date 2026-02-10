import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'mock_orders_provider.dart';

// Order Service Provider
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Orders List Provider
// 
// Returns mock data when AppConfig.useMockOrders == true
// Returns real Supabase data when AppConfig.useMockOrders == false
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  if (AppConfig.useMockOrders) {
    // Mock mode: return fake orders with simulated network delay
    return MockOrdersProvider.getMockOrdersAsync();
  } else {
    // Production mode: fetch from Supabase
    final service = ref.read(orderServiceProvider);
    return service.getUserOrders();
  }
});

// Single Order Provider
final orderDetailProvider = FutureProvider.family<Order, String>((ref, orderId) async {
  if (AppConfig.useMockOrders) {
    // Mock mode: find order from mock data
    await Future.delayed(const Duration(milliseconds: 300));
    final orders = MockOrdersProvider.getMockOrders();
    return orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
  } else {
    // Production mode: fetch from Supabase
    final service = ref.read(orderServiceProvider);
    return service.getOrderById(orderId);
  }
});

// Order Actions Provider
final orderActionsProvider = Provider<OrderActions>((ref) {
  return OrderActions(ref);
});

class OrderActions {
  final Ref ref;

  OrderActions(this.ref);

  Future<void> cancelOrder(String orderId) async {
    if (AppConfig.useMockOrders) {
      // Mock mode: simulate cancel action
      await Future.delayed(const Duration(milliseconds: 500));
      // In mock mode, just refresh the provider
      ref.invalidate(ordersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      return;
    }
    
    // Production mode: call real service
    final service = ref.read(orderServiceProvider);
    await service.cancelOrder(orderId);
    ref.invalidate(ordersProvider);
    ref.invalidate(orderDetailProvider(orderId));
  }

  Future<String> reorder(String orderId) async {
    if (AppConfig.useMockOrders) {
      // Mock mode: simulate reorder
      await Future.delayed(const Duration(milliseconds: 500));
      return 'ORDER #${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Production mode: call real service
    final service = ref.read(orderServiceProvider);
    final newOrderId = await service.reorder(orderId);
    ref.invalidate(ordersProvider);
    return newOrderId;
  }

  Future<Map<String, dynamic>> trackShipment(String trackingNumber, String provider) async {
    if (AppConfig.useMockOrders) {
      // Mock mode: return fake tracking info
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'status': 'in_transit',
        'location': 'Distribution Center',
        'estimated_delivery': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      };
    }
    
    // Production mode: call real service
    final service = ref.read(orderServiceProvider);
    return service.trackShipment(trackingNumber, provider);
  }
}
