import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../cart/models/cart_item.dart';
import '../../payment/models/payment_method.dart';
import '../models/checkout_state.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'THANH TOÁN',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Kiểm tra lần cuối trước khi giao',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedSilver,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepCharcoal),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppTheme.softTaupe.withValues(alpha: 0.9),
                  ),
                ),
                child: Text(
                  '$itemCount sản phẩm',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: checkoutState.orderItems.isEmpty
          ? _EmptyCheckoutState(
              onReturnToCart: () => context.go(AppRoutes.cart),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _CheckoutHeroCard(
                  totalAmount: checkoutState.totalAmount,
                  itemCount: itemCount,
                ),
                const SizedBox(height: 20),
                _SectionHeader(
                  eyebrow: 'GIAO HÀNG',
                  title: 'Bạn muốn nhận hàng ở đâu?',
                  actionLabel: 'Thay đổi',
                  onAction: () =>
                      _showAddressSheet(context, ref, checkoutState),
                ),
                const SizedBox(height: 12),
                _AddressCard(
                  address: checkoutState.selectedAddress,
                  onTap: () => _showAddressSheet(context, ref, checkoutState),
                ),
                const SizedBox(height: 20),
                _SectionHeader(
                  eyebrow: 'THANH TOÁN',
                  title: 'Chọn phương thức thanh toán',
                  actionLabel: 'Chỉnh sửa',
                  onAction: () =>
                      _showPaymentSheet(context, ref, checkoutState),
                ),
                const SizedBox(height: 12),
                _PaymentCard(
                  paymentMethod: checkoutState.selectedPaymentMethod,
                  onTap: () => _showPaymentSheet(context, ref, checkoutState),
                ),
                const SizedBox(height: 20),
                const _DeliveryPromiseCard(),
                const SizedBox(height: 20),
                const _SectionHeader(
                  eyebrow: 'ĐƠN HÀNG',
                  title: 'Lựa chọn mùi hương của bạn',
                ),
                const SizedBox(height: 12),
                _OrderItemsCard(items: checkoutState.orderItems),
                const SizedBox(height: 20),
                const _SectionHeader(
                  eyebrow: 'TỔNG TIỀN',
                  title: 'Tóm tắt thanh toán',
                ),
                const SizedBox(height: 12),
                _PriceBreakdownCard(
                  subtotal: checkoutState.subtotal,
                  shippingCost: checkoutState.shippingCost,
                  tax: checkoutState.tax,
                  totalAmount: checkoutState.totalAmount,
                ),
                const SizedBox(height: 120),
              ],
            ),
      bottomNavigationBar: checkoutState.orderItems.isEmpty
          ? null
          : _CheckoutBottomBar(
              totalAmount: checkoutState.totalAmount,
              isSubmitting: checkoutState.isSubmitting,
              canConfirm: checkoutState.canConfirm,
              onConfirm: () => _handleConfirmOrder(context, ref),
            ),
    );
  }

  Future<void> _showAddressSheet(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
  ) async {
    final addresses = <CheckoutAddress>[
      const CheckoutAddress(
        name: 'EVELYN VANCE',
        address: '221B Baker Street, London',
        isDefault: true,
      ),
      const CheckoutAddress(
        name: 'MIA TRAN',
        address: '12 Nguyen Hue, District 1, Ho Chi Minh City',
      ),
      const CheckoutAddress(
        name: 'ALEXANDER LE',
        address: '8 Hang Gai, Hoan Kiem, Hanoi',
      ),
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CheckoutSheet(
          title: 'Chọn địa chỉ giao hàng',
          subtitle: 'Chọn nơi nhận cho đơn hàng này.',
          child: Column(
            children: addresses.map((address) {
              final isSelected =
                  checkoutState.selectedAddress?.name == address.name &&
                  checkoutState.selectedAddress?.address == address.address;
              return _SelectableTile(
                title: address.name,
                subtitle: address.address,
                badge: address.isDefault ? 'Mặc định' : null,
                icon: Icons.location_on_outlined,
                isSelected: isSelected,
                onTap: () {
                  ref.read(checkoutProvider.notifier).selectAddress(address);
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showPaymentSheet(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CheckoutSheet(
          title: 'Chọn phương thức thanh toán',
          subtitle: 'Hãy chọn cách thanh toán phù hợp nhất.',
          child: Column(
            children: PaymentMethodType.values.map((type) {
              final isSelected =
                  checkoutState.selectedPaymentMethod?.type == type;
              return _SelectableTile(
                title: type.displayName,
                subtitle: type.description,
                badge: type.requiresOnlinePayment
                    ? 'Ngay lập tức'
                    : 'Linh hoạt',
                icon: _paymentIcon(type),
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(checkoutProvider.notifier)
                      .selectPaymentMethod(
                        PaymentMethod(
                          type: type,
                          isDefault: type == PaymentMethodType.cod,
                        ),
                      );
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _handleConfirmOrder(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(checkoutProvider.notifier);
    final success = await notifier.confirmOrder();

    if (success && context.mounted) {
      context.go(AppRoutes.orderSuccess);
    } else if (context.mounted) {
      final errorMessage = ref.read(checkoutProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Không thể xác nhận đơn hàng'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _CheckoutHeroCard extends StatelessWidget {
  final double totalAmount;
  final int itemCount;

  const _CheckoutHeroCard({required this.totalAmount, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F1E6), Color(0xFFE6D5B8)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            right: -18,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -10,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Thanh toán nhanh',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ),
                  const Spacer(),
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
              const SizedBox(height: 18),
              Text(
                'Kiểm tra đơn hàng trước khi rời xưởng.',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Mọi thứ đã sẵn sàng cho quá trình giao hàng suôn sẻ, từ xác nhận địa chỉ đến thanh toán an toàn.',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.deepCharcoal.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: '$itemCount sản phẩm đã chọn'),
                  const _InfoChip(label: 'Miễn phí vận chuyển'),
                  const _InfoChip(label: 'Dự kiến 2-4 ngày làm việc'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: AppTheme.mutedSilver,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGold,
              ),
            ),
          ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final CheckoutAddress? address;
  final VoidCallback onTap;

  const _AddressCard({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selectedAddress = address;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.softTaupe),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.ivoryBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            selectedAddress?.name ?? 'Chọn địa chỉ nhận hàng',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepCharcoal,
                            ),
                          ),
                        ),
                        if (selectedAddress?.isDefault ?? false) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.ivoryBackground,
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
                    const SizedBox(height: 6),
                    Text(
                      selectedAddress?.address ??
                          'Nhấn để chọn địa chỉ giao hàng.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.mutedSilver,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentMethod? paymentMethod;
  final VoidCallback onTap;

  const _PaymentCard({required this.paymentMethod, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selectedMethod = paymentMethod;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.softTaupe),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.ivoryBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _paymentIcon(selectedMethod?.type ?? PaymentMethodType.cod),
                  color: AppTheme.deepCharcoal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMethod?.type.displayName ??
                          'Chọn phương thức thanh toán',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedMethod?.type.description ??
                          'Nhấn để chọn phương thức thanh toán.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.ivoryBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  selectedMethod?.type.requiresOnlinePayment ?? false
                      ? 'Trực tuyến'
                      : 'An toàn',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryPromiseCard extends StatelessWidget {
  const _DeliveryPromiseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E7DA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cam kết giao hàng',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đơn đặt trước 6 giờ tối hôm nay sẽ được chuẩn bị ngay trong tối với gói quà miễn phí.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
          width: 72,
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.ivoryBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
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
        borderRadius: BorderRadius.circular(28),
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng cần thanh toán',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatCurrency(totalAmount),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.ivoryBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bảo mật',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ],
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
  final VoidCallback onConfirm;

  const _CheckoutBottomBar({
    required this.totalAmount,
    required this.isSubmitting,
    required this.canConfirm,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(color: AppTheme.softTaupe.withValues(alpha: 0.8)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepCharcoal.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số tiền thanh toán',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedSilver,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(totalAmount),
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LuxuryButton(
                    text: 'Đặt hàng',
                    trailingIcon: Icons.arrow_forward_rounded,
                    height: 54,
                    isLoading: isSubmitting,
                    onPressed: canConfirm ? onConfirm : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppTheme.mutedSilver.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  'Thanh toán an toàn với xác nhận đơn hàng được mã hóa',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedSilver.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  const _EmptyCheckoutState({required this.onReturnToCart});

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
              'Hãy thêm sản phẩm vào giỏ hàng trước khi tiến hành thanh toán.',
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

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
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

String _formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

IconData _paymentIcon(PaymentMethodType type) {
  switch (type) {
    case PaymentMethodType.vnpay:
      return Icons.account_balance_wallet_outlined;
    case PaymentMethodType.momo:
      return Icons.phone_iphone_outlined;
    case PaymentMethodType.cod:
      return Icons.local_shipping_outlined;
  }
}
