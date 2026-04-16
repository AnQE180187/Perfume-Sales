import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../models/orders_models.dart';
import '../providers/orders_provider.dart';
import '../../pos/models/pos_models.dart';
import '../../pos/providers/pos_provider.dart';
import '../../staff_shell.dart';
import '../../../../core/widgets/app_error_widget.dart';

class StaffOrdersScreen extends ConsumerStatefulWidget {
  const StaffOrdersScreen({super.key});

  @override
  ConsumerState<StaffOrdersScreen> createState() => _StaffOrdersScreenState();
}

class _StaffOrdersScreenState extends ConsumerState<StaffOrdersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _currencyFmt = NumberFormat('#,###', 'vi');
  final _dateFmt = DateFormat('dd/MM HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(ordersProvider.notifier).loadOrders();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      final query = ref.read(ordersSearchQueryProvider);
      ref
          .read(ordersProvider.notifier)
          .loadMore(search: query.isEmpty ? null : query);
    }
  }

  void _onSearch(String value) {
    ref.read(ordersSearchQueryProvider.notifier).state = value;
    ref
        .read(ordersProvider.notifier)
        .loadOrders(search: value.isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final state = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: SafeArea(
        top: false, // Custom header handles top padding partly
        child: RefreshIndicator(
          color: AppTheme.accentGold,
          onRefresh: () async {
            final q = ref.read(ordersSearchQueryProvider);
            await ref.read(ordersProvider.notifier).loadOrders(search: q.isEmpty ? null : q);
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Fixed Header Area
              SliverToBoxAdapter(child: _buildGradientHeader(context, l10n)),
              
              // 2. Search Bar Area
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  color: const Color(0xFF030303),
                  child: _buildSearchBar(l10n),
                ),
              ),
              
              // 3. Body Content
              _buildSliverBody(state, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverBody(OrdersState state, AppLocalizations l10n) {
    if (state.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(AppSpacing.md),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ShimmerCard(height: 88, baseColor: const Color(0xFF121212), highlightColor: const Color(0xFF1A1A1A)),
            ),
            childCount: 5,
          ),
        ),
      );
    }

    if (state.error != null && state.orders.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorWidget(
          message: l10n.unableLoadData,
          onRetry: () => ref.read(ordersProvider.notifier).loadOrders(),
        ),
      );
    }

    if (state.orders.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_outlined, size: 56, color: AppTheme.mutedSilver.withOpacity(0.2)),
              AppSpacing.vertMd,
              Text(l10n.noOrdersYet, style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.mutedSilver)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            if (i == state.orders.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold)),
              );
            }
            return _buildOrderCard(state.orders[i], l10n);
          },
          childCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  // ── Gradient Header ────────────────────────────────────────────

  Widget _buildGradientHeader(BuildContext context, AppLocalizations l10n) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        topPadding + AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121212), Color(0xFF030303)],
        ),
        border: const Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGold,
                  AppTheme.accentGold.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.black87, size: 18),
          ),
          AppSpacing.horzSm,
          Text(
            l10n.ordersHistoryLabel,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Consumer(
            builder: (ctx, ref, _) {
              final total = ref.watch(ordersProvider).total;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.15),
                  borderRadius: AppRadius.chipBorder,
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                ),
                child: Text(
                  l10n.totalOrdersCount(total),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: l10n.searchOrdersHint,
          hintStyle: GoogleFonts.montserrat(fontSize: 13, color: Colors.white24),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white24, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.white24),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: const Color(0xFF0D0D0D),
          border: OutlineInputBorder(
            borderRadius: AppRadius.inputBorder,
            borderSide: const BorderSide(color: Colors.white10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputBorder,
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputBorder,
            borderSide: const BorderSide(color: AppTheme.accentGold, width: 0.5),
          ),
        ),
        style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white),
      ),
    );
  }

  // ── Order Card ─────────────────────────────────────────────────

  Widget _buildOrderCard(StaffOrder order, AppLocalizations l10n) {
    final payBadge = _paymentBadge(order.paymentStatus, l10n);

    return _HoverableOrderCard(
      order: order,
      payBadge: payBadge,
      currencyFmt: _currencyFmt,
      dateFmt: _dateFmt,
      l10n: l10n,
      onTap: () => _showDetailSheet(order.id),
    );
  }

  void _showDetailSheet(String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrderDetailSheet(orderId: orderId),
    );
  }

  _PayBadge _paymentBadge(String status, AppLocalizations l10n) {
    switch (status) {
      case 'PAID':
        return _PayBadge(label: l10n.statusPaid, color: Colors.green.shade600, icon: Icons.check_circle_rounded);
      case 'PENDING':
        return _PayBadge(label: l10n.statusPendingPayment, color: Colors.orange.shade600, icon: Icons.hourglass_empty_rounded);
      case 'FAILED':
        return _PayBadge(label: l10n.statusCancelled, color: Colors.red.shade600, icon: Icons.cancel_rounded);
      default:
        return _PayBadge(label: status, color: AppTheme.mutedSilver, icon: Icons.help_outline_rounded);
    }
  }
}

class _OrderDetailSheet extends ConsumerWidget {
  final String orderId;
  const _OrderDetailSheet({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();
    
    final detail = ref.watch(orderDetailProvider(orderId));
    final currencyFmt = NumberFormat('#,###', 'vi');
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF030303),
        borderRadius: AppRadius.sheetBorder,
        border: const Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              ),
              Expanded(
                child: detail.when(
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold)),
                  error: (e, _) => Center(
                    child: AppErrorWidget(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
                    ),
                  ),
                  data: (order) => ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      _buildDetailHeader(context, l10n, order, currencyFmt, dateFmt),
                      AppSpacing.vertMd,
                      if (order.user != null || order.phone != null) _buildCustomerCard(l10n, order),
                      if (order.user != null || order.phone != null) AppSpacing.vertMd,
                      _buildItemsList(l10n, order, currencyFmt),
                      AppSpacing.vertMd,
                      _buildOrderSummary(l10n, order, currencyFmt),
                      if (order.payments.isNotEmpty) ...[AppSpacing.vertMd, _buildPaymentInfo(l10n, order)],
                      if (order.isPaid) ...[AppSpacing.vertMd, _buildReturnButton(context, l10n, ref, order)],
                      if (!order.isPaid && order.status != 'CANCELLED') ...[AppSpacing.vertMd, _buildActionButtons(context, l10n, ref, order)],
                      AppSpacing.vertMd,
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailHeader(BuildContext context, AppLocalizations l10n, StaffOrder order, NumberFormat currencyFmt, DateFormat dateFmt) {
    final isPaid = order.paymentStatus == 'PAID';
    final isCancelled = order.status == 'CANCELLED';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.code, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(dateFmt.format(order.createdAt.toLocal()), style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38)),
              if (order.store != null) Text(order.store?.name ?? '', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${currencyFmt.format(order.finalAmount)}đ', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.accentGold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: isCancelled ? Colors.red.withOpacity(0.1) : isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: AppRadius.chipBorder),
              child: Text(isCancelled ? l10n.statusCancelled : isPaid ? l10n.statusPaid : l10n.statusPendingPayment, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: isCancelled ? Colors.red.shade400 : isPaid ? Colors.green.shade400 : Colors.orange.shade400)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReturnButton(BuildContext context, AppLocalizations l10n, WidgetRef ref, StaffOrder order) {
    if (order.hasReturnRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.green.shade400),
            AppSpacing.horzSm,
            Text("Đã yêu cầu trả hàng thành công", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade400)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF121212),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder, side: const BorderSide(color: Colors.white10)),
              title: Text(l10n.confirmReturnTitle, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: Colors.white)),
              content: Text(l10n.confirmReturnDesc(order.code), style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white60)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.no, style: const TextStyle(color: Colors.white38))),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm, style: const TextStyle(color: AppTheme.accentGold))),
              ],
            ),
          );
          if (confirmed != true) return;

          if (!context.mounted) return;

          final ok = await ref.read(posProvider.notifier).createPosReturn(
            orderId: order.id,
            orderItems: order.items.map((e) => PosOrderItem(id: e.id, variantId: e.variantId, quantity: e.quantity, unitPrice: e.unitPrice, totalPrice: e.totalPrice, variant: e.variant != null ? PosOrderItemVariant(id: e.variant!.id, name: e.variant!.name, price: e.variant!.price, product: e.variant!.product != null ? PosOrderItemProduct(id: e.variant!.product!.id, name: e.variant!.product!.name) : null) : null)).toList(),
            reason: l10n.reasonCustomerReturnCounter,
          );
          if (!context.mounted) return;
          Navigator.pop(context);
          ref.read(ordersProvider.notifier).loadOrders();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? l10n.returnSuccess : l10n.returnError), backgroundColor: ok ? Colors.green.shade600 : Colors.red.shade600));
        },
        icon: const Icon(Icons.keyboard_return_rounded, size: 18),
        label: Text(l10n.returnRefundLabel),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder)),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n, WidgetRef ref, StaffOrder order) {
    if (order.paymentStatus != 'PENDING') return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              if (order.store?.id != null) ref.read(posSelectedStoreIdProvider.notifier).state = order.store!.id;
              ref.read(posProvider.notifier).loadExistingOrder(order.id, storeId: order.store?.id);
              ref.read(staffTabIndexProvider.notifier).state = 1;
            },
            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
            label: const Text("Tiếp tục thanh toán"),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder)),
          ),
        ),
        AppSpacing.horzSm,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmCancelOrder(context, l10n, ref, order),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text("Hủy đơn"),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade400, side: BorderSide(color: Colors.red.withOpacity(0.3)), padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder)),
          ),
        ),
      ],
    );
  }

  void _confirmCancelOrder(BuildContext context, AppLocalizations l10n, WidgetRef ref, StaffOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder, side: const BorderSide(color: Colors.white10)),
        title: Text(l10n.confirmCancelOrderTitle, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: Colors.white)),
        content: Text(l10n.confirmCancelOrderDesc(order.code), style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.no, style: GoogleFonts.montserrat(color: Colors.white38))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(posProvider.notifier).cancelOrder(order.id);
              if (context.mounted) {
                Navigator.pop(context);
                ref.read(ordersProvider.notifier).loadOrders();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? l10n.cancelOrderSuccess(order.code) : l10n.cancelOrderError), backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600));
              }
            },
            child: Text(l10n.statusCancelled, style: GoogleFonts.montserrat(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(AppLocalizations l10n, StaffOrder order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: const Color(0xFF0D0D0D), borderRadius: AppRadius.cardBorder, border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.accentGold.withOpacity(0.12), borderRadius: AppRadius.cardBorder), child: const Icon(Icons.person_rounded, size: 18, color: AppTheme.accentGold)),
          AppSpacing.horzSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.user?.fullName ?? l10n.guest, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                if (order.user?.phone != null || order.phone != null) Text(order.user?.phone ?? order.phone ?? '', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38)),
                if (order.user?.email != null) Text(order.user?.email ?? '', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(AppLocalizations l10n, StaffOrder order, NumberFormat currencyFmt) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF0D0D0D), borderRadius: AppRadius.cardBorder, border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm), child: Text('${l10n.products} (${order.items.length})', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white24, letterSpacing: 0.5))),
          ...order.items.asMap().entries.map((e) => _buildItemRow(e.value, e.key == order.items.length - 1, currencyFmt)),
        ],
      ),
    );
  }

  Widget _buildItemRow(StaffOrderItem item, bool isLast, NumberFormat currencyFmt) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10, width: 0.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.variant?.product?.imageUrl != null
                    ? Image.network(
                        item.variant!.product!.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 20, color: Colors.white10),
                      )
                    : const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.white10),
              ),
              AppSpacing.horzSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.variant?.product?.name ?? 'Sản phẩm',
                        style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('${item.variant?.name ?? ''}  ×${item.quantity}', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38)),
                  ],
                ),
              ),
              Text('${currencyFmt.format(item.totalPrice)}đ', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.white10, indent: AppSpacing.md, endIndent: AppSpacing.md),
      ],
    );
  }

  Widget _buildOrderSummary(AppLocalizations l10n, StaffOrder order, NumberFormat currencyFmt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: const Color(0xFF0D0D0D), borderRadius: AppRadius.cardBorder, border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          _Row(label: l10n.subtotal, value: '${currencyFmt.format(order.totalAmount)}đ'),
          if (order.discountAmount > 0) _Row(label: l10n.discount, value: '-${currencyFmt.format(order.discountAmount)}đ'),
          _Row(label: l10n.total, value: '${currencyFmt.format(order.finalAmount)}đ', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(AppLocalizations l10n, StaffOrder order) {
    final p = order.payments.first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: const Color(0xFF0D0D0D), borderRadius: AppRadius.cardBorder, border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Icon(p.provider == 'COD' ? Icons.payments_rounded : Icons.qr_code_rounded, size: 20, color: AppTheme.accentGold),
          AppSpacing.horzSm,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.paymentMethod, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38)), Text(p.provider, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: p.status == 'PAID' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: AppRadius.chipBorder), child: Text(p.status, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: p.status == 'PAID' ? Colors.green.shade400 : Colors.orange.shade400))),
        ],
      ),
    );
  }

}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _Row({required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.montserrat(fontSize: isBold ? 14 : 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: isBold ? Colors.white : Colors.white60)), Text(value, style: GoogleFonts.montserrat(fontSize: isBold ? 16 : 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: isBold ? AppTheme.accentGold : Colors.white))]),
    );
  }
}


class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: AppRadius.chipBorder, border: Border.all(color: color.withOpacity(0.3))), child: Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700, color: color)));
  }
}

class _PayBadge {
  final String label;
  final Color color;
  final IconData icon;
  const _PayBadge({required this.label, required this.color, required this.icon});
}

class _HoverableOrderCard extends StatefulWidget {
  final StaffOrder order;
  final _PayBadge payBadge;
  final NumberFormat currencyFmt;
  final DateFormat dateFmt;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _HoverableOrderCard({
    required this.order,
    required this.payBadge,
    required this.currencyFmt,
    required this.dateFmt,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_HoverableOrderCard> createState() => _HoverableOrderCardState();
}

class _HoverableOrderCardState extends State<_HoverableOrderCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final payBadge = widget.payBadge;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF121212) : const Color(0xFF0D0D0D),
            borderRadius: AppRadius.cardBorder,
            border: Border.all(
              color: _isHovered ? AppTheme.accentGold.withOpacity(0.3) : Colors.white10,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: _isHovered ? payBadge.color.withOpacity(0.9) : payBadge.color.withOpacity(0.7),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  boxShadow: _isHovered
                      ? [BoxShadow(color: payBadge.color.withOpacity(0.3), blurRadius: 8)]
                      : [],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: payBadge.color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: payBadge.color.withOpacity(0.15), width: 0.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: order.items.isNotEmpty && order.items.first.variant?.product?.imageUrl != null
                            ? Image.network(
                                order.items.first.variant!.product!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(payBadge.icon, size: 22, color: payBadge.color),
                              )
                            : Icon(payBadge.icon, size: 22, color: payBadge.color),
                      ),
                      AppSpacing.horzSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    order.code,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppSpacing.horzXs,
                                _StatusChip(label: payBadge.label, color: payBadge.color),
                                if (order.hasReturnRequest) ...[
                                  AppSpacing.horzXs,
                                  _StatusChip(label: "TRẢ HÀNG", color: Colors.blue.shade400),
                                ],
                              ],
                            ),
                            AppSpacing.vertXxs,
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 12, color: Colors.white38),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    order.customerDisplay,
                                    style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.vertXxs,
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 12, color: Colors.white38),
                                const SizedBox(width: 3),
                                Text(
                                  widget.dateFmt.format(order.createdAt.toLocal()),
                                  style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38),
                                ),
                                if (order.store != null) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.store_outlined, size: 12, color: Colors.white38),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      order.store?.name ?? '',
                                      style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.horzSm,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${widget.currencyFmt.format(order.finalAmount)}đ',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentGold,
                            ),
                          ),
                          AppSpacing.vertXxs,
                          Text(
                            widget.l10n.itemCount(order.items.length),
                            style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38),
                          ),
                        ],
                      ),
                    ],
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
