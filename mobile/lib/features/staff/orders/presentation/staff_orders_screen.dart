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
import '../../../../core/config/env.dart';
import '../../../../core/utils/responsive.dart';
import 'dart:ui';

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
      final range = ref.read(ordersDateRangeProvider);
      ref
          .read(ordersProvider.notifier)
          .loadMore(
            search: query.isEmpty ? null : query,
            startDate: range?.start.toUtc().toIso8601String(),
            endDate: range?.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toUtc().toIso8601String(),
          );
    }
  }

  void _onSearch(String value) {
    ref.read(ordersSearchQueryProvider.notifier).state = value;
    final range = ref.read(ordersDateRangeProvider);
    ref.read(ordersProvider.notifier).loadOrders(
      search: value.isEmpty ? null : value,
      startDate: range?.start.toUtc().toIso8601String(),
      endDate: range?.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toUtc().toIso8601String(),
    );
  }


  void _clearDateRange() {
    ref.read(ordersDateRangeProvider.notifier).state = null;
    final q = ref.read(ordersSearchQueryProvider);
    ref.read(ordersProvider.notifier).loadOrders(
      search: q.isEmpty ? null : q,
    );
  }

  void _applyRange(DateTimeRange range) {
    ref.read(ordersDateRangeProvider.notifier).state = range;
    final q = ref.read(ordersSearchQueryProvider);
    ref.read(ordersProvider.notifier).loadOrders(
      search: q.isEmpty ? null : q,
      startDate: range.start.toUtc().toIso8601String(),
      endDate: range.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toUtc().toIso8601String(),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DateFilterSheet(
        currentRange: ref.read(ordersDateRangeProvider),
        onSelect: (range) {
          Navigator.pop(context);
          _applyRange(range);
        },
        onCustomRange: () async {
          Navigator.pop(context);
          final newRange = await showDateRangePicker(
            context: context,
            initialDateRange: ref.read(ordersDateRangeProvider),
            firstDate: DateTime(2023),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppTheme.accentGold,
                    onPrimary: Colors.black,
                    surface: Color(0xFF1A1A1A),
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: const Color(0xFF121212),
                ),
                child: child!,
              );
            },
          );
          if (newRange != null) {
            _applyRange(newRange);
          }
        },
      ),
    );
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
    final isTablet = Responsive.isTablet(context) || Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accentGold,
          backgroundColor: const Color(0xFF1A1A1A),
          onRefresh: () async {
            final q = ref.read(ordersSearchQueryProvider);
            final range = ref.read(ordersDateRangeProvider);
            await ref.read(ordersProvider.notifier).loadOrders(
              search: q.isEmpty ? null : q,
              startDate: range?.start.toIso8601String(),
              endDate: range?.end.toIso8601String(),
            );
          },
          child: Column(
            children: [
              _buildGradientHeader(context, l10n),
              _buildSearchBar(l10n),
              if (!state.isLoading && state.orders.isNotEmpty) 
                _buildDashboardBar(state),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    _buildSliverBody(state, l10n),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardBar(OrdersState state) {
    if (Responsive.isMobile(context)) return const SizedBox.shrink();
    
    final totalRevenue = state.orders.fold<double>(0, (sum, order) => sum + order.finalAmount);
    final pendingCount = state.orders.where((o) => o.paymentStatus == 'PENDING').length;
    final paidCount = state.orders.where((o) => o.paymentStatus == 'PAID').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentGold.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DashboardItem(
                label: "TỔNG DOANH THU",
                value: "${_currencyFmt.format(totalRevenue)}đ",
                icon: Icons.auto_graph_rounded,
                isGold: true,
              ),
              _buildDivider(),
              _DashboardItem(
                label: "SỐ ĐƠN HÀNG",
                value: "${state.total}",
                icon: Icons.receipt_long_rounded,
              ),
              _buildDivider(),
              _DashboardItem(
                label: "ĐÃ THANH TOÁN",
                value: "$paidCount",
                icon: Icons.verified_rounded,
                color: const Color(0xFF4CAF50),
              ),
              _buildDivider(),
              _DashboardItem(
                label: "CHỜ THANH TOÁN",
                value: "$pendingCount",
                icon: Icons.pending_actions_rounded,
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 40, color: Colors.white10);

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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ordersHistoryLabel,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: Responsive.isMobile(context) ? 22 : 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Theo dõi và quản lý lịch sử giao dịch",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _TotalBadge(count: ref.watch(ordersProvider).total),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────

  Widget _buildSearchBar(AppLocalizations l10n) {
    final range = ref.watch(ordersDateRangeProvider);
    final hasRange = range != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.searchOrdersHint,
                  hintStyle: GoogleFonts.montserrat(fontSize: 13, color: Colors.white24),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white24, size: 20),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.white24),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showFilterOptions,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: hasRange ? AppTheme.accentGold.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasRange ? AppTheme.accentGold.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: hasRange ? AppTheme.accentGold : Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasRange
                        ? "${DateFormat('dd/MM').format(range.start)} - ${DateFormat('dd/MM').format(range.end)}"
                        : "Lọc ngày",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: hasRange ? AppTheme.accentGold : Colors.white38,
                      fontWeight: hasRange ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (hasRange) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _clearDateRange();
                      },
                      child: const Icon(Icons.close_rounded, size: 14, color: AppTheme.accentGold),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
        return _PayBadge(
          label: l10n.statusPaid, 
          color: const Color(0xFF4CAF50), 
          icon: Icons.verified_rounded,
          bgColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        );
      case 'PENDING':
        return _PayBadge(
          label: l10n.statusPendingPayment, 
          color: const Color(0xFFFF9800), 
          icon: Icons.pending_rounded,
          bgColor: const Color(0xFFFF9800).withValues(alpha: 0.1),
        );
      case 'FAILED':
        return _PayBadge(
          label: l10n.statusCancelled, 
          color: const Color(0xFFE57373), 
          icon: Icons.cancel_rounded,
          bgColor: const Color(0xFFE57373).withValues(alpha: 0.1),
        );
      default:
        return _PayBadge(
          label: status, 
          color: AppTheme.mutedSilver, 
          icon: Icons.help_outline_rounded,
          bgColor: Colors.white10,
        );
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
    final isMobile = Responsive.isMobile(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: isMobile ? 0.85 : 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollCtrl) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
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
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      children: [
                        _buildDetailHeader(context, l10n, order, currencyFmt, dateFmt),
                        const SizedBox(height: 32),
                        _buildStatusTimeline(order, l10n),
                        const SizedBox(height: 32),
                        if (order.user != null || order.phone != null) _buildCustomerSection(l10n, order),
                        const SizedBox(height: 32),
                        _buildItemsSection(l10n, order, currencyFmt),
                        const SizedBox(height: 32),
                        _buildSumarySection(l10n, order, currencyFmt),
                        if (order.payments.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          _buildPaymentInfo(l10n, order),
                        ],
                        const SizedBox(height: 40),
                        if (order.isPaid) _buildPaidReturnButton(context, l10n, ref, order),
                        if (!order.isPaid && order.status != 'CANCELLED') _buildActionButtons(context, l10n, ref, order),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(StaffOrder order, AppLocalizations l10n) {
    bool isCancelled = order.status == 'CANCELLED';
    bool isPaid = order.paymentStatus == 'PAID';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _TimelineStep(title: "Khởi tạo", isComplete: true, time: DateFormat('HH:mm').format(order.createdAt.toLocal())),
          _TimelineConnector(isComplete: isPaid || isCancelled),
          _TimelineStep(
            title: isPaid ? "Thanh toán" : (isCancelled ? "Đã huỷ" : "Chờ xử lý"), 
            isComplete: isPaid || isCancelled,
            isAlert: isCancelled,
          ),
          _TimelineConnector(isComplete: isPaid && !isCancelled),
          _TimelineStep(title: "Hoàn tất", isComplete: isPaid && !isCancelled, last: true),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(AppLocalizations l10n, StaffOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "THÔNG TIN KHÁCH HÀNG"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentGold.withValues(alpha: 0.2), AppTheme.accentGold.withValues(alpha: 0.05)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppTheme.accentGold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.user?.fullName ?? order.phone ?? l10n.guest, 
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(order.user?.phone ?? order.phone ?? 'Không có số điện thoại', 
                      style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (order.user?.email != null)
                const Icon(Icons.verified_user_rounded, size: 20, color: Colors.greenAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(AppLocalizations l10n, StaffOrder order, NumberFormat currencyFmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${l10n.products.toUpperCase()} (${order.items.length})", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 70),
            itemBuilder: (ctx, i) => _buildItemTile(order.items[i], currencyFmt),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(StaffOrderItem item, NumberFormat currencyFmt) {
    String? imageUrl = item.variant?.product?.imageUrl;
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = '${EnvConfig.apiBaseUrl}/$imageUrl';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.white10),
                  )
                : const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.white10),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.variant?.product?.name ?? 'Sản phẩm', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text("${item.variant?.name} × ${item.quantity}", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text("${currencyFmt.format(item.totalPrice)}đ", style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSumarySection(AppLocalizations l10n, StaffOrder order, NumberFormat currencyFmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _SummaryRow(label: l10n.subtotal, value: "${currencyFmt.format(order.totalAmount)}đ"),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 12),
            _SummaryRow(label: "Giảm giá", value: "-${currencyFmt.format(order.discountAmount)}đ", color: Colors.redAccent),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Colors.white10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text("${currencyFmt.format(order.finalAmount)}đ", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accentGold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaidReturnButton(BuildContext context, AppLocalizations l10n, WidgetRef ref, StaffOrder order) {
    if (order.hasReturnRequest) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 12),
            Text("ĐÃ YÊU CẦU TRẢ HÀNG", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.greenAccent, letterSpacing: 1)),
          ],
        ),
      );
    }

    return _PremiumButton(
      label: l10n.returnRefundLabel,
      icon: Icons.keyboard_return_rounded,
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF151515),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
            title: Text(l10n.confirmReturnTitle, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w800, color: Colors.white)),
            content: Text(l10n.confirmReturnDesc(order.code), style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white60)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.no, style: GoogleFonts.montserrat(color: Colors.white38, fontWeight: FontWeight.w600))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm, style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontWeight: FontWeight.w800))),
            ],
          ),
        );
        if (confirmed == true) {
          final ok = await ref.read(posProvider.notifier).createPosReturn(
            orderId: order.id,
            orderItems: order.items.map((e) => PosOrderItem(id: e.id, variantId: e.variantId, quantity: e.quantity, unitPrice: e.unitPrice, totalPrice: e.totalPrice, variant: e.variant != null ? PosOrderItemVariant(id: e.variant!.id, name: e.variant!.name, price: e.variant!.price, product: e.variant!.product != null ? PosOrderItemProduct(id: e.variant!.product!.id, name: e.variant!.product!.name) : null) : null)).toList(),
            reason: l10n.reasonCustomerReturnCounter,
          );
          if (context.mounted) {
            Navigator.pop(context);
            ref.read(ordersProvider.notifier).loadOrders();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? l10n.returnSuccess : l10n.returnError), backgroundColor: ok ? Colors.green.shade600 : Colors.red.shade600));
          }
        }
      },
      color: const Color(0xFF1A1A1A),
      textColor: Colors.white,
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n, WidgetRef ref, StaffOrder order) {
    if (order.paymentStatus != 'PENDING') return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _PremiumButton(
            label: "Tiếp tục thanh toán",
            icon: Icons.shopping_cart_checkout_rounded,
            onTap: () {
              Navigator.pop(context);
              if (order.store?.id != null) ref.read(posSelectedStoreIdProvider.notifier).state = order.store!.id;
              ref.read(posProvider.notifier).loadExistingOrder(order.id, storeId: order.store?.id);
              ref.read(staffTabIndexProvider.notifier).state = 1;
            },
            color: AppTheme.accentGold,
            textColor: Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PremiumButton(
            label: "Hủy đơn",
            icon: Icons.cancel_outlined,
            onTap: () => _confirmCancelOrder(context, l10n, ref, order),
            color: Colors.transparent,
            textColor: Colors.redAccent,
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  void _confirmCancelOrder(BuildContext context, AppLocalizations l10n, WidgetRef ref, StaffOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
        title: Text(l10n.confirmCancelOrderTitle, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text(l10n.confirmCancelOrderDesc(order.code), style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.no, style: GoogleFonts.montserrat(color: Colors.white38, fontWeight: FontWeight.w600))),
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
            child: Text(l10n.statusCancelled, style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(BuildContext context, AppLocalizations l10n, StaffOrder order, NumberFormat currencyFmt, DateFormat dateFmt) {
    final status = order.status == 'CANCELLED' ? l10n.statusCancelled : (order.paymentStatus == 'PAID' ? l10n.statusPaid : l10n.statusPendingPayment);
    final color = order.status == 'CANCELLED' ? Colors.redAccent : (order.paymentStatus == 'PAID' ? Colors.greenAccent : Colors.orangeAccent);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.code, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 12, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(dateFmt.format(order.createdAt.toLocal()), style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
        _StatusBadge(label: status.toUpperCase(), color: color),
      ],
    );
  }

  Widget _buildPaymentInfo(AppLocalizations l10n, StaffOrder order) {
    if (order.payments.isEmpty) return const SizedBox.shrink();
    final p = order.payments.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              p.provider == 'COD' ? Icons.payments_rounded : Icons.qr_code_rounded, 
              size: 20, 
              color: AppTheme.accentGold
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(l10n.paymentMethod.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(p.provider, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))
              ]
            )
          ),
          _StatusChip(label: p.status, color: p.status == 'PAID' ? Colors.greenAccent : Colors.orangeAccent),
        ],
      ),
    );
  }
}



class _TotalBadge extends StatelessWidget {
  final int count;
  const _TotalBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$count",
            style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.accentGold),
          ),
          const SizedBox(width: 6),
          Text(
            "đơn",
            style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SummaryRow({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white38, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? Colors.white70)),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final bool isComplete;
  final bool isAlert;
  final String? time;
  final bool last;

  const _TimelineStep({required this.title, required this.isComplete, this.isAlert = false, this.time, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: last ? 0 : 1,
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isComplete ? (isAlert ? Colors.redAccent : Colors.greenAccent) : Colors.white24,
              shape: BoxShape.circle,
              boxShadow: isComplete ? [BoxShadow(color: (isAlert ? Colors.redAccent : Colors.greenAccent).withOpacity(0.3), blurRadius: 4)] : [],
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w800, color: isComplete ? Colors.white70 : Colors.white24, letterSpacing: 0.5)),
          if (time != null) ...[
            const SizedBox(height: 2),
            Text(time!, style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white38)),
          ],
        ],
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  final bool isComplete;
  const _TimelineConnector({required this.isComplete});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 24),
        color: isComplete ? Colors.greenAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final bool isOutlined;

  const _PremiumButton({
    required this.label, 
    required this.icon, 
    required this.onTap, 
    required this.color, 
    required this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined ? Border.all(color: textColor.withOpacity(0.3)) : null,
          boxShadow: !isOutlined ? [
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;
  const _StatusChip({required this.label, required this.color, this.small = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: AppRadius.chipBorder,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: small ? 8 : 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _PayBadge {
  final String label;
  final Color color;
  final IconData icon;
  final Color bgColor;
  const _PayBadge({required this.label, required this.color, required this.icon, required this.bgColor});
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
    final isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? AppTheme.accentGold.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
              width: 0.8,
            ),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.05),
                blurRadius: 15,
                spreadRadius: -5,
              )
            ] : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductPreview(order, payBadge),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Code and Status
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            order.code,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 8),
                          _StatusChip(label: payBadge.label, color: payBadge.color),
                          if (order.hasReturnRequest) ...[
                            const SizedBox(width: 4),
                            _StatusChip(label: "TRẢ HÀNG", color: Colors.blueAccent),
                          ],
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Middle Row: Price and Count for Mobile
                    if (isMobile) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text(
                      '${widget.currencyFmt.format(order.finalAmount)}đ',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentGold,
                      ),
                    ),
                          Wrap(
                            spacing: 4,
                            children: [
                              _StatusChip(label: payBadge.label, color: payBadge.color, small: true),
                              if (order.hasReturnRequest)
                                _StatusChip(label: "TRẢ", color: Colors.blueAccent, small: true),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Bottom Row: Meta Info
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 12, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text(
                              order.customerDisplay,
                              style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text(
                              widget.dateFmt.format(order.createdAt.toLocal()),
                              style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        if (isMobile)
                          Text(
                            "• ${order.items.length} sản phẩm",
                            style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.currencyFmt.format(order.finalAmount)}đ',
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${order.items.length} sản phẩm",
                      style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Icon(Icons.chevron_right_rounded, color: _isHovered ? AppTheme.accentGold : Colors.white10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductPreview(StaffOrder order, _PayBadge payBadge) {
    final hasImage = order.items.isNotEmpty && order.items.first.variant?.product?.imageUrl != null;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              '${EnvConfig.apiBaseUrl}${order.items.first.variant!.product!.imageUrl!}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(payBadge.icon, size: 18, color: payBadge.color.withOpacity(0.5)),
            )
          : Icon(payBadge.icon, size: 18, color: payBadge.color.withOpacity(0.5)),
    );
  }
}

class _DateFilterSheet extends StatelessWidget {
  final DateTimeRange? currentRange;
  final Function(DateTimeRange) onSelect;
  final VoidCallback onCustomRange;

  const _DateFilterSheet({
    required this.currentRange,
    required this.onSelect,
    required this.onCustomRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Chọn thời gian lọc",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildOption(
                icon: Icons.today_rounded,
                title: "Hôm nay",
                subtitle: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                onTap: () {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  onSelect(DateTimeRange(start: today, end: today));
                },
              ),
              _buildOption(
                icon: Icons.history_rounded,
                title: "Hôm qua",
                subtitle: DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 1))),
                onTap: () {
                  final now = DateTime.now();
                  final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
                  onSelect(DateTimeRange(start: yesterday, end: yesterday));
                },
              ),
              _buildOption(
                icon: Icons.date_range_rounded,
                title: "7 ngày qua",
                subtitle: "Từ ngày ${DateFormat('dd/MM').format(DateTime.now().subtract(const Duration(days: 7)))}",
                onTap: () {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  onSelect(DateTimeRange(start: today.subtract(const Duration(days: 7)), end: today));
                },
              ),
              const Divider(color: Colors.white10, height: 32),
              _buildOption(
                icon: Icons.calendar_month_rounded,
                title: "Tùy chọn khoảng ngày",
                subtitle: "Chọn ngày bắt đầu và kết thúc",
                color: AppTheme.accentGold,
                onTap: onCustomRange,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? Colors.white70, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          color: Colors.white38,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white10),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DashboardItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isGold;
  final Color? color;

  const _DashboardItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isGold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isGold ? AppTheme.accentGold : (color ?? Colors.white70);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: displayColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: displayColor),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9,
            color: Colors.white38,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: displayColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppTheme.accentGold.withValues(alpha: 0.6),
        letterSpacing: 2,
      ),
    );
  }
}

