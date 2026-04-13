import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../address/providers/address_providers.dart';
import '../../orders/providers/order_provider.dart';
import '../providers/checkout_provider.dart';
import 'sections/checkout_address_section.dart';
import 'sections/checkout_items_section.dart';
import 'sections/checkout_payment_section.dart';
import 'sections/checkout_price_section.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(addressListProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final itemCount = checkoutState.orderItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.ivoryBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.payment.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
            color: AppTheme.deepCharcoal,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepCharcoal),
          onPressed: () => context.pop(),
        ),
      ),
      body: checkoutState.orderItems.isEmpty
          ? checkoutState.isCartLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentGold,
                    ),
                  )
                : _EmptyCheckoutState(
                    onReturnToCart: () => context.go(AppRoutes.cart),
                    message:
                        checkoutState.cartError ??
                        l10n.emptyCheckoutMessage,
                  )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
              children: [
                _CompactOrderHeader(
                  itemCount: itemCount,
                  totalAmount: checkoutState.totalAmount,
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: l10n.shippingAddressUpper),
                const SizedBox(height: 12),
                CheckoutAddressSection(
                  address: checkoutState.selectedAddress,
                  onTap: () => _showAddressSheet(context, ref),
                  highlight: checkoutState.selectedAddress == null,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFFE5D5C0), thickness: 0.5),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _SectionLabel(label: l10n.paymentMethodUpper),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.profilePaymentMethods),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.change,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckoutPaymentSection(
                  method: checkoutState.selectedPaymentMethod,
                  onEdit: () => context.push(AppRoutes.profilePaymentMethods),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFFE5D5C0), thickness: 0.5),
                ),
                _SectionLabel(label: l10n.itemsUpper),
                const SizedBox(height: 12),
                CheckoutItemsSection(items: checkoutState.orderItems),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFFE5D5C0), thickness: 0.5),
                ),
                _SectionLabel(label: l10n.payment),
                const SizedBox(height: 12),
                CheckoutPriceSection(
                  subtotal: checkoutState.subtotal,
                  shippingCost: checkoutState.shippingCost,
                  tax: checkoutState.tax,
                  discount: checkoutState.discountAmount,
                  totalAmount: checkoutState.totalAmount,
                ),
                const SizedBox(height: 40),
                const _TrustSignalsRow(),
              ],
            ),
      bottomNavigationBar: checkoutState.orderItems.isEmpty
          ? null
          : _CheckoutBottomBar(
              totalAmount: checkoutState.totalAmount,
              isSubmitting: checkoutState.isSubmitting,
              canConfirm: checkoutState.canConfirm,
              pendingPayment: checkoutState.pendingOnlinePayment,
              onConfirm: () => _handleConfirmOrder(context, ref),
            ),
    );
  }

  Future<void> _showAddressSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AddressPickerSheet(
          onSelected: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
  }

  Future<void> _handleConfirmOrder(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(checkoutProvider.notifier);
    final currentState = ref.read(checkoutProvider);
    final isOnlinePayment =
        currentState.selectedPaymentMethod?.type.requiresOnlinePayment ?? false;

    if (isOnlinePayment && currentState.createdOrderId != null) {
      final isPaid = await notifier.isOnlinePaymentPaid();
      if (!context.mounted) return;

      if (isPaid) {
        ref.invalidate(orderProvider);
        context.go(AppRoutes.orderSuccess);
        return;
      }
    }

    final success = await notifier.confirmOrder();
    if (!context.mounted) return;

    if (!success) {
      final errorMessage = ref.read(checkoutProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? l10n.orderConfirmError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final checkoutState = ref.read(checkoutProvider);
    final payosUrl = checkoutState.payosCheckoutUrl;
    final isOnlineAfterConfirm =
        checkoutState.selectedPaymentMethod?.type.requiresOnlinePayment ??
        false;

    if (isOnlineAfterConfirm) {
      if (payosUrl == null || payosUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.missingPaymentLink),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      try {
        final launched = await launchUrl(
          Uri.parse(payosUrl),
          mode: LaunchMode.externalApplication,
        );

        if (!context.mounted) return;

        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.unableOpenPayment,
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.paymentInstructions,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.unableOpenPayment,
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    ref.invalidate(orderProvider);
    context.go(AppRoutes.orderSuccess);
  }
}

class _CompactOrderHeader extends StatelessWidget {
  final int itemCount;
  final double totalAmount;

  const _CompactOrderHeader({
    required this.itemCount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5D5C0).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderSummary,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$itemCount ${l10n.products}',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 11,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${l10n.estDelivery}: 20 - 22 ${l10n.april}',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.mutedSilver,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.totalUpper,
                style: GoogleFonts.montserrat(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.mutedSilver,
                ),
              ),
              Text(
                formatVND(totalAmount),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
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
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: AppTheme.mutedSilver,
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final double totalAmount;
  final bool isSubmitting;
  final bool canConfirm;
  final bool pendingPayment;
  final VoidCallback onConfirm;

  const _CheckoutBottomBar({
    required this.totalAmount,
    required this.isSubmitting,
    required this.canConfirm,
    required this.pendingPayment,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonText = pendingPayment
        ? l10n.checkPaymentOpen
        : '${l10n.placeOrder}    ${formatVND(totalAmount)}';
    final buttonIcon = pendingPayment
        ? Icons.open_in_browser_rounded
        : Icons.arrow_forward_rounded;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppTheme.softTaupe.withValues(alpha: 0.6)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepCharcoal.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: LuxuryButton(
          text: buttonText,
          trailingIcon: buttonIcon,
          height: 56,
          isLoading: isSubmitting,
          onPressed: canConfirm && !isSubmitting ? onConfirm : null,
        ),
      ),
    );
  }
}

class _TrustSignalsRow extends StatelessWidget {
  const _TrustSignalsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TrustIconItem(
              icon: Icons.verified_user_outlined,
              label: l10n.securePayment,
            ),
            _TrustIconDivider(),
            _TrustIconItem(
              icon: Icons.local_shipping_outlined,
              label: l10n.expressShipping,
            ),
            _TrustIconDivider(),
            _TrustIconItem(
              icon: Icons.history_edu_outlined,
              label: l10n.dayReturn7,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'AURA LUXURY PERFUME SIGNATURE',
          style: GoogleFonts.montserrat(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: AppTheme.mutedSilver.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _TrustIconItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustIconItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.accentGold.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 7,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppTheme.mutedSilver,
          ),
        ),
      ],
    );
  }
}

class _TrustIconDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0xFFE5D5C0),
    );
  }
}

class _EmptyCheckoutState extends StatelessWidget {
  final VoidCallback onReturnToCart;
  final String message;

  const _EmptyCheckoutState({
    required this.onReturnToCart,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 34,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.checkoutEmptyTitle,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedSilver,
              ),
            ),
            const SizedBox(height: 24),
            LuxuryButton(text: l10n.returnToCart, onPressed: onReturnToCart),
          ],
        ),
      ),
    );
  }
}
