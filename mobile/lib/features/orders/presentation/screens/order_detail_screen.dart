import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final paymentAsync = ref.watch(orderPaymentProvider(orderId));

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        data: (order) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(orderDetailProvider(orderId));
            ref.invalidate(orderPaymentProvider(orderId));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              _OrderSummaryCard(order: order),
              const SizedBox(height: 12),
              _ProductList(order: order),
              const SizedBox(height: 12),
              _PriceBreakdown(order: order),
              const SizedBox(height: 12),
              _ShippingAddress(order: order),
              const SizedBox(height: 12),
              paymentAsync.when(
                data: (payment) => _PaymentInfo(paymentLabel: _paymentLabel(order, payment?.status.name.toUpperCase())),
                loading: () => const _PaymentInfo(paymentLabel: 'Checking payment...'),
                error: (_, __) => const _PaymentInfo(paymentLabel: 'Payment info unavailable'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (order.canTrack)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.trackOrderWithId(order.id)),
                        child: const Text('Track Order'),
                      ),
                    ),
                  if (order.canTrack) const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Support will contact you shortly.')),
                        );
                      },
                      child: const Text('Contact Support'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final Order order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softTaupe),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Placed on ${_formatDateTime(order.createdAt)}', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final Order order;

  const _ProductList({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softTaupe),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Products', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(
                            'x${item.quantity}${item.variantLabel.isEmpty ? '' : ' • ${item.variantLabel}'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Text(formatVND(item.totalPrice)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final Order order;

  const _PriceBreakdown({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softTaupe),
      ),
      child: Column(
        children: [
          _line('Subtotal', formatVND(order.totalAmount)),
          const SizedBox(height: 8),
          _line('Discount', '-${formatVND(order.discountAmount)}'),
          const SizedBox(height: 8),
          _line('Shipping', formatVND(order.shippingFee)),
          const Divider(height: 20),
          _line('Total', formatVND(order.finalAmount), emphasized: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool emphasized = false}) {
    return Builder(
      builder: (context) => Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingAddress extends StatelessWidget {
  final Order order;

  const _ShippingAddress({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softTaupe),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shipping address', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(order.recipientName),
          Text(order.phone, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(order.shippingAddress),
        ],
      ),
    );
  }
}

class _PaymentInfo extends StatelessWidget {
  final String paymentLabel;

  const _PaymentInfo({required this.paymentLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softTaupe),
      ),
      child: Row(
        children: [
          Text('Payment info', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(paymentLabel, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

String _paymentLabel(Order order, String? paymentStatus) {
  if (paymentStatus != null && paymentStatus.isNotEmpty) {
    return paymentStatus;
  }
  return order.paymentStatus.name.toUpperCase();
}

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} $hour:$minute';
}
