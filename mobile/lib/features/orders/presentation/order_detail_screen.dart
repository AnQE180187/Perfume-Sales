import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ORDER DETAILS',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: 6,
            fontSize: 12,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        data: (order) => _buildOrderDetail(context, ref, order),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.champagneGold,
            strokeWidth: 2,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load order',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetail(BuildContext context, WidgetRef ref, Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(context, order),
          const SizedBox(height: 32),

          // Timeline
          _buildTimeline(context, order),
          const SizedBox(height: 32),

          // Tracking Info
          if (order.canTrack) ...[
            _buildTrackingInfo(context, ref, order),
            const SizedBox(height: 32),
          ],

          // Items
          _buildItemsSection(context, order),
          const SizedBox(height: 32),

          // Shipping Address
          _buildShippingAddress(context, order),
          const SizedBox(height: 32),

          // Price Summary
          _buildPriceSummary(context, order),
          const SizedBox(height: 32),

          // Actions
          _buildActions(context, ref, order),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER NUMBER',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: order.orderNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order number copied')),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      order.orderNumber,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.copy, size: 14, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER DATE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(order.createdAt),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
                  ),
                ],
              ),
              _buildStatusBadge(context, order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER TIMELINE',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 20),
        ...order.timeline.asMap().entries.map((entry) {
          final index = entry.key;
          final timeline = entry.value;
          final isLast = index == order.timeline.length - 1;
          final isActive = timeline.status == order.status;

          return _TimelineItem(
            timeline: timeline,
            isLast: isLast,
            isActive: isActive,
          );
        }),
      ],
    );
  }

  Widget _buildTrackingInfo(BuildContext context, WidgetRef ref, Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.champagneGold.withValues(alpha: 0.05),
        border: Border.all(
          color: AppTheme.champagneGold.withValues(alpha: 0.2),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: AppTheme.accentGold, size: 20),
              const SizedBox(width: 12),
              Text(
                'TRACKING INFORMATION',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking Number',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.trackingNumber ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
                  ),
                ],
              ),
              if (order.shippingProvider != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.shippingProvider!.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                // TODO: Show tracking details
                if (order.trackingNumber != null && order.shippingProvider != null) {
                  await ref.read(orderActionsProvider).trackShipment(
                    order.trackingNumber!,
                    order.shippingProvider!,
                  );
                  // Show tracking modal
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.accentGold, width: 0.5),
              ),
              child: Text(
                'TRACK SHIPMENT',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ITEMS (${order.itemCount})',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 16),
        ...order.items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item.productImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.outline,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}${item.size != null ? ' • ${item.size}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildShippingAddress(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'SHIPPING ADDRESS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.shippingAddress,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildPriceRow(context, 'Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
          if (order.discount > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(context, 'Discount', '-\$${order.discount.toStringAsFixed(2)}', isDiscount: true),
          ],
          const SizedBox(height: 12),
          _buildPriceRow(context, 'Shipping Fee', order.shippingFee > 0 ? '\$${order.shippingFee.toStringAsFixed(2)}' : 'FREE'),
          const SizedBox(height: 16),
          Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
              Text(
                order.paymentMethod.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 13,
            color: isDiscount ? AppTheme.accentGold : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Order order) {
    return Column(
      children: [
        if (order.canReorder)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final newOrderId = await ref.read(orderActionsProvider).reorder(order.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order placed successfully')),
                    );
                    context.push('/orders/$newOrderId');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to reorder: $e')),
                    );
                  }
                }
              },
              child: const Text('REORDER'),
            ),
          ),
        if (order.canCancel) ...[
          if (order.canReorder) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Order'),
                    content: const Text('Are you sure you want to cancel this order?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('NO'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('YES, CANCEL'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await ref.read(orderActionsProvider).cancelOrder(order.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order cancelled')),
                      );
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to cancel: $e')),
                      );
                    }
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 0.5),
              ),
              child: Text(
                'CANCEL ORDER',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.delivered:
        backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        textColor = const Color(0xFF10B981);
        break;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
        textColor = const Color(0xFFEF4444);
        break;
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        backgroundColor = AppTheme.accentGold.withValues(alpha: 0.1);
        textColor = AppTheme.accentGold;
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.1);
        textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 9,
          color: textColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final OrderTimeline timeline;
  final bool isLast;
  final bool isActive;

  const _TimelineItem({
    required this.timeline,
    required this.isLast,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.accentGold : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accentGold : Colors.transparent,
                border: Border.all(color: color!, width: 2),
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: AppTheme.primaryDb)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeline.status.displayName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 11,
                    color: isActive ? AppTheme.accentGold : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeline.status.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(timeline.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
                if (timeline.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timeline.note!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
