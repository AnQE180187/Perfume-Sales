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

class StaffReturnsScreen extends ConsumerWidget {
  const StaffReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final returnsAsync = ref.watch(staffReturnsProvider);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reverseLogistics,
                      style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.w800, letterSpacing: 4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Quản lý Đổi trả",
                      style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                _DateFilterButton(),
              ],
            ),
            const SizedBox(height: 32),
            _buildTableHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: returnsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                error: (e, _) => AppErrorWidget(
                  message: l10n.unableLoadData,
                  onRetry: () => ref.read(staffReturnsProvider.notifier).loadReturns(),
                ),
                data: (list) {
                  final storeId = ref.watch(posSelectedStoreIdProvider);
                  final range = ref.watch(returnsDateRangeProvider);
                  final posReturnsToday = list.where((item) {
                    try {
                      if (item['origin'] != 'POS') return false;
                      if (item['order']?['storeId'] != storeId) return false;
                      
                      if (range == null) {
                        // Default to today if no range selected
                        final createdAt = DateTime.parse(item['createdAt']).toLocal();
                        final now = DateTime.now();
                        return createdAt.year == now.year &&
                            createdAt.month == now.month &&
                            createdAt.day == now.day;
                      }
                      
                      final createdAt = DateTime.parse(item['createdAt']).toLocal();
                      // Compare with range (inclusive of the whole start and end days)
                      final start = DateTime(range.start.year, range.start.month, range.start.day);
                      final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
                      return createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
                             createdAt.isBefore(end.add(const Duration(seconds: 1)));
                    } catch (_) {
                      return false;
                    }
                  }).toList();

                  if (posReturnsToday.isEmpty) {
                    return Center(
                      child: Text(
                          range == null
                              ? "Không tìm thấy yêu cầu trả hàng nào hôm nay tại quầy"
                              : "Không tìm thấy yêu cầu trả hàng trong khoảng thời gian đã chọn",
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.white38,
                              letterSpacing: 2)),
                    );
                  }
                  return ListView.builder(
                    itemCount: posReturnsToday.length,
                    itemBuilder: (ctx, i) => GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (ctx) => TabletReturnDetailsDialog(
                            returnId: posReturnsToday[i]['id']),
                      ),
                      child: _ReturnCard(
                        data: posReturnsToday[i],
                        dateFmt: dateFmt,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("Nguồn", style: _headerStyle())),
          Expanded(flex: 2, child: Text("Mã Yêu Cầu", style: _headerStyle())),
          Expanded(flex: 2, child: Text("Mã Đơn", style: _headerStyle())),
          Expanded(flex: 2, child: Text("Ngày tạo", style: _headerStyle())),
          Expanded(flex: 3, child: Text("Lý do", style: _headerStyle())),
          Expanded(flex: 2, child: Text("Trạng thái", style: _headerStyle())),
          SizedBox(width: 48, child: Text("Hành động", style: _headerStyle(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white54);
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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF151515) : const Color(0xFF0F0F0F),
          border: Border.all(
            color: _isHovered ? AppTheme.accentGold.withOpacity(0.3) : Colors.white10,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(flex: 1, child: _buildOriginBadge(origin)),
            Expanded(flex: 2, child: Text((widget.data['id']?.toString() ?? '').substring(0, (widget.data['id']?.toString().length ?? 0) > 8 ? 8 : (widget.data['id']?.toString().length ?? 0)).toUpperCase(), style: GoogleFonts.robotoMono(fontSize: 12, color: _isHovered ? AppTheme.accentGold : Colors.white70))),
            Expanded(flex: 2, child: Text((widget.data['orderId']?.toString() ?? '').substring(0, (widget.data['orderId']?.toString().length ?? 0) > 8 ? 8 : (widget.data['orderId']?.toString().length ?? 0)).toUpperCase(), style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white70))),
            Expanded(flex: 2, child: Text(widget.dateFmt.format(DateTime.parse(widget.data['createdAt']).toLocal()), style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70))),
            Expanded(flex: 3, child: Text(reason.isEmpty ? "Không có lý do" : reason, style: GoogleFonts.montserrat(fontSize: 12, color: reason.isEmpty ? Colors.white38 : Colors.white70, fontStyle: reason.isEmpty ? FontStyle.italic : FontStyle.normal), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _StatusBadge(status: status))),
            SizedBox(
              width: 48,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.search_rounded, size: 20, color: _isHovered ? AppTheme.accentGold.withOpacity(0.8) : Colors.white38),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPos ? Colors.redAccent.withOpacity(0.1) : Colors.cyanAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isPos ? Colors.redAccent.withOpacity(0.3) : Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPos ? Icons.store_rounded : Icons.public_rounded, size: 10, color: isPos ? Colors.redAccent.shade100 : Colors.cyanAccent.shade100),
          const SizedBox(width: 4),
          Text(isPos ? "POS" : "Online", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: isPos ? Colors.redAccent.shade100 : Colors.cyanAccent.shade100)),
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
      case "APPROVED": return "Đã duyệt, đợi trả";
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
                    ? "${DateFormat('dd/MM').format(range.start)}${range.start.day == range.end.day ? '' : ' - ${DateFormat('dd/MM').format(range.end)}'}"
                    : "Lọc theo ngày",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
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
