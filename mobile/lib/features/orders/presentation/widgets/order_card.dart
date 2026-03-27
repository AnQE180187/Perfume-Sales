import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../models/order.dart';
import 'order_status_badge.dart';

enum OrderCardVariant { active, completed }

class OrderCard extends StatelessWidget {
  final Order order;
  final OrderCardVariant variant;
  final VoidCallback onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onReview;
  final VoidCallback? onViewDetail;

  const OrderCard({
    super.key,
    required this.order,
    required this.variant,
    required this.onTap,
    this.onTrack,
    this.onReview,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final previewItem = order.previewItem;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: variant == OrderCardVariant.active
                    ? AppTheme.accentGold.withValues(alpha: 0.4)
                    : AppTheme.softTaupe,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      OrderStatusBadge(status: order.status),
                      const Spacer(),
                      Text(
                        _formatDate(order.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.code,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductImage(url: previewItem?.productImage ?? ''),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              previewItem?.productName ?? 'Perfume item',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (previewItem?.variantLabel.isNotEmpty ?? false)
                                  ? previewItem!.variantLabel
                                  : 'Luxury fragrance',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${order.itemCount} item${order.itemCount > 1 ? 's' : ''} • ${formatVND(order.finalAmount)}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.deepCharcoal,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildCtaRow(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaRow(BuildContext context) {
    final showTrack = variant == OrderCardVariant.active && onTrack != null;
    final isCancelled = order.status == OrderStatus.cancelled;
    final ctaLabel = showTrack
        ? 'Track Order'
        : isCancelled
        ? 'View Details'
        : 'Review';

    return Row(
      children: [
        TextButton(
          onPressed: onViewDetail ?? onTap,
          child: const Text('View Details'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed:
              showTrack ? onTrack : (isCancelled ? onViewDetail : onReview),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(ctaLabel),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;

  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softTaupe),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url.isEmpty
            ? const Icon(Icons.inventory_2_outlined)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.inventory_2_outlined),
              ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
