import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../../core/config/env.dart';
import '../../pos/providers/pos_provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../../tablet/presentation/tablet_inventory_adjust_dialog.dart';
import '../../tablet/presentation/tablet_inventory_import_dialog.dart';
import '../../../../core/widgets/app_error_widget.dart';
import 'staff_inventory_history_screen.dart';
import 'staff_inventory_requests_screen.dart';
import '../../../../core/utils/responsive.dart';

class StaffInventoryScreen extends ConsumerStatefulWidget {
  const StaffInventoryScreen({super.key});

  @override
  ConsumerState<StaffInventoryScreen> createState() => _StaffInventoryScreenState();
}

class _StaffInventoryScreenState extends ConsumerState<StaffInventoryScreen> {
  String _searchQuery = "";
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedStoreId = ref.read(selectedStoreIdProvider);
      if (selectedStoreId != null) {
        ref.read(inventoryProvider.notifier).loadOverview(selectedStoreId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    final selectedStoreId = ref.watch(selectedStoreIdProvider);
    final storesAsync = ref.watch(posStoresProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by Shell
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4), // Soften the molecular background
        ),
        child: Column(
          children: [
            _buildBoutiqueHeader(context, storesAsync, selectedStoreId),
            
            if (inventoryState.overview != null)
              _buildGlassDashboard(inventoryState.overview!),

            _buildRefinedSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (selectedStoreId != null) {
                    await ref.read(inventoryProvider.notifier).loadOverview(selectedStoreId);
                  }
                },
                color: AppTheme.accentGold,
                backgroundColor: const Color(0xFF141414),
                child: _buildPremiumInventoryTable(inventoryState, selectedStoreId),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (ctx) => const TabletInventoryImportDialog(),
        ),
        backgroundColor: AppTheme.accentGold,
        elevation: 10,
        icon: const Icon(Icons.add_box_rounded, color: Colors.black),
        label: Text(
          "NHẬP KHO",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
  Widget _buildBoutiqueHeader(BuildContext context, AsyncValue<List<dynamic>> stores, String? selectedStoreId) {
    final isMobile = Responsive.isMobile(context);
    
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quản lý kho",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (selectedStoreId != null)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => showGeneralDialog(
                          context: context,
                          pageBuilder: (ctx, _, __) => StaffInventoryHistoryScreen(storeId: selectedStoreId),
                        ),
                        icon: const Icon(Icons.history_rounded, color: AppTheme.accentGold, size: 20),
                      ),
                      IconButton(
                        onPressed: () => showGeneralDialog(
                          context: context,
                          pageBuilder: (ctx, _, __) => StaffInventoryRequestsScreen(storeId: selectedStoreId),
                        ),
                        icon: const Icon(Icons.assignment_rounded, color: AppTheme.accentGold, size: 20),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            stores.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (list) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStoreId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF141414),
                    icon: const Icon(Icons.expand_more_rounded, color: AppTheme.accentGold, size: 18),
                    hint: Text(
                      "CHỌN QUẦY",
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: Colors.white24,
                        letterSpacing: 2,
                      ),
                    ),
                    items: list.map((s) => DropdownMenuItem(
                      value: s.id as String,
                      child: Text(
                        s.name.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(selectedStoreIdProvider.notifier).state = val;
                        ref.read(inventoryProvider.notifier).loadOverview(val);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "QUẢN LÝ KHO",
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Quản lý kho",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          stores.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Row(
              children: [
                if (selectedStoreId != null) ...[
                  IconButton(
                    onPressed: () => showGeneralDialog(
                      context: context,
                      pageBuilder: (ctx, _, __) => StaffInventoryHistoryScreen(storeId: selectedStoreId),
                    ),
                    icon: const Icon(Icons.history_rounded, color: AppTheme.accentGold, size: 20),
                    tooltip: "Lịch sử kho",
                  ),
                  IconButton(
                    onPressed: () => showGeneralDialog(
                      context: context,
                      pageBuilder: (ctx, _, __) => StaffInventoryRequestsScreen(storeId: selectedStoreId),
                    ),
                    icon: const Icon(Icons.assignment_rounded, color: AppTheme.accentGold, size: 20),
                    tooltip: "Yêu cầu của tôi",
                  ),
                ],
                Text(
                  "QUẦY:",
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Colors.white38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStoreId,
                      dropdownColor: const Color(0xFF141414),
                      icon: const Icon(Icons.expand_more_rounded, color: AppTheme.accentGold, size: 18),
                      hint: Text(
                        "CHỌN QUẦY",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.white24,
                          letterSpacing: 2,
                        ),
                      ),
                      items: list.map((s) => DropdownMenuItem(
                        value: s.id as String,
                        child: Text(
                          s.name.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(selectedStoreIdProvider.notifier).state = val;
                          ref.read(inventoryProvider.notifier).loadOverview(val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDashboard(InventoryOverview overview) {
    final isMobile = Responsive.isMobile(context);
    final stats = [
      {
        'label': 'TỔNG SẢN PHẨM',
        'value': '${overview.stats.totalUnits}',
        'icon': Icons.layers_outlined,
        'isAlert': false,
      },
      {
        'label': 'TỔNG SKU',
        'value': '${overview.variants.length}',
        'icon': Icons.science_outlined,
        'isAlert': false,
      },
      {
        'label': 'SẮP HẾT HÀNG',
        'value': '${overview.stats.lowStockCount}',
        'icon': Icons.emergency_outlined,
        'isAlert': overview.stats.lowStockCount > 0,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
      child: isMobile 
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _GlassStatCard(
                      label: stats[0]['label'] as String,
                      value: stats[0]['value'] as String,
                      icon: stats[0]['icon'] as IconData,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlassStatCard(
                      label: stats[1]['label'] as String,
                      value: stats[1]['value'] as String,
                      icon: stats[1]['icon'] as IconData,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _GlassStatCard(
                label: stats[2]['label'] as String,
                value: stats[2]['value'] as String,
                icon: stats[2]['icon'] as IconData,
                isAlert: stats[2]['isAlert'] as bool,
              ),
            ],
          )
        : Row(
            children: stats.map((s) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: s != stats.last ? 24 : 0),
                child: _GlassStatCard(
                  label: s['label'] as String,
                  value: s['value'] as String,
                  icon: s['icon'] as IconData,
                  isAlert: s['isAlert'] as bool,
                ),
              ),
            )).toList(),
          ),
    );
  }

  Widget _buildRefinedSearchBar() {
    final isMobile = Responsive.isMobile(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 32, isMobile ? 8 : 24, isMobile ? 20 : 32, isMobile ? 12 : 24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.2), width: 0.5),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: isMobile ? "Tìm kiếm..." : "Tìm tên sản phẩm, SKU, nhóm mùi hương, thương hiệu",
                  hintStyle: GoogleFonts.montserrat(color: Colors.white60, fontSize: 11, letterSpacing: 0.5),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumInventoryTable(InventoryState state, String? storeId) {
    if (storeId == null) return _buildBoutiqueHint();
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
    
    final overview = state.overview;
    if (overview == null) {
      if (state.error != null) {
        return AppErrorWidget(
          message: state.error!,
          onRetry: () => ref.read(inventoryProvider.notifier).loadOverview(storeId),
        );
      }
      return const SizedBox.shrink();
    }

    var variants = overview.variants;
    if (_searchQuery.isNotEmpty) {
      variants = variants.where((v) {
        return v.name.toLowerCase().contains(_searchQuery) ||
               v.variantName.toLowerCase().contains(_searchQuery) ||
               (v.brand?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    final isMobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 32, 0, isMobile ? 20 : 32, 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            // Header Row
            if (!Responsive.isMobile(context)) ...[
              Container(
                color: const Color(0xFF0F0F0F),
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _TableHeaderText("CHI TIẾT BỘ SƯU TẬP", flex: 4),
                    _TableHeaderText("MÃ SKU / ĐƠN VỊ", flex: 2),
                    _TableHeaderText("TRẠNG THÁI", flex: 2),
                    _TableHeaderText("THAO TÁC", flex: 1),
                  ],
                ),
              ),
              const Divider(color: AppTheme.accentGold, height: 1, thickness: 0.5),
            ],
            
            // List of items
            ...variants.map((v) => _InventoryRow(variant: v, onAdjust: () => _showAdjustSheet(context, v))),
          ],
        ),
      ),
    );
  }

  Widget _buildBoutiqueHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white10, size: 60),
          const SizedBox(height: 24),
          Text("VUI LÒNG CHỌN QUẦY ĐỂ BẮT ĐẦU KIỂM KHO", style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white60, letterSpacing: 4)),
        ],
      ),
    );
  }

  void _showAdjustSheet(BuildContext context, InventoryVariant variant) {
    showDialog(
      context: context,
      builder: (ctx) => TabletInventoryAdjustDialog(
        variant: variant,
        onSubmit: (delta, reason) async {
          final storeId = ref.read(selectedStoreIdProvider);
          if (storeId == null) return;
          Navigator.of(ctx).pop();
          await ref.read(inventoryProvider.notifier).adjustStock(
            storeId: storeId,
            variantId: variant.id,
            delta: delta,
            reason: reason,
          );
          ref.invalidate(myInventoryRequestsProvider);
        },
      ),
    );
  }
}

class _GlassStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isAlert;
  const _GlassStatCard({required this.label, required this.value, required this.icon, this.isAlert = false});

  @override
  State<_GlassStatCard> createState() => _GlassStatCardState();
}

class _GlassStatCardState extends State<_GlassStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: _PulsingAlertWrapper(
          isAlert: widget.isAlert,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            transform: Matrix4.identity()..translate(0.0, _isHovered ? -3.0 : 0.0),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isAlert
                    ? Colors.redAccent.withOpacity(_isHovered ? 0.6 : 0.4)
                    : _isHovered
                        ? AppTheme.accentGold.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: (widget.isAlert ? Colors.redAccent : AppTheme.accentGold).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: widget.isAlert ? Colors.redAccent : AppTheme.accentGold, size: isMobile ? 14 : 18),
                    const Spacer(),
                    Text(widget.label, style: GoogleFonts.montserrat(fontSize: isMobile ? 8 : 9, color: Colors.white54, fontWeight: FontWeight.w800, letterSpacing: isMobile ? 1 : 2)),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 16),
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.getGoldGradient().createShader(bounds),
                  child: Text(
                    widget.value,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    
    return content;
  }
}

class _PulsingAlertWrapper extends StatefulWidget {
  final Widget child;
  final bool isAlert;
  const _PulsingAlertWrapper({required this.child, required this.isAlert});
  @override
  State<_PulsingAlertWrapper> createState() => _PulsingAlertWrapperState();
}

class _PulsingAlertWrapperState extends State<_PulsingAlertWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!widget.isAlert) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.1 * _ctrl.value),
              blurRadius: 10 + (10 * _ctrl.value),
              spreadRadius: 2,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  final int flex;
  const _TableHeaderText(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }
}

class _InventoryRow extends StatefulWidget {
  final InventoryVariant variant;
  final VoidCallback onAdjust;
  const _InventoryRow({required this.variant, required this.onAdjust});

  @override
  State<_InventoryRow> createState() => _InventoryRowState();
}

class _InventoryRowState extends State<_InventoryRow> {
  bool _isHovered = false;

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${EnvConfig.apiBaseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final isLow = widget.variant.stock < 10;
    final imageUrl = _normalizeImageUrl(widget.variant.imageUrl);
    final isMobile = Responsive.isMobile(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onAdjust,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 20),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.03) : Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: isMobile 
            ? Column(
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _isHovered ? AppTheme.accentGold.withOpacity(0.3) : Colors.transparent,
                          ),
                          image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                        ),
                        child: imageUrl.isEmpty ? const Icon(Icons.science_outlined, color: Colors.white12, size: 16) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.variant.name.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: _isHovered ? Colors.white : Colors.white.withOpacity(0.9), letterSpacing: 1)),
                            Text("${widget.variant.brand?.toUpperCase() ?? 'GENERIC'}", style: GoogleFonts.montserrat(fontSize: 9, color: AppTheme.accentGold, letterSpacing: 1.5)),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_outlined, color: AppTheme.accentGold, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SKU: ${widget.variant.id.substring(0,8)}".toUpperCase(),
                            style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white38),
                          ),
                          if (widget.variant.barcode != null)
                            Text(
                              "BARCODE: ${widget.variant.barcode}",
                              style: GoogleFonts.robotoMono(fontSize: 10, color: AppTheme.accentGold.withOpacity(0.5), fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, size: 10, color: isLow ? Colors.redAccent : Colors.greenAccent),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.variant.stock} ĐƠN VỊ",
                            style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.bold, color: isLow ? Colors.redAccent : Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _isHovered ? AppTheme.accentGold.withOpacity(0.3) : Colors.transparent,
                            ),
                            image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                          ),
                          child: imageUrl.isEmpty ? const Icon(Icons.science_outlined, color: Colors.white12, size: 18) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.variant.name.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: _isHovered ? Colors.white : Colors.white.withOpacity(0.9), letterSpacing: 1)),
                              Text("${widget.variant.brand?.toUpperCase() ?? 'GENERIC'}", style: GoogleFonts.montserrat(fontSize: 9, color: AppTheme.accentGold, letterSpacing: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SKU: ${widget.variant.id.substring(0,8)}".toUpperCase(),
                          style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white38),
                        ),
                        if (widget.variant.barcode != null)
                          Text(
                            "BC: ${widget.variant.barcode}",
                            style: GoogleFonts.robotoMono(fontSize: 10, color: AppTheme.accentGold.withOpacity(0.5), fontWeight: FontWeight.bold),
                          ),
                        Text(
                          "${widget.variant.variantName} UNIT",
                          style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, size: 12, color: isLow ? Colors.redAccent : Colors.greenAccent),
                        const SizedBox(width: 8),
                        Text(
                          "${widget.variant.stock} ĐƠN VỊ",
                          style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.bold, color: isLow ? Colors.redAccent : Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(_isHovered ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit_outlined, size: 16, color: _isHovered ? AppTheme.accentGold : AppTheme.accentGold.withOpacity(0.7)),
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
