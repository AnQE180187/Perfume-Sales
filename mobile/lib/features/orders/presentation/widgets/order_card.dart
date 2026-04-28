import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../models/order.dart';
import 'order_status_badge.dart';
import 'return_status_badge.dart';
import '../../../../l10n/app_localizations.dart';

enum OrderCardVariant { active, completed, returns }

class OrderCard extends StatelessWidget {
  final Order order;
  final OrderCardVariant variant;
  final VoidCallback onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onReview;
  final VoidCallback? onViewDetail;
  final bool isReviewed;

  const OrderCard({
    super.key,
    required this.order,
    required this.variant,
    required this.onTap,
    this.onTrack,
    this.onReview,
    this.onViewDetail,
    this.isReviewed = false,
  });

  @override
  Widget build(BuildContext context) {
    final previewItem = order.previewItem;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: variant == OrderCardVariant.active
                    ? AppTheme.accentGold.withValues(alpha: 0.25)
                    : AppTheme.softTaupe.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepCharcoal.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                children: [
                  if (variant == OrderCardVariant.returns && order.returnRequests.isNotEmpty)
                    ReturnStatusBadge(status: order.returnRequests.first.status)
                  else
                    OrderStatusBadge(status: order.status),
                  const Spacer(),
                  Text(
                    _formatDate(variant == OrderCardVariant.returns && order.returnRequests.isNotEmpty 
                        ? order.returnRequests.first.createdAt 
                        : order.createdAt),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppTheme.mutedSilver,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductImage(
                        url: previewItem?.productImage ?? '',
                        productId: previewItem?.productId ?? '',
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variant == OrderCardVariant.returns && order.returnRequests.isNotEmpty
                                  ? '${l10n.returnCode} #${order.returnRequests.first.id.substring(order.returnRequests.first.id.length - 8).toUpperCase()}'
                                  : order.code,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.mutedSilver,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              previewItem?.productName ?? 'Perfume item',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (variant == OrderCardVariant.returns && order.returnRequests.isNotEmpty) ...[
                              Text(
                                '${l10n.relatedOrder}: ${order.code}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.mutedSilver,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const SizedBox(height: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${order.itemCount} ${l10n.items.toLowerCase()}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  if (order.returnRequests.first.status == ReturnStatus.completed) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Hoàn tiền: ${formatVND(order.returnRequests.first.totalAmount)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ] else ...[
                              Text(
                                '${order.itemCount} ${l10n.items.toLowerCase()} • ${formatVND(order.finalAmount)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppTheme.softTaupe),
                  const SizedBox(height: 12),
                  _buildCtaRow(context, l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaRow(BuildContext context, AppLocalizations l10n) {
    final showTrack = variant == OrderCardVariant.active && onTrack != null;
    final isCancelled = order.status == OrderStatus.cancelled;
    final isReturn = variant == OrderCardVariant.returns;
    
    final ctaLabel = showTrack
        ? l10n.trackShipment
        : isReturn
            ? l10n.returnDetails
            : isCancelled
                ? l10n.viewDetails
                : isReviewed
                    ? l10n.reviewed
                    : l10n.review;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isCancelled && !isReturn) ...[
          TextButton(
            onPressed: onViewDetail ?? onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.viewDetails,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton(
          onPressed: isReviewed
              ? null
              : showTrack
                  ? onTrack
                  : (isCancelled || isReturn ? onViewDetail : onReview),
          style: ElevatedButton.styleFrom(
            backgroundColor: showTrack || isReturn ? AppTheme.accentGold : AppTheme.deepCharcoal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            minimumSize: const Size(100, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReviewed) ...[
                const Icon(Icons.check_circle, size: 14),
                const SizedBox(width: 4),
              ],
              Text(
                showTrack 
                    ? l10n.traceOrder 
                    : isReturn 
                        ? l10n.viewDetails 
                        : (isCancelled ? l10n.viewDetails : (isReviewed ? l10n.reviewed : l10n.review)),
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;
  final String productId;

  const _ProductImage({required this.url, required this.productId});

  @override
  Widget build(BuildContext context) {
    final image = Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: url.isEmpty
            ? const Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 32,
                  color: AppTheme.softTaupe,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: AppTheme.softTaupe,
                  ),
                ),
              ),
      ),
    );

    if (productId.isEmpty) return image;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.productDetailWithId(productId)),
      child: image,
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
