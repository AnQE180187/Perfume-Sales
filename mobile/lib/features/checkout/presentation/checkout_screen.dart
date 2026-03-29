import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../address/models/address.dart';
import '../../address/providers/address_providers.dart';
import '../../cart/models/cart_item.dart';
import '../../orders/providers/order_provider.dart';
import '../../payment/models/payment_method.dart';
import '../../payment/providers/payment_method_provider.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'THANH TOÁN',
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
                        'Hãy thêm sản phẩm vào giỏ hàng trước khi tiến hành thanh toán.',
                  )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
              children: [
                _CompactOrderHeader(
                  itemCount: itemCount,
                  totalAmount: checkoutState.totalAmount,
                ),
                const SizedBox(height: 20),
                const _SectionLabel(label: 'ĐỊA CHỈ GIAO HÀNG'),
                const SizedBox(height: 8),
                _AddressCard(
                  address: checkoutState.selectedAddress,
                  onTap: () => _showAddressSheet(context, ref),
                  highlight: checkoutState.selectedAddress == null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: _SectionLabel(label: 'PHƯƠNG THỨC THANH TOÁN'),
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
                        'Đổi',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _SelectedPaymentCard(
                  method: checkoutState.selectedPaymentMethod,
                  onEdit: () => context.push(AppRoutes.profilePaymentMethods),
                ),
                const SizedBox(height: 16),
                const _SectionLabel(label: 'SẢN PHẨM'),
                const SizedBox(height: 8),
                _OrderItemsCard(items: checkoutState.orderItems),
                const SizedBox(height: 16),
                const _SectionLabel(label: 'TỔNG CỘNG'),
                const SizedBox(height: 8),
                _PriceBreakdownCard(
                  subtotal: checkoutState.subtotal,
                  shippingCost: checkoutState.shippingCost,
                  tax: checkoutState.tax,
                  totalAmount: checkoutState.totalAmount,
                ),
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
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddressPickerSheet(
          onSelected: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
  }

  Future<void> _handleConfirmOrder(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(checkoutProvider.notifier);
    final currentState = ref.read(checkoutProvider);
    final isOnlinePayment =
        currentState.selectedPaymentMethod?.type.requiresOnlinePayment ?? false;

    // For existing online orders, verify backend status before any success navigation.
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
          content: Text(errorMessage ?? 'Không thể xác nhận đơn hàng'),
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
          const SnackBar(
            content: Text('Đơn đã tạo nhưng chưa có link thanh toán. Thử lại.'),
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
            const SnackBar(
              content: Text(
                'Không thể mở trang thanh toán. Nhấn nút để thử lại.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Hoàn tất thanh toán trên browser, sau đó quay lại và nhấn kiểm tra.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể mở trang thanh toán. Nhấn nút để thử lại.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // COD — navigate directly to success
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.champagneGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppTheme.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$itemCount sản phẩm',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Dự kiến nhận hàng trong 2–4 ngày',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(totalAmount),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
            ),
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

class _AddressCard extends StatelessWidget {
  final Address? address;
  final VoidCallback onTap;
  final bool highlight;

  const _AddressCard({
    required this.address,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedAddress = address;
    final isEmpty = selectedAddress == null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlight && isEmpty
                  ? Colors.orange.withValues(alpha: 0.6)
                  : AppTheme.softTaupe,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.ivoryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: isEmpty ? AppTheme.mutedSilver : AppTheme.deepCharcoal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            selectedAddress?.recipientName ??
                                'Thêm địa chỉ giao hàng',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isEmpty
                                  ? (highlight
                                        ? Colors.orange.shade700
                                        : AppTheme.mutedSilver)
                                  : AppTheme.deepCharcoal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedAddress?.isDefault ?? false) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Mặc định',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!isEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        selectedAddress.fullAddress,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.mutedSilver,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isEmpty ? AppTheme.accentGold : AppTheme.mutedSilver,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows only the currently-selected payment method as a single tappable card.
class _SelectedPaymentCard extends StatelessWidget {
  final PaymentMethod? method;
  final VoidCallback onEdit;

  const _SelectedPaymentCard({required this.method, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final m = method;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentGold, width: 1.4),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  m != null ? _paymentIcon(m.type) : Icons.payment_outlined,
                  color: AppTheme.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  m?.label ?? 'Chưa chọn',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ),
              Icon(
                Icons.radio_button_checked,
                color: AppTheme.accentGold,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  final List<CartItem> items;

  const _OrderItemsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _OrderItemRow(item: items[index]),
            if (index != items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  color: AppTheme.softTaupe.withValues(alpha: 0.8),
                  height: 1,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final CartItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.ivoryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.productImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_outlined,
                size: 28,
                color: AppTheme.mutedSilver,
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
                item.productName,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if ((item.variant ?? '').isNotEmpty)
                    _TagChip(label: item.variant!),
                  if ((item.size ?? '').isNotEmpty) _TagChip(label: item.size!),
                  _TagChip(label: 'SL ${item.quantity}'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _formatCurrency(item.subtotal),
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceBreakdownCard extends StatelessWidget {
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double totalAmount;

  const _PriceBreakdownCard({
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Tiền hàng', value: _formatCurrency(subtotal)),
          const SizedBox(height: 12),
          _PriceRow(
            label: 'Vận chuyển',
            value: shippingCost == 0
                ? 'Miễn phí'
                : _formatCurrency(shippingCost),
            highlight: shippingCost == 0,
          ),
          const SizedBox(height: 12),
          _PriceRow(label: 'Thuế', value: _formatCurrency(tax)),
          const SizedBox(height: 16),
          Divider(color: AppTheme.softTaupe.withValues(alpha: 0.8), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TỔNG CỘNG',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              Text(
                _formatCurrency(totalAmount),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
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
    final buttonText = pendingPayment
        ? 'Kiểm tra / mở lại thanh toán  →'
        : 'Đặt hàng  •  ${_formatCurrency(totalAmount)}';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LuxuryButton(
              text: buttonText,
              trailingIcon: buttonIcon,
              height: 56,
              isLoading: isSubmitting,
              onPressed: canConfirm && !isSubmitting ? onConfirm : null,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _TrustItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Bảo mật',
                ),
                const _TrustDivider(),
                const _TrustItem(
                  icon: Icons.local_shipping_outlined,
                  label: '2–4 ngày',
                ),
                const _TrustDivider(),
                const _TrustItem(
                  icon: Icons.replay_rounded,
                  label: 'Đổi trả 14 ngày',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppTheme.mutedSilver.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.mutedSilver.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _TrustDivider extends StatelessWidget {
  const _TrustDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '·',
        style: TextStyle(fontSize: 12, color: AppTheme.softTaupe),
      ),
    );
  }
}

class _AddressPickerSheet extends ConsumerWidget {
  final VoidCallback onSelected;

  const _AddressPickerSheet({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressListProvider);
    final selected = ref.watch(selectedAddressProvider);

    return _CheckoutSheet(
      title: 'Chọn địa chỉ giao hàng',
      subtitle: 'Danh sách này được đồng bộ trực tiếp từ tài khoản của bạn.',
      child: addressesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.accentGold),
          ),
        ),
        error: (error, _) => Column(
          children: [
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => ref.read(addressListProvider.notifier).reload(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Column(
              children: [
                Text(
                  'Bạn chưa có địa chỉ. Hãy thêm địa chỉ trước khi đặt hàng.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedSilver,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.shippingAddresses),
                  child: const Text('Mở màn quản lý địa chỉ'),
                ),
              ],
            );
          }

          return Column(
            children: [
              ...addresses.map((address) {
                return _SelectableTile(
                  title: address.recipientName,
                  subtitle: address.fullAddress,
                  badge: address.isDefault ? 'Mặc định' : null,
                  icon: Icons.location_on_outlined,
                  isSelected: selected?.id == address.id,
                  onTap: () async {
                    await ref
                        .read(checkoutProvider.notifier)
                        .selectAddress(address);
                    onSelected();
                  },
                );
              }),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.push(AppRoutes.shippingAddresses),
                  icon: const Icon(Icons.add),
                  label: const Text('Quản lý địa chỉ'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckoutSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CheckoutSheet({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.softTaupe,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedSilver,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? const Color(0xFFF3ECE1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.accentGold : AppTheme.softTaupe,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.ivoryBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppTheme.deepCharcoal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badge!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.mutedSilver,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? AppTheme.accentGold
                      : AppTheme.mutedSilver,
                ),
              ],
            ),
          ),
        ),
      ),
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
              'Trang thanh toán của bạn đang trống.',
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
            LuxuryButton(text: 'Quay lại giỏ hàng', onPressed: onReturnToCart),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.ivoryBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.deepCharcoal,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedSilver,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: highlight ? AppTheme.accentGold : AppTheme.deepCharcoal,
          ),
        ),
      ],
    );
  }
}

String _formatCurrency(double amount) => formatVND(amount);

IconData _paymentIcon(PaymentMethodType type) {
  switch (type) {
    case PaymentMethodType.cod:
      return Icons.local_shipping_outlined;
    case PaymentMethodType.payos:
      return Icons.qr_code_2_rounded;
    case PaymentMethodType.vnpay:
      return Icons.account_balance_wallet_outlined;
    case PaymentMethodType.momo:
      return Icons.phone_iphone_outlined;
  }
}
