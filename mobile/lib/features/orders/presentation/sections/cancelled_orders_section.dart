import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/order_card.dart';
import '../../../../l10n/app_localizations.dart';

class CancelledOrdersSection extends StatelessWidget {
  final List<Order> orders;
  final Future<void> Function() onRefresh;
  final void Function(Order order) onTapOrder;

  const CancelledOrdersSection({
    super.key,
    required this.orders,
    required this.onRefresh,
    required this.onTapOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyOrdersWidget(
        title: AppLocalizations.of(context)!.noOrdersYet,
        subtitle: AppLocalizations.of(context)!.orderHistoryAppear,
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
            variant: OrderCardVariant.completed, // Use completed or active? 
            onTap: () => onTapOrder(order),
            onViewDetail: () => onTapOrder(order),
          );
        },
      ),
    );
  }
}
