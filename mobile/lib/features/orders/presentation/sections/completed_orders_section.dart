import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../services/review_status_store.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/order_card.dart';
import '../widgets/write_review_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';

class CompletedOrdersSection extends StatefulWidget {
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
  State<CompletedOrdersSection> createState() => _CompletedOrdersSectionState();
}

class _CompletedOrdersSectionState extends State<CompletedOrdersSection> {
  final Set<String> _reviewedOrderIds = {};
  final _store = ReviewStatusStore();

  @override
  void initState() {
    super.initState();
    _loadReviewedState();
  }

  Future<void> _loadReviewedState() async {
    final ids = await _store.getReviewedOrderIds();
    if (!mounted) return;
    setState(() {
      _reviewedOrderIds
        ..clear()
        ..addAll(ids);
    });
  }

  Future<void> _openReview(Order order) async {
    final result = await WriteReviewBottomSheet.show(context, order);
    if (result == true && mounted) {
      setState(() => _reviewedOrderIds.add(order.id));
      await _store.markReviewed(order.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return EmptyOrdersWidget(
        title: AppLocalizations.of(context)!.noOrdersYet,
        subtitle: AppLocalizations.of(context)!.orderHistoryAppear,
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        itemCount: widget.orders.length,
        itemBuilder: (context, index) {
          final order = widget.orders[index];
          final reviewed = _reviewedOrderIds.contains(order.id);
          return OrderCard(
            order: order,
            variant: OrderCardVariant.completed,
            onTap: () => widget.onTapOrder(order),
            onViewDetail: () => widget.onTapOrder(order),
            onReview: () => _openReview(order),
            isReviewed: reviewed,
          );
        },
      ),
    );
  }
}
