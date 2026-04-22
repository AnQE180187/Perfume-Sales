import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../models/daily_report.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/config/env.dart';
import '../../pos/providers/pos_provider.dart';
import '../../../../core/utils/responsive.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(dashboardProvider);
    final selectedStoreId = ref.watch(posSelectedStoreIdProvider);
    final storesAsync = ref.watch(posStoresProvider);
    final currencyFmt = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: RefreshIndicator(
        color: AppTheme.accentGold,
        onRefresh: () => ref.read(dashboardProvider.notifier).loadReport(storeId: selectedStoreId),
        child: CustomScrollView(
          slivers: [
            // Luxury Header
            SliverToBoxAdapter(
              child: _buildObsidianHeader(context, ref, state, storesAsync, selectedStoreId, l10n),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (state.report != null) ...[
                    // Primary Chart: Sales Trends
                    _buildDynamicSalesChart(state.report!),
                    const SizedBox(height: 32),
                    
                    // KPI Grid
                    _buildHighPerformanceKpis(context, state.report!, currencyFmt, l10n),
                    const SizedBox(height: 32),
                    
                    // Top Products Table
                    _buildScientificProductBoard(state.report!, currencyFmt, l10n),
                  ] else if (state.isLoading) 
                    const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator(color: AppTheme.accentGold)))
                  else if (state.error != null)
                    AppErrorWidget(
                      message: state.error!,
                      onRetry: () => ref.read(dashboardProvider.notifier).loadReport(storeId: selectedStoreId),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObsidianHeader(BuildContext context, WidgetRef ref, DashboardState state, AsyncValue<List<dynamic>> stores, String? selectedStoreId, AppLocalizations l10n) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 32 : 48, isMobile ? 16 : 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.analyticsCommand,
                      style: GoogleFonts.montserrat(fontSize: 9, color: AppTheme.accentGold, fontWeight: FontWeight.w800, letterSpacing: isMobile ? 2 : 4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "QUẢN LÝ DOANH THU",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isMobile ? 18 : 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: isMobile ? 0.5 : 2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              _DateFilter(date: state.selectedDate),
            ],
          ),
          const SizedBox(height: 24),
          stores.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStoreId,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF141414),
                        hint: Text(l10n.allAteliers, style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
                        icon: const Icon(Icons.expand_more_rounded, color: AppTheme.accentGold, size: 16),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(l10n.globalNetwork, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white60, letterSpacing: 2)),
                          ),
                          ...list.map((s) => DropdownMenuItem(
                            value: s.id as String,
                            child: Text(s.name.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white60, letterSpacing: 2)),
                          )),
                        ],
                        onChanged: (val) {
                          ref.read(posSelectedStoreIdProvider.notifier).state = val;
                          ref.read(dashboardProvider.notifier).loadReport(storeId: val);
                        },
                      ),
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

  Widget _buildDynamicSalesChart(DailyReport report) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SALES TRENDS / METALLIC FLUX", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.03), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text("${v.toInt()}H", style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white54)))),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppTheme.accentGold,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppTheme.accentGold.withOpacity(0.2), AppTheme.accentGold.withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: report.hourlySales.map((h) => FlSpot(h.hour.toDouble(), h.revenue / 1000000)).toList(), 
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighPerformanceKpis(BuildContext context, DailyReport report, NumberFormat fmt, AppLocalizations l10n) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _ObsidianKpi(label: l10n.grossRevenue, value: "${fmt.format(report.totalRevenue)}đ", icon: Icons.insights_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _ObsidianKpi(label: l10n.transCount, value: "${report.totalOrders}", icon: Icons.shutter_speed_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ObsidianKpi(label: l10n.aovEfficiency, value: "${fmt.format(report.avgOrderValue)}đ", icon: Icons.precision_manufacturing_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _ObsidianKpi(label: l10n.conversionRate, value: "${report.completionRate.toStringAsFixed(1)}%", icon: Icons.troubleshoot_rounded, isGold: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ObsidianKpi(label: l10n.cancelRate, value: "${report.cancelRate.toStringAsFixed(1)}%", icon: Icons.cancel_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _ObsidianKpi(label: l10n.refundVolume, value: "${fmt.format(report.totalRefundedAmount)}đ", icon: Icons.replay_circle_filled_rounded)),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ObsidianKpi(label: l10n.grossRevenue, value: "${fmt.format(report.totalRevenue)}đ", icon: Icons.insights_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _ObsidianKpi(label: l10n.transCount, value: "${report.totalOrders}", icon: Icons.shutter_speed_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _ObsidianKpi(label: l10n.aovEfficiency, value: "${fmt.format(report.avgOrderValue)}đ", icon: Icons.precision_manufacturing_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _ObsidianKpi(label: l10n.conversionRate, value: "${report.completionRate.toStringAsFixed(1)}%", icon: Icons.troubleshoot_rounded, isGold: true)),
            const SizedBox(width: 16),
            Expanded(child: _ObsidianKpi(label: l10n.cancelRate, value: "${report.cancelRate.toStringAsFixed(1)}%", icon: Icons.cancel_outlined)),
            const SizedBox(width: 16),
            Expanded(child: _ObsidianKpi(label: l10n.refundVolume, value: "${fmt.format(report.totalRefundedAmount)}đ", icon: Icons.replay_circle_filled_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildScientificProductBoard(DailyReport report, NumberFormat fmt, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.topPerformanceCollection, style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
          child: Column(
            children: report.topProducts.asMap().entries.map((entry) => _HoverableProductRow(
              index: entry.key,
              product: entry.value,
              fmt: fmt,
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _ObsidianKpi extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isGold;
  const _ObsidianKpi({required this.label, required this.value, required this.icon, this.isGold = false});

  @override
  State<_ObsidianKpi> createState() => _ObsidianKpiState();
}

class _ObsidianKpiState extends State<_ObsidianKpi> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -2.0 : 0.0),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF141414) : const Color(0xFF0F0F0F),
          border: Border.all(
            color: _isHovered
                ? AppTheme.accentGold.withOpacity(0.4)
                : (widget.isGold ? AppTheme.accentGold.withOpacity(0.3) : Colors.white10),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: widget.isGold ? AppTheme.accentGold : AppTheme.accentGold.withOpacity(_isHovered ? 0.8 : 0.5), size: 18),
            const SizedBox(height: 20),
            Text(widget.label, style: GoogleFonts.montserrat(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(widget.value, style: GoogleFonts.robotoMono(fontSize: 15, color: widget.isGold ? AppTheme.accentGold : Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _HoverableProductRow extends StatefulWidget {
  final int index;
  final dynamic product;
  final NumberFormat fmt;
  const _HoverableProductRow({required this.index, required this.product, required this.fmt});

  @override
  State<_HoverableProductRow> createState() => _HoverableProductRowState();
}

class _HoverableProductRowState extends State<_HoverableProductRow> {
  bool _isHovered = false;

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Prepend host for relative paths
    return '${EnvConfig.apiBaseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final imageUrl = _normalizeImageUrl(p.imageUrl as String?);

    final isMobile = Responsive.isMobile(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white.withOpacity(0.03) : Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Text("0${widget.index + 1}", style: GoogleFonts.robotoMono(fontSize: 10, color: AppTheme.accentGold)),
            SizedBox(width: isMobile ? 12 : 24),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(2),
                image: imageUrl.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) 
                  : null,
              ),
              child: imageUrl.isEmpty ? const Icon(Icons.science_outlined, color: Colors.white24, size: 14) : null,
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.productName.toUpperCase(), style: GoogleFonts.montserrat(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.bold, color: _isHovered ? Colors.white : Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(p.variantName, style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white60)),
              ],
            )),
            const SizedBox(width: 8),
            Text("x${p.totalQuantity}", style: GoogleFonts.robotoMono(fontSize: isMobile ? 11 : 12, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: isMobile ? 12 : 40),
            Text("${widget.fmt.format(p.totalRevenue)}đ", style: GoogleFonts.robotoMono(fontSize: isMobile ? 10 : 11, color: AppTheme.accentGold)),
          ],
        ),
      ),
    );
  }
}

class _DateFilter extends StatefulWidget {
  final DateTime date;
  const _DateFilter({required this.date});

  @override
  State<_DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<_DateFilter> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 8 : 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white.withOpacity(0.03) : const Color(0xFF141414),
          border: Border.all(color: _isHovered ? AppTheme.accentGold.withOpacity(0.5) : AppTheme.accentGold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.accentGold),
            const SizedBox(width: 12),
            Text(DateFormat('dd / MM / yyyy').format(widget.date), style: GoogleFonts.robotoMono(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
