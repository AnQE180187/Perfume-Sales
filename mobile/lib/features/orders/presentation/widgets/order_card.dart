import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/order.dart';

/// Order Card - Reusable component with variants
///
/// Handles both Active and Completed order states with context-aware actions.
///
/// Why this exists:
/// - Single source of truth for order card UI
/// - Variant-based rendering (active vs completed)
/// - Context-aware CTAs (track, review, view receipt)
/// - Consistent luxury styling across all order states
enum OrderCardVariant {
  active, // For Active tab (shipped, out for delivery)
  completed, // For Completed tab (delivered, cancelled)
}

class OrderCard extends StatelessWidget {
  final Order order;
  final OrderCardVariant variant;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onWriteReview;
  final VoidCallback? onViewReview;
  final VoidCallback? onTap;
  final bool hasReviewed;

  const OrderCard({
    super.key,
    required this.order,
    required this.variant,
    this.onTrackOrder,
    this.onViewReceipt,
    this.onWriteReview,
    this.onViewReview,
    this.onTap,
    this.hasReviewed = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCancelled
              ? AppTheme.mutedSilver.withValues(alpha: 0.3)
              : AppTheme.accentGold.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isCancelled),
                const SizedBox(height: 14),
                _buildStatusRow(context, isCancelled),
                const SizedBox(height: 16),
                _buildProductInfo(context, isCancelled),
                const SizedBox(height: 16),
                _buildActions(context, isCancelled),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCancelled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          order.orderNumber,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isCancelled ? AppTheme.mutedSilver : AppTheme.deepCharcoal,
          ),
        ),
        Text(
          _formatDate(order.createdAt),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppTheme.mutedSilver,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, bool isCancelled) {
    IconData statusIcon;
    Color statusColor;

    switch (order.status) {
      case OrderStatus.outForDelivery:
        statusIcon = Icons.local_shipping_outlined;
        statusColor = AppTheme.accentGold;
        break;
      case OrderStatus.shipped:
        statusIcon = Icons.inventory_2_outlined;
        statusColor = AppTheme.accentGold;
        break;
      case OrderStatus.delivered:
        statusIcon = Icons.check_circle_outline;
        statusColor = AppTheme.accentGold;
        break;
      case OrderStatus.cancelled:
        statusIcon = Icons.cancel_outlined;
        statusColor = AppTheme.mutedSilver;
        break;
      default:
        statusIcon = Icons.access_time;
        statusColor = AppTheme.mutedSilver;
    }

    return Row(
      children: [
        Icon(statusIcon, size: 18, color: statusColor),
        const SizedBox(width: 7),
        Text(
          order.status.displayName,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context, bool isCancelled) {
    final firstItem = order.items.first;

    return Row(
      children: [
        // Product thumbnail
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.ivoryBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.softTaupe.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              firstItem.productImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.auto_awesome,
                color: AppTheme.mutedSilver,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstItem.productName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCancelled
                      ? AppTheme.mutedSilver
                      : AppTheme.deepCharcoal,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${firstItem.size ?? '50ml'} • Eau de Parfum',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mutedSilver,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isCancelled) {
    if (variant == OrderCardVariant.active) {
      return Row(
        children: [
          if (onViewReceipt != null)
            TextButton(
              onPressed: onViewReceipt,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View Receipt',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                ),
              ),
            ),
          const Spacer(),
          if (onTrackOrder != null)
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: onTrackOrder,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  side: BorderSide(color: AppTheme.accentGold, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Track Order',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppTheme.accentGold,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } else {
      // Completed variant
      if (isCancelled) {
        return Text(
          'This item is not eligible for review',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppTheme.mutedSilver,
            fontStyle: FontStyle.italic,
          ),
        );
      } else if (hasReviewed) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.ivoryBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 12, color: AppTheme.accentGold),
                  const SizedBox(width: 5),
                  Text(
                    'REVIEWED',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (onViewReview != null)
              TextButton(
                onPressed: onViewReview,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Your Review',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share your experience with this scent',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.mutedSilver,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: onWriteReview,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  side: BorderSide(color: AppTheme.accentGold, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Write Review',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cardDate = DateTime(date.year, date.month, date.day);

    if (cardDate == today) {
      return 'Today';
    } else if (cardDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
