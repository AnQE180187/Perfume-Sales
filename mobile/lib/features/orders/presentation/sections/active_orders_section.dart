import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/order_card.dart';
import '../../../../l10n/app_localizations.dart';

class ActiveOrdersSection extends StatelessWidget {
  final List<Order> orders;
  final Future<void> Function() onRefresh;
  final void Function(Order order) onTapOrder;
  final void Function(Order order) onTrackOrder;

  const ActiveOrdersSection({
    super.key,
    required this.orders,
    required this.onRefresh,
    required this.onTapOrder,
    required this.onTrackOrder,
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
            variant: OrderCardVariant.active,
            onTap: () => onTapOrder(order),
            onViewDetail: () => onTapOrder(order),
            onTrack: () => onTrackOrder(order),
          );
        },
      ),
    );
  }
}
