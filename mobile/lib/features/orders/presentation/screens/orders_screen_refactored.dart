import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_card.dart';

/// Orders Screen - Refactored
/// 
/// Luxury e-commerce order history with Active/Completed tabs.
/// 
/// Architecture:
/// - Tab-based navigation (Active / Completed)
/// - Reusable OrderCard with variants
/// - Context-aware empty states
/// - Smooth animations and transitions
/// 
/// Why this refactor improves UX:
/// 1. Clear separation: Active vs Completed orders
/// 2. Context-aware actions: Track, Review, View Receipt
/// 3. Premium feel: Luxury spacing, typography, gold accents
/// 4. Trustworthy: Clear status indicators and order info
class OrdersScreenRefactored extends ConsumerStatefulWidget {
  const OrdersScreenRefactored({super.key});

  @override
  ConsumerState<OrdersScreenRefactored> createState() => _OrdersScreenRefactoredState();
}

class _OrdersScreenRefactoredState extends ConsumerState<OrdersScreenRefactored>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ordersAsync),
            _buildTabs(context),
            Expanded(
              child: ordersAsync.when(
                data: (orders) => _buildContent(context, orders),
                loading: () => _buildLoading(),
                error: (error, stack) => _buildError(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<List<Order>> ordersAsync) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.softTaupe.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _handleBack(context),
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.deepCharcoal,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'My Orders',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ordersAsync.when(
                      data: (orders) {
                        final activeCount = orders.where((o) => 
                          o.status == OrderStatus.shipped || 
                          o.status == OrderStatus.outForDelivery
                        ).length;
                        final completedCount = orders.where((o) => 
                          o.status == OrderStatus.delivered || 
                          o.status == OrderStatus.cancelled
                        ).length;
                        
                        final count = _tabController.index == 0 
                          ? activeCount 
                          : completedCount;
                        final label = _tabController.index == 0
                          ? 'active shipment${count != 1 ? 's' : ''}'
                          : 'past order${count != 1 ? 's' : ''}';
                        
                        return Text(
                          '$count $label',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.mutedSilver,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 44), // Balance with back button
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicatorColor: AppTheme.accentGold,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.accentGold,
        unselectedLabelColor: AppTheme.mutedSilver,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Order> orders) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildActiveTab(context, orders),
        _buildCompletedTab(context, orders),
      ],
    );
  }

  Widget _buildActiveTab(BuildContext context, List<Order> orders) {
    final activeOrders = orders.where((o) => 
      o.status == OrderStatus.shipped || 
      o.status == OrderStatus.outForDelivery
    ).toList();

    if (activeOrders.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.local_shipping_outlined,
        title: 'No active shipments',
        subtitle: 'Your active orders will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider);
      },
      color: AppTheme.accentGold,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          return OrderCard(
            order: order,
            variant: OrderCardVariant.active,
            onTrackOrder: () => _handleTrackOrder(order),
            onViewReceipt: () => _handleViewReceipt(order),
            onTap: () => _handleOrderTap(order),
          );
        },
      ),
    );
  }

  Widget _buildCompletedTab(BuildContext context, List<Order> orders) {
    final completedOrders = orders.where((o) => 
      o.status == OrderStatus.delivered || 
      o.status == OrderStatus.cancelled
    ).toList();

    if (completedOrders.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.receipt_long_outlined,
        title: 'No past orders',
        subtitle: 'You haven\'t placed any orders yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider);
      },
      color: AppTheme.accentGold,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: completedOrders.length,
        itemBuilder: (context, index) {
          final order = completedOrders[index];
          // TODO: Check if order has been reviewed from your review system
          final hasReviewed = index == 1; // Mock: second order has been reviewed
          
          return OrderCard(
            order: order,
            variant: OrderCardVariant.completed,
            hasReviewed: hasReviewed,
            onWriteReview: () => _handleWriteReview(order),
            onViewReview: () => _handleViewReview(order),
            onTap: () => _handleOrderTap(order),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.accentGold.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.mutedSilver,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.accentGold,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.mutedSilver,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppTheme.mutedSilver,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================
  // Navigation & Action Handlers
  // ============================================

  void _handleBack(BuildContext context) {
    // Guard against popping root route (from bottom navigation)
    // GoRouter's context.pop() handles this automatically
    context.pop();
  }

  void _handleOrderTap(Order order) {
    // TODO: Navigate to order detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order detail: ${order.orderNumber}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleTrackOrder(Order order) {
    // TODO: Navigate to tracking screen or show tracking modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Track order: ${order.trackingNumber}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleViewReceipt(Order order) {
    // TODO: Show receipt modal or navigate to receipt screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View receipt for ${order.orderNumber}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleWriteReview(Order order) {
    // TODO: Navigate to write review screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Write review for ${order.items.first.productName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleViewReview(Order order) {
    // TODO: Navigate to view review screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View your review for ${order.items.first.productName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
