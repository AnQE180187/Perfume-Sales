import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ORDER HISTORY',
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
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ordersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: orders[index]);
              },
            ),
          );
        },
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
                'Failed to load orders',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'NO ORDERS YET',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Your order history will appear here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('START SHOPPING'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/orders/${order.id}'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(order.createdAt),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    _buildStatusBadge(context, order.status),
                  ],
                ),
                
                const SizedBox(height: 20),
                Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5),
                const SizedBox(height: 16),

                // Items Preview
                ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
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
                                size: 20,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Qty: ${item.quantity}${item.size != null ? ' • ${item.size}' : ''}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                )),

                if (order.items.length > 2) ...[
                  Text(
                    '+${order.items.length - 2} more items',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 8),
                Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5),
                const SizedBox(height: 16),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
