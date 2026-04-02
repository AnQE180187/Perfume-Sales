import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../services/inventory_socket_service.dart';

class StaffInventoryScreen extends ConsumerStatefulWidget {
  const StaffInventoryScreen({super.key});

  @override
  ConsumerState<StaffInventoryScreen> createState() =>
      _StaffInventoryScreenState();
}

class _StaffInventoryScreenState extends ConsumerState<StaffInventoryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _autoSelectStore();
      _connectInventorySocket();
    });
  }

  @override
  void dispose() {
    ref.read(inventorySocketServiceProvider).disconnect();
    super.dispose();
  }

  Future<void> _connectInventorySocket() async {
    final tokenStorage = ref.read(secureTokenStorageProvider);
    final token = await tokenStorage.getAccessToken();
    if (token == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref
        .read(inventorySocketServiceProvider)
        .connect(
          token: token,
          userId: user.id,
          onRequestReviewed: (data) {
            // Refresh pending requests banner
            ref.invalidate(myInventoryRequestsProvider);
            // Refresh inventory overview (stock may have changed)
            final storeId = ref.read(selectedStoreIdProvider);
            if (storeId != null) {
              ref.read(inventoryProvider.notifier).loadOverview(storeId);
            }
            // Show notification snackbar
            if (mounted) {
              final status = data['status'] as String?;
              final isApproved = status == 'APPROVED';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isApproved
                        ? 'Yêu cầu #${data['id']} đã được duyệt ✓'
                        : 'Yêu cầu #${data['id']} đã bị từ chối',
                  ),
                  backgroundColor: isApproved
                      ? Colors.green
                      : Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
  }

  Future<void> _autoSelectStore() async {
    final storesAsync = ref.read(staffStoresProvider);
    storesAsync.whenData((stores) {
      if (stores.isNotEmpty && ref.read(selectedStoreIdProvider) == null) {
        ref.read(selectedStoreIdProvider.notifier).state = stores.first.id;
        ref.read(inventoryProvider.notifier).loadOverview(stores.first.id);
      }
    });
  }

  void _onStoreChanged(String? storeId) {
    if (storeId == null) return;
    ref.read(selectedStoreIdProvider.notifier).state = storeId;
    ref.read(inventoryProvider.notifier).loadOverview(storeId);
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(staffStoresProvider);
    final selectedStoreId = ref.watch(selectedStoreIdProvider);
    final inventoryState = ref.watch(inventoryProvider);

    // Auto-select first store when data arrives initially
    storesAsync.whenData((stores) {
      if (stores.isNotEmpty && selectedStoreId == null) {
        Future.microtask(() {
          ref.read(selectedStoreIdProvider.notifier).state = stores.first.id;
          ref.read(inventoryProvider.notifier).loadOverview(stores.first.id);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _buildGradientHeader(context, storesAsync, selectedStoreId),
          ),
          if (inventoryState.overview != null)
            SliverToBoxAdapter(
              child: _buildStatsRow(inventoryState.overview!.stats),
            ),
          if (selectedStoreId != null)
            SliverToBoxAdapter(
              child: _buildPendingRequestsBanner(selectedStoreId),
            ),
          SliverToBoxAdapter(child: _buildSearchBar()),
        ],
        body: _buildBody(inventoryState, selectedStoreId),
      ),
    );
  }

  // ── Gradient Header ─────────────────────────────────────────────

  Widget _buildGradientHeader(
    BuildContext context,
    AsyncValue storesAsync,
    String? selectedStoreId,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.of(context).padding.top + AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGold,
                      AppTheme.accentGold.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              AppSpacing.horzSm,
              Text(
                'Quản lý kho',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          AppSpacing.vertXs,
          // Store selector inside header
          storesAsync.when(
            loading: () => const SizedBox(
              height: 44,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accentGold,
                ),
              ),
            ),
            error: (e, _) => Text(
              'Lỗi tải cửa hàng',
              style: TextStyle(color: Colors.red.shade300, fontSize: 13),
            ),
            data: (storesRaw) {
              final stores = (storesRaw as List).cast<dynamic>();
              if (stores.isEmpty) {
                return Container(
                  padding: AppSpacing.cardInner,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade900.withValues(alpha: 0.3),
                    borderRadius: AppRadius.cardBorder,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade300,
                        size: 20,
                      ),
                      AppSpacing.horzSm,
                      Expanded(
                        child: Text(
                          'Bạn chưa được gán vào cửa hàng nào.',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.orange.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: AppRadius.cardBorder,
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStoreId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2C2C2C),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.accentGold,
                    ),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    items: stores.map<DropdownMenuItem<String>>((s) {
                      return DropdownMenuItem<String>(
                        value: s.id as String,
                        child: Text(
                          s.name as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _onStoreChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────

  Widget _buildStatsRow(InventoryStats stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.all_inbox_rounded,
            label: 'Tổng SP',
            value: '${stats.totalUnits}',
            color: AppTheme.accentGold,
          ),
          AppSpacing.horzSm,
          _StatChip(
            icon: Icons.warning_amber_rounded,
            label: 'Sắp hết',
            value: '${stats.lowStockCount}',
            color: Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  // ── Pending Requests Banner ──────────────────────────────────────

  Widget _buildPendingRequestsBanner(String storeId) {
    final requestsAsync = ref.watch(myInventoryRequestsProvider(storeId));

    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        final pending = requests.where((r) => r.isPending).toList();
        if (pending.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: AppRadius.cardBorder,
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Yêu cầu chờ duyệt (${pending.length})',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...pending
                    .take(3)
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: r.type == 'IMPORT'
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r.type == 'IMPORT' ? 'Nhập' : 'Đ.chỉnh',
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: r.type == 'IMPORT'
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${r.product ?? ''} — ${r.variantName ?? ''} (${r.quantity > 0 ? '+' : ''}${r.quantity})',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: AppTheme.deepCharcoal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (pending.length > 3)
                  Text(
                    '...và ${pending.length - 3} yêu cầu khác',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.amber.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: GoogleFonts.montserrat(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tìm sản phẩm...',
          hintStyle: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppTheme.mutedSilver,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppTheme.mutedSilver,
          ),
          filled: true,
          fillColor: AppTheme.creamWhite,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.cardBorder,
            borderSide: BorderSide(color: AppTheme.softTaupe),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.cardBorder,
            borderSide: BorderSide(color: AppTheme.softTaupe),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.cardBorder,
            borderSide: const BorderSide(
              color: AppTheme.accentGold,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────

  Widget _buildBody(InventoryState inventoryState, String? selectedStoreId) {
    if (selectedStoreId == null) {
      return Center(
        child: Text(
          'Vui lòng chọn cửa hàng',
          style: GoogleFonts.montserrat(
            color: AppTheme.mutedSilver,
            fontSize: 14,
          ),
        ),
      );
    }

    if (inventoryState.isLoading && inventoryState.overview == null) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: ShimmerCard(height: 80),
        ),
      );
    }

    if (inventoryState.error != null && inventoryState.overview == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade300,
            ),
            AppSpacing.vertSm,
            Text(
              'Không thể tải dữ liệu kho',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.red.shade400,
              ),
            ),
            AppSpacing.vertSm,
            TextButton(
              onPressed: () => ref
                  .read(inventoryProvider.notifier)
                  .loadOverview(selectedStoreId),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final overview = inventoryState.overview;
    if (overview == null) return const SizedBox.shrink();

    var variants = overview.variants;
    if (_searchQuery.isNotEmpty) {
      variants = variants.where((v) {
        return v.name.toLowerCase().contains(_searchQuery) ||
            v.variantName.toLowerCase().contains(_searchQuery) ||
            (v.brand?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    if (variants.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? 'Không có sản phẩm' : 'Không tìm thấy',
          style: GoogleFonts.montserrat(
            color: AppTheme.mutedSilver,
            fontSize: 14,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accentGold,
      onRefresh: () =>
          ref.read(inventoryProvider.notifier).loadOverview(selectedStoreId),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          100,
        ),
        itemCount: variants.length,
        separatorBuilder: (_, __) => AppSpacing.vertXs,
        itemBuilder: (context, index) {
          final variant = variants[index];
          return _InventoryTile(
            variant: variant,
            onImport: () => _showImportSheet(context, variant),
            onAdjust: () => _showAdjustSheet(context, variant),
          );
        },
      ),
    );
  }

  // ── Import Bottom Sheet ─────────────────────────────────────────

  void _showImportSheet(BuildContext context, InventoryVariant variant) {
    final qtyController = TextEditingController();
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhập kho',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              AppSpacing.vertXs,
              Text(
                '${variant.name} — ${variant.variantName}',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppTheme.mutedSilver,
                ),
              ),
              AppSpacing.vertMd,
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số lượng nhập',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorder,
                  ),
                ),
              ),
              AppSpacing.vertXs,
              // Quick import chips
              Wrap(
                spacing: AppSpacing.xs,
                children: [10, 20, 50, 100].map((n) {
                  return ActionChip(
                    label: Text(
                      '+$n',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    backgroundColor: AppTheme.accentGold.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppTheme.accentGold.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.chipBorder,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final current =
                          int.tryParse(qtyController.text.trim()) ?? 0;
                      qtyController.text = '${current + n}';
                    },
                  );
                }).toList(),
              ),
              AppSpacing.vertSm,
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Lý do (tuỳ chọn)',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorder,
                  ),
                ),
              ),
              AppSpacing.vertMd,
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonBorder,
                    ),
                  ),
                  onPressed: () async {
                    final qty = int.tryParse(qtyController.text.trim());
                    if (qty == null || qty <= 0) return;
                    final storeId = ref.read(selectedStoreIdProvider);
                    if (storeId == null) return;
                    Navigator.of(ctx).pop();
                    final request = await ref
                        .read(inventoryProvider.notifier)
                        .importStock(
                          storeId: storeId,
                          variantId: variant.id,
                          quantity: qty,
                          reason: reasonController.text.trim().isEmpty
                              ? null
                              : reasonController.text.trim(),
                        );
                    if (request != null) {
                      ref.invalidate(myInventoryRequestsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Yêu cầu nhập kho đã gửi, chờ admin duyệt',
                            ),
                            backgroundColor: AppTheme.accentGold,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Gửi yêu cầu nhập kho',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Adjust Bottom Sheet ─────────────────────────────────────────

  void _showAdjustSheet(BuildContext context, InventoryVariant variant) {
    final deltaController = TextEditingController();
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điều chỉnh tồn kho',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              AppSpacing.vertXs,
              Text(
                '${variant.name} — ${variant.variantName}  (hiện tại: ${variant.stock})',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppTheme.mutedSilver,
                ),
              ),
              AppSpacing.vertMd,
              TextField(
                controller: deltaController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Số lượng thay đổi (+/-)',
                  hintText: 'VD: -3 hoặc +5',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorder,
                  ),
                ),
              ),
              AppSpacing.vertSm,
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Lý do (bắt buộc)',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorder,
                  ),
                ),
              ),
              AppSpacing.vertMd,
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepCharcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonBorder,
                    ),
                  ),
                  onPressed: () async {
                    final delta = int.tryParse(deltaController.text.trim());
                    final reason = reasonController.text.trim();
                    if (delta == null || delta == 0 || reason.isEmpty) return;
                    final storeId = ref.read(selectedStoreIdProvider);
                    if (storeId == null) return;
                    Navigator.of(ctx).pop();
                    final request = await ref
                        .read(inventoryProvider.notifier)
                        .adjustStock(
                          storeId: storeId,
                          variantId: variant.id,
                          delta: delta,
                          reason: reason,
                        );
                    if (request != null) {
                      ref.invalidate(myInventoryRequestsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Yêu cầu điều chỉnh đã gửi, chờ admin duyệt',
                            ),
                            backgroundColor: AppTheme.deepCharcoal,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Gửi yêu cầu điều chỉnh',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// STAT CHIP WIDGET
// ══════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppTheme.creamWhite,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            AppSpacing.horzXs,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: AppTheme.mutedSilver,
                    letterSpacing: 0.3,
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

// ══════════════════════════════════════════════════════════════════════
// INVENTORY TILE WIDGET
// ══════════════════════════════════════════════════════════════════════

class _InventoryTile extends StatelessWidget {
  final InventoryVariant variant;
  final VoidCallback onImport;
  final VoidCallback onAdjust;

  const _InventoryTile({
    required this.variant,
    required this.onImport,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final Color stockColor;
    final String stockLabel;
    if (variant.isOutOfStock) {
      stockColor = Colors.red.shade600;
      stockLabel = 'Hết hàng';
    } else if (variant.isLowStock) {
      stockColor = Colors.orange.shade600;
      stockLabel = 'Sắp hết (${variant.stock})';
    } else {
      stockColor = const Color(0xFF2E7D32);
      stockLabel = '${variant.stock}';
    }

    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: variant.isOutOfStock
              ? Colors.red.shade200
              : variant.isLowStock
              ? Colors.orange.shade200
              : AppTheme.softTaupe.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: variant.imageUrl != null && variant.imageUrl!.isNotEmpty
                ? Image.network(
                    variant.imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      color: AppTheme.softTaupe.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 22,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                  )
                : Container(
                    width: 52,
                    height: 52,
                    color: AppTheme.softTaupe.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 22,
                      color: AppTheme.mutedSilver,
                    ),
                  ),
          ),
          AppSpacing.horzSm,
          // Left accent bar
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: stockColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.horzSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variant.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepCharcoal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${variant.variantName}${variant.brand != null ? ' · ${variant.brand}' : ''}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppTheme.mutedSilver,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text(
                        stockLabel,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: stockColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vertSm,
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Nhập kho',
                        color: AppTheme.accentGold,
                        onTap: onImport,
                        filled: true,
                      ),
                    ),
                    AppSpacing.horzSm,
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.tune_rounded,
                        label: 'Điều chỉnh',
                        color: AppTheme.deepCharcoal,
                        onTap: onAdjust,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// SMALL ACTION BUTTON
// ══════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.inputBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : null,
          border: filled
              ? null
              : Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: AppRadius.inputBorder,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
