import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/order_card.dart';
import '../../../../l10n/app_localizations.dart';

class ReturnsSection extends StatelessWidget {
  final List<Order> orders;
  final Future<void> Function() onRefresh;
  final void Function(String returnId) onTapReturn;

  const ReturnsSection({
    super.key,
    required this.orders,
    required this.onRefresh,
    required this.onTapReturn,
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
            variant: OrderCardVariant.returns,
            onTap: () => onTapReturn(order.returnRequests.first.id),
            onViewDetail: () => onTapReturn(order.returnRequests.first.id),
          );
        },
      ),
    );
  }
}
