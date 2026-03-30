import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/order_card.dart';

class CompletedOrdersSection extends StatelessWidget {
  final List<Order> orders;
  final Future<void> Function() onRefresh;
  final void Function(Order order) onTapOrder;

  const CompletedOrdersSection({
    super.key,
    required this.orders,
    required this.onRefresh,
    required this.onTapOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyOrdersWidget(
        title: 'No completed orders',
        subtitle: 'Completed and cancelled orders will be listed here.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            variant: OrderCardVariant.completed,
            onTap: () => onTapOrder(order),
            onViewDetail: () => onTapOrder(order),
            onReview: () => onTapOrder(order),
          );
        },
      ),
    );
  }
}
