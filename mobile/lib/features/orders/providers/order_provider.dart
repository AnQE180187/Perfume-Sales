import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../models/order.dart';
import '../models/payment.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';

class OrderListState {
  final List<Order> all;
  final List<Order> active;
  final List<Order> completed;

  const OrderListState({
    required this.all,
    required this.active,
    required this.completed,
  });

  factory OrderListState.fromOrders(List<Order> orders) {
    final active = orders.where((order) => order.status.isActive).toList();
    final completed =
        orders.where((order) => order.isCompletedBucket).toList();
    return OrderListState(all: orders, active: active, completed: completed);
  }
}

class TrackingTimelineStep {
  final String title;
  final String description;
  final DateTime? timestamp;
  final bool reached;
  final bool current;

  const TrackingTimelineStep({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.reached,
    required this.current,
  });
}

class TrackingViewData {
  final String header;
  final String etaText;
  final String mapLabel;
  final List<TrackingTimelineStep> steps;

  const TrackingViewData({
    required this.header,
    required this.etaText,
    required this.mapLabel,
    required this.steps,
  });
}

final orderServiceProvider = Provider<OrderService>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrderService(client: client);
});

final orderPaymentServiceProvider = Provider<OrderPaymentService>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrderPaymentService(client: client);
});

class OrderNotifier extends AsyncNotifier<OrderListState> {
  @override
  Future<OrderListState> build() async {
    final service = ref.read(orderServiceProvider);
    final orders = await service.getOrders();
    return OrderListState.fromOrders(orders);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(orderServiceProvider);
      final orders = await service.getOrders();
      return OrderListState.fromOrders(orders);
    });
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, OrderListState>(
  OrderNotifier.new,
);

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final listState = await ref.watch(orderProvider.future);
  return listState.all;
});

final orderDetailProvider = FutureProvider.family<Order, String>((
  ref,
  orderId,
) async {
  final service = ref.read(orderServiceProvider);
  return service.getOrderById(orderId);
});

final orderPaymentProvider = FutureProvider.family<OrderPayment?, String>((
  ref,
  orderId,
) async {
  final service = ref.read(orderPaymentServiceProvider);
  return service.getPaymentByOrderId(orderId);
});

final trackingProvider = FutureProvider.family<TrackingViewData, String>((
  ref,
  orderId,
) async {
  final order = await ref.watch(orderDetailProvider(orderId).future);
  final latestShipment = order.latestShipment;

  final mapLabel = latestShipment?.trackingCode == null
      ? 'Dang cho tao van don GHN'
      : 'Ma van don: ${latestShipment!.trackingCode}';

  final etaText = switch (order.status) {
    OrderStatus.completed => 'Da giao thanh cong',
    OrderStatus.cancelled => 'Don da huy',
    OrderStatus.shipped => 'Du kien giao trong 1-2 ngay',
    _ => 'Dang cap nhat lo trinh',
  };

  final statusOrder = <OrderStatus>[
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.completed,
  ];

  final currentIndex = statusOrder.indexOf(order.status);
  final currentSafeIndex = currentIndex < 0 ? 0 : currentIndex;

  final stepTitles = <String>[
    'Confirmed',
    'Shipped',
    'Out for delivery',
    'Delivered',
  ];

  final descriptions = <String>[
    'Don hang da duoc xac nhan thanh toan.',
    'Kho da ban giao don vi van chuyen.',
    'Shipper dang giao hang den dia chi cua ban.',
    'Don hang da den tay ban.',
  ];

  final steps = List<TrackingTimelineStep>.generate(stepTitles.length, (index) {
    final reached = order.status == OrderStatus.completed
        ? true
        : index <= currentSafeIndex;
    final current = order.status == OrderStatus.completed
        ? index == stepTitles.length - 1
        : index == currentSafeIndex;
    return TrackingTimelineStep(
      title: stepTitles[index],
      description: descriptions[index],
      timestamp: reached ? order.updatedAt.subtract(Duration(hours: (stepTitles.length - index) * 5)) : null,
      reached: reached,
      current: current,
    );
  });

  return TrackingViewData(
    header: 'Your order is on the way',
    etaText: etaText,
    mapLabel: mapLabel,
    steps: order.status == OrderStatus.cancelled
        ? const [
            TrackingTimelineStep(
              title: 'Cancelled',
              description: 'Don hang da duoc huy do thanh toan that bai hoac theo yeu cau.',
              timestamp: null,
              reached: true,
              current: true,
            ),
          ]
        : steps,
  );
});
