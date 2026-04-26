import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_async_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/order_realtime_provider.dart';
import '../sections/active_orders_section.dart';
import '../sections/completed_orders_section.dart';
import '../sections/cancelled_orders_section.dart';
import '../sections/returns_section.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderState = ref.watch(orderProvider);

    // Auto-refresh order list when any order status changes in real-time
    ref.listen<OrderStatusEvent?>(orderRealtimeProvider, (prev, next) {
      if (next != null) {
        ref.read(orderProvider.notifier).refresh();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppTheme.deepCharcoal,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          l10n.orderHistory,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.deepCharcoal,
          unselectedLabelColor: AppTheme.mutedSilver,
          tabs: [
            Tab(text: l10n.ordersActive),
            Tab(text: l10n.ordersCompleted),
            Tab(text: l10n.ordersReturns),
            Tab(text: l10n.ordersCancelled),
          ],
        ),
      ),
      body: AppAsyncWidget(
        value: orderState,
        onRetry: () => _refresh(),
        loadingBuilder: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: ShimmerCard(height: 160),
          ),
        ),
        dataBuilder: (state) {
          // Business rule:
          // - Orders with an active return request show in "Returns"
          // - If the return request is cancelled, the order behaves as normal
          //   (i.e., still appears in "Completed" if completed)
          final activeOrders =
              state.active.where((o) => !o.hasActiveReturn).toList();
          final completedOrders =
              state.completed.where((o) => !o.hasActiveReturn).toList();
          final returnedOrders = state.all
              .where((o) => o.hasActiveReturn)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return TabBarView(
            controller: _tabController,
            children: [
              ActiveOrdersSection(
                orders: activeOrders,
                onRefresh: _refresh,
                onTapOrder: _openOrderDetail,
                onTrackOrder: _openTracking,
              ),
              CompletedOrdersSection(
                orders: completedOrders,
                onRefresh: _refresh,
                onTapOrder: _openOrderDetail,
              ),
              ReturnsSection(
                orders: returnedOrders,
                onRefresh: _refresh,
                onTapReturn: _openReturnDetail,
              ),
              CancelledOrdersSection(
                orders: state.cancelled,
                onRefresh: _refresh,
                onTapOrder: _openOrderDetail,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _refresh() => ref.read(orderProvider.notifier).refresh();

  void _openOrderDetail(Order order) {
    context.push(AppRoutes.orderDetailWithId(order.id));
  }

  void _openReturnDetail(String returnId) {
    context.push(AppRoutes.returnDetailWithId(returnId));
  }

  void _openTracking(Order order) {
    context.push(AppRoutes.trackOrderWithId(order.id));
  }
}
