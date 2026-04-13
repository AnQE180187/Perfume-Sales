import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../models/order.dart';
import '../../../../l10n/app_localizations.dart';
import '../../services/payment_service.dart';
import '../../providers/order_provider.dart';
import '../../providers/order_realtime_provider.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OrderStatusEvent?>(orderRealtimeProvider, (prev, next) {
      if (next != null && next.orderId == orderId) {
        ref.invalidate(orderDetailProvider(orderId));
        ref.invalidate(orderPaymentProvider(orderId));
      }
    });

    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final paymentAsync = ref.watch(orderPaymentProvider(orderId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: orderAsync.when(
        data: (order) => RefreshIndicator(
          color: AppTheme.accentGold,
          onRefresh: () async {
            ref.invalidate(orderDetailProvider(orderId));
            ref.invalidate(orderPaymentProvider(orderId));
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: AppTheme.ivoryBackground,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF8F2EB), Color(0xFFEDE3D8)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(56, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.orderDetail,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 14,
                                  color: AppTheme.mutedSilver,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  order.code,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.mutedSilver,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OrderStatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.placedOn} ${_formatDateTime(order.createdAt)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                color: AppTheme.mutedSilver,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ProductList(order: order),
                    const SizedBox(height: 14),
                    _PriceBreakdown(order: order),
                    const SizedBox(height: 14),
                    _ShippingAddress(order: order),
                    const SizedBox(height: 14),
                    paymentAsync.when(
                      data: (payment) => _PaymentInfo(
                        paymentLabel: _paymentLabel(
                          order,
                          payment?.status.name.toUpperCase(),
                          l10n,
                        ),
                      ),
                      loading: () =>
                          _PaymentInfo(paymentLabel: l10n.checkingPayment),
                      error: (err, stack) {
                        return _PaymentInfo(
                          paymentLabel: _paymentLabel(
                            order,
                            order.paymentStatus.name.toUpperCase(),
                            l10n,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    if (order.canTrack) ...[
                      _GoldButton(
                        icon: Icons.location_on_outlined,
                        label: l10n.trackOrderUpper,
                        onPressed: () =>
                            context.push(AppRoutes.trackOrderWithId(order.id)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    _SupportButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.supportContactMessage,
                              style: GoogleFonts.montserrat(fontSize: 13),
                            ),
                            backgroundColor: AppTheme.deepCharcoal,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    if (order.status == OrderStatus.completed && !order.hasActiveReturn) ...[
                      _SubtleReturnButton(
                        onPressed: () => context.push(AppRoutes.returnOrderWithId(order.id)),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGold),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppTheme.mutedSilver,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dt);
  }

  String _paymentLabel(Order order, String? status, AppLocalizations l10n) {
    if (order.paymentMethod == 'COD') return l10n.cod;
    if (status == 'PAID' || status == 'COMPLETED') return l10n.paid;
    if (status == 'PENDING') return l10n.pending;
    if (status == 'CANCELLED' || status == 'EXPIRED') return l10n.cancelled;
    return l10n.pending;
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget _sectionHeader(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppTheme.accentGold),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.deepCharcoal,
          ),
        ),
      ],
    ),
  );
}

class _ProductList extends StatelessWidget {
  final Order order;
  const _ProductList({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(l10n.allProducts, Icons.shopping_bag_rounded),
          ...order.items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == order.items.length - 1;

            return Column(
              children: [
                GestureDetector(
                  onTap: item.productId.isNotEmpty
                      ? () => context.push(
                          AppRoutes.productDetailWithId(item.productId),
                        )
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFF8F5F0),
                          border: Border.all(
                            color: AppTheme.accentGold.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: item.productImage.isNotEmpty
                              ? Image.network(
                                  item.productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _productPlaceholder(),
                                )
                              : _productPlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.titleMd(
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'x${item.quantity}${item.variantLabel.isEmpty ? '' : '  •  ${item.variantLabel}'}',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AppTheme.mutedSilver,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatVND(item.totalPrice),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      color: AppTheme.softTaupe.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _productPlaceholder() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 24,
        color: AppTheme.softTaupe,
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final Order order;
  const _PriceBreakdown({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentSummary,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 16),
          _priceLine(l10n.subtotal, formatVND(order.totalAmount)),
          const SizedBox(height: 10),
          _priceLine(
            l10n.discount,
            '-${formatVND(order.discountAmount)}',
            valueColor: const Color(0xFFC19E3F),
          ),
          const SizedBox(height: 10),
          _priceLine(l10n.shippingFee, formatVND(order.shippingFee)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF0EAE2)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalAmount,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              Text(
                formatVND(order.finalAmount),
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceLine(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.deepCharcoal,
          ),
        ),
      ],
    );
  }
}

class _ShippingAddress extends StatelessWidget {
  final Order order;
  const _ShippingAddress({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shippingAddressUpper,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppTheme.accentGold,
              ),
              const SizedBox(width: 12),
              Text(
                order.recipientName,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppTheme.accentGold,
              ),
              const SizedBox(width: 12),
              Text(
                order.phone,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.shippingAddress,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    height: 1.6,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
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
    final l10n = AppLocalizations.of(context)!;
    final isPending = paymentLabel.toUpperCase().contains('PENDING') || paymentLabel.toUpperCase().contains('CHỜ');
    
    return _SectionCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              size: 16,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.payment.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPending 
                      ? const Color(0xFFFFF7E6) 
                      : const Color(0xFFF6FBF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPending 
                        ? const Color(0xFFFFD666).withValues(alpha: 0.5)
                        : const Color(0xFFB7EB8F).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  paymentLabel.toUpperCase(),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isPending ? const Color(0xFFD48806) : const Color(0xFF389E0D),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GoldButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFE2C563)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SupportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return LuxuryButton(
      text: AppLocalizations.of(context)!.contactSupport,
      onPressed: onPressed,
      height: 54,
    );
  }
}

class _SubtleReturnButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SubtleReturnButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        AppLocalizations.of(context)!.returnRequest,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.mutedSilver,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class LuxuryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;

  const LuxuryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.deepCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
