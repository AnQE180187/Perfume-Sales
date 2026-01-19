import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/order_service.dart';

// Order Service Provider
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Orders List Provider
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final service = ref.read(orderServiceProvider);
  return service.getUserOrders();
});

// Single Order Provider
final orderDetailProvider = FutureProvider.family<Order, String>((ref, orderId) async {
  final service = ref.read(orderServiceProvider);
  return service.getOrderById(orderId);
});

// Order Actions Provider
final orderActionsProvider = Provider<OrderActions>((ref) {
  return OrderActions(ref);
});

class OrderActions {
  final Ref ref;

  OrderActions(this.ref);

  Future<void> cancelOrder(String orderId) async {
    final service = ref.read(orderServiceProvider);
    await service.cancelOrder(orderId);
    // Refresh orders list
    ref.invalidate(ordersProvider);
    ref.invalidate(orderDetailProvider(orderId));
  }

  Future<String> reorder(String orderId) async {
    final service = ref.read(orderServiceProvider);
    final newOrderId = await service.reorder(orderId);
    // Refresh orders list
    ref.invalidate(ordersProvider);
    return newOrderId;
  }

  Future<Map<String, dynamic>> trackShipment(String trackingNumber, String provider) async {
    final service = ref.read(orderServiceProvider);
    return service.trackShipment(trackingNumber, provider);
  }
}
