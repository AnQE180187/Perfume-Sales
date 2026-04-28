import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../pos/providers/pos_provider.dart';
import '../providers/returns_provider.dart';
import '../../tablet/presentation/tablet_return_details_dialog.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';

class StaffReturnsScreen extends ConsumerWidget {
  const StaffReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final returnsAsync = ref.watch(staffReturnsProvider);
    final dateFmt = DateFormat('dd/MM/yyyy');

    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "HOÀN TRẢ",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isMobile ? 22 : 32, 
                              fontWeight: FontWeight.w800, 
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white24, size: 20),
                            onPressed: () {
                              ref.read(staffReturnsProvider.notifier).loadReturns();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Theo dõi và quản lý yêu cầu đổi trả hàng",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _DateFilterButton(),
              ],
            ),
            SizedBox(height: isMobile ? 20 : 32),
            if (!isMobile) ...[
              _buildTableHeader(),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.accentGold,
                backgroundColor: const Color(0xFF1A1A1A),
                onRefresh: () async {
                  await ref.read(staffReturnsProvider.notifier).loadReturns();
                },
                child: returnsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                  error: (e, _) => AppErrorWidget(
                    message: l10n.unableLoadData,
                    onRetry: () => ref.read(staffReturnsProvider.notifier).loadReturns(),
                  ),
                  data: (list) {
                    final storeId = ref.watch(posSelectedStoreIdProvider);
                    final range = ref.watch(returnsDateRangeProvider);
                    final statusFilter = ref.watch(returnStatusFilterProvider);
                    final posReturns = list.where((item) {
                      try {
                        // 1. Filter by store
                        if (storeId != null && item['order']?['storeId'] != storeId) return false;
                        
                        // 2. Filter by status
                        if (statusFilter != 'ALL' && item['status'] != statusFilter) return false;

                        // 3. Filter by date
                        if (range == null) {
                          final createdAt = DateTime.parse(item['createdAt']).toLocal();
                          final now = DateTime.now();
                          bool isToday = createdAt.year == now.year &&
                              createdAt.month == now.month &&
                              createdAt.day == now.day;
                          
                          final status = item['status'] as String;
                          final isPending = status != 'COMPLETED' && status != 'CANCELLED';
                          
                          if (isPending) return true;
                          return isToday;
                        }
                        
                        final createdAt = DateTime.parse(item['createdAt']).toLocal();
                        final start = DateTime(range.start.year, range.start.month, range.start.day);
                        final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
                        return createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
                                createdAt.isBefore(end.add(const Duration(seconds: 1)));
                      } catch (_) {
                        return false;
                      }
                    }).toList();

                    // Calculate summary
                    final totalAmount = posReturns.fold<double>(0, (sum, item) => sum + (item['totalAmount'] ?? 0));
                    final pendingCount = posReturns.where((item) => item['status'] == 'REQUESTED').length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusFilterChips(),
                        const SizedBox(height: 16),
                        if (isMobile) 
                          _buildMobileSummary(totalAmount, posReturns.length, pendingCount)
                        else 
                          _buildSummaryBar(totalAmount, posReturns.length, pendingCount),
                        
                        if (!isMobile) const SizedBox(height: 24),
                        if (isMobile) const SizedBox(height: 12),
                        
                        if (posReturns.isEmpty)
                          Expanded(
                            child: ListView(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  child: Center(
                                    child: Text(
                                        "Không tìm thấy yêu cầu trả hàng phù hợp",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            color: Colors.white38,
                                            letterSpacing: 2)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.only(bottom: 40),
                              itemCount: posReturns.length,
                              itemBuilder: (ctx, i) => GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (ctx) => TabletReturnDetailsDialog(
                                      returnId: posReturns[i]['id']),
                                ),
                                child: _ReturnCard(
                                  data: posReturns[i],
                                  dateFmt: dateFmt,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSummary(double totalAmount, int totalCount, int pendingCount) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Expanded(
                child: _MobileSummaryItem(
                  label: "TỔNG HOÀN",
                  value: "${NumberFormat('#,###', 'vi_VN').format(totalAmount)}đ",
                  isGold: true,
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white10),
              Expanded(
                child: _MobileSummaryItem(
                  label: "ĐƠN HÀNG",
                  value: "$totalCount",
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white10),
              Expanded(
                child: _MobileSummaryItem(
                  label: "CHỜ XỬ LÝ",
                  value: "$pendingCount",
                  isAlert: pendingCount > 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(double totalAmount, int totalCount, int pendingCount) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
              _SummaryItem(label: "TỔNG HOÀN TIỀN", value: "${NumberFormat('#,###', 'vi_VN').format(totalAmount)}đ", isGold: true),
              _buildVerticalDivider(),
              _SummaryItem(label: "SỐ LƯỢNG ĐƠN", value: "$totalCount"),
              _buildVerticalDivider(),
              _SummaryItem(label: "CHỜ XỬ LÝ", value: "$pendingCount", isAlert: pendingCount > 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() => Container(width: 1, height: 30, color: Colors.white.withOpacity(0.05));

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("NGUỒN", style: _headerStyle())),
          Expanded(flex: 2, child: Text("MÃ YÊU CẦU", style: _headerStyle())),
          Expanded(flex: 2, child: Text("MÃ ĐƠN", style: _headerStyle())),
          Expanded(flex: 2, child: Text("NGÀY TẠO", style: _headerStyle())),
          Expanded(flex: 2, child: Text("SỐ TIỀN", style: _headerStyle())),
          Expanded(flex: 3, child: Text("LÝ DO", style: _headerStyle())),
          Expanded(flex: 2, child: Text("TRẠNG THÁI", style: _headerStyle())),
          SizedBox(width: 48, child: Text("HÀNH ĐỘNG", style: _headerStyle(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 1);
  }
}

class _StatusFilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStatus = ref.watch(returnStatusFilterProvider);
    final statuses = [
      {'id': 'ALL', 'label': 'Tất cả'},
      {'id': 'REQUESTED', 'label': 'Chờ duyệt'},
      {'id': 'APPROVED', 'label': 'Đã duyệt'},
      {'id': 'RECEIVED', 'label': 'Đã nhận'},
      {'id': 'REFUNDED', 'label': 'Đã hoàn tiền'},
      {'id': 'COMPLETED', 'label': 'Hoàn tất'},
      {'id': 'CANCELLED', 'label': 'Đã hủy'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: statuses.map((status) {
          final isSelected = currentStatus == status['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                status['label']!.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(returnStatusFilterProvider.notifier).state = status['id']!;
                }
              },
              backgroundColor: Colors.transparent,
              selectedColor: AppTheme.accentGold,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              selectedShadowColor: Colors.transparent,
              elevation: 0,
              pressElevation: 0,
              side: BorderSide(
                color: isSelected ? AppTheme.accentGold : Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MobileSummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;
  final bool isAlert;

  const _MobileSummaryItem({
    required this.label,
    required this.value,
    this.isGold = false,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 8,
            color: Colors.white38,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isGold
                ? AppTheme.accentGold
                : (isAlert ? Colors.orangeAccent : Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;
  final bool isAlert;
  const _SummaryItem({required this.label, required this.value, this.isGold = false, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(
          value, 
          style: GoogleFonts.robotoMono(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: isGold ? AppTheme.accentGold : (isAlert ? Colors.orangeAccent : Colors.white70)
          )
        ),
      ],
    );
  }
}


class _ReturnCard extends StatefulWidget {
  final dynamic data;
  final DateFormat dateFmt;

  const _ReturnCard({required this.data, required this.dateFmt});

  @override
  State<_ReturnCard> createState() => _ReturnCardState();
}

class _ReturnCardState extends State<_ReturnCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final status = (widget.data['status'] as String?) ?? 'REQUESTED';
    final origin = (widget.data['origin'] as String?) ?? 'ONLINE';
    final reason = (widget.data['reason'] as String?) ?? '';
    final amount = (widget.data['totalAmount'] as num?) ?? 0;

    final isMobile = Responsive.isMobile(context);
    final currencyFmt = NumberFormat('#,###', 'vi_VN');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: _isHovered ? AppTheme.accentGold.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.05),
              blurRadius: 15,
              spreadRadius: -5,
            )
          ] : null,
        ),
        child: isMobile 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildOriginBadge(origin),
                    const SizedBox(width: 12),
                    Text(
                      "#${(widget.data['id']?.toString() ?? '').substring(0, 8).toUpperCase()}",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14, 
                        fontWeight: FontWeight.w800, 
                        color: AppTheme.accentGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mã Đơn: ${(widget.data['orderId']?.toString() ?? '').substring(0, 8).toUpperCase()}", style: GoogleFonts.robotoMono(fontSize: 11, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(widget.dateFmt.format(DateTime.parse(widget.data['createdAt']).toLocal()), style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white24)),
                      ],
                    ),
                    Text("${currencyFmt.format(amount)}đ", style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(reason, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white54, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(flex: 1, child: _buildOriginBadge(origin)),
                Expanded(
                  flex: 2, 
                  child: Text(
                    (widget.data['id']?.toString() ?? '').substring(0, (widget.data['id']?.toString().length ?? 0) > 8 ? 8 : (widget.data['id']?.toString().length ?? 0)).toUpperCase(), 
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13, 
                      fontWeight: FontWeight.w800, 
                      color: _isHovered ? AppTheme.accentGold : Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2, 
                  child: Text(
                    (widget.data['orderId']?.toString() ?? '').substring(0, (widget.data['orderId']?.toString().length ?? 0) > 8 ? 8 : (widget.data['orderId']?.toString().length ?? 0)).toUpperCase(), 
                    style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white38),
                  ),
                ),
                Expanded(flex: 2, child: Text(widget.dateFmt.format(DateTime.parse(widget.data['createdAt']).toLocal()), style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white54))),
                Expanded(flex: 2, child: Text("${currencyFmt.format(amount)}đ", style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 3, child: Text(reason.isEmpty ? "Không có lý do" : reason, style: GoogleFonts.montserrat(fontSize: 12, color: reason.isEmpty ? Colors.white24 : Colors.white70, fontStyle: reason.isEmpty ? FontStyle.italic : FontStyle.normal), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _StatusBadge(status: status))),
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Icon(Icons.chevron_right_rounded, size: 20, color: _isHovered ? AppTheme.accentGold : Colors.white10),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildOriginBadge(String origin) {
    bool isPos = origin == 'POS';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPos ? Colors.redAccent.withOpacity(0.05) : Colors.cyanAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isPos ? Colors.redAccent.withOpacity(0.2) : Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPos ? Icons.store_rounded : Icons.public_rounded, size: 10, color: isPos ? Colors.redAccent.shade100 : Colors.cyanAccent.shade100),
          const SizedBox(width: 4),
          Text(isPos ? "POS" : "Online", style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w800, color: isPos ? Colors.redAccent.shade100 : Colors.cyanAccent.shade100, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  String get localized {
    switch (status) {
      case "REQUESTED": return "Yêu cầu mới";
      case "AWAITING_CUSTOMER": return "Chờ phản hồi khách";
      case "REVIEWING": return "Đang xem xét";
      case "APPROVED": return "Đã duyệt";
      case "RETURNING": return "Đang gửi hàng";
      case "RECEIVED": return "Đã nhận hàng";
      case "REFUNDING": return "Đang hoàn tiền";
      case "REFUND_FAILED": return "Hoàn tiền lỗi";
      case "COMPLETED": return "Hoàn tất";
      case "REJECTED": return "Đã từ chối";
      case "REJECTED_AFTER_RETURN": return "Từ chối sau nhận";
      case "CANCELLED": return "Đã huỷ";
      default: return status;
    }
  }

  MaterialColor get color {
    switch (status) {
      case "REQUESTED": return Colors.blue;
      case "REVIEWING": return Colors.purple;
      case "APPROVED": return Colors.green;
      case "RETURNING": return Colors.amber;
      case "RECEIVED": return Colors.teal;
      case "COMPLETED": return Colors.lightGreen;
      case "REFUNDING": return Colors.indigo;
      case "REJECTED":
      case "REJECTED_AFTER_RETURN":
      case "CANCELLED":
      case "REFUND_FAILED":
        return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        localized,
        style: GoogleFonts.montserrat(fontSize: 10, color: color.shade300, fontWeight: FontWeight.w600),
      ),
    );
  }
}
class _DateFilterButton extends ConsumerWidget {
  void _applyRange(WidgetRef ref, DateTimeRange range) {
    ref.read(returnsDateRangeProvider.notifier).state = range;
    ref.read(staffReturnsProvider.notifier).loadReturns(
          status: ref.read(returnStatusFilterProvider),
          startDate: range.start.toUtc().toIso8601String(),
          endDate: range.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toUtc().toIso8601String(),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(returnsDateRangeProvider);
    final hasRange = range != null;

    return Theme(
      data: ThemeData.dark(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: hasRange ? AppTheme.accentGold.withOpacity(0.1) : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasRange ? AppTheme.accentGold.withOpacity(0.3) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            if (hasRange)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.accentGold),
                onPressed: () {
                  ref.read(returnsDateRangeProvider.notifier).state = null;
                  ref.read(staffReturnsProvider.notifier).loadReturns(
                        status: ref.read(returnStatusFilterProvider),
                      );
                },
                tooltip: "Xoá lọc ngày",
              ),
            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => _DateFilterSheet(
                    currentRange: range,
                    onSelect: (r) {
                      Navigator.pop(ctx);
                      _applyRange(ref, r);
                    },
                    onCustomRange: () async {
                      Navigator.pop(ctx);
                      final newRange = await showDateRangePicker(
                        context: context,
                        initialDateRange: range,
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
                        _applyRange(ref, newRange);
                      }
                    },
                  ),
                );
              },
              icon: Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: hasRange ? AppTheme.accentGold : Colors.white24,
              ),
              label: Text(
                hasRange
                    ? "${DateFormat('dd/MM').format(range.start)}${range.start.day == range.end.day ? '' : '-${DateFormat('dd/MM').format(range.end)}'}"
                    : "Lọc",
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: hasRange ? AppTheme.accentGold : Colors.white24,
                  fontWeight: hasRange ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
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
