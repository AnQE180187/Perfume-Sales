import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/env.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../returns/providers/returns_provider.dart';
import 'tablet_return_receive_dialog.dart';
import 'tablet_return_refund_dialog.dart';

class TabletReturnDetailsDialog extends ConsumerStatefulWidget {
  final String returnId;
  const TabletReturnDetailsDialog({super.key, required this.returnId});

  @override
  ConsumerState<TabletReturnDetailsDialog> createState() => _TabletReturnDetailsDialogState();
}

class _TabletReturnDetailsDialogState extends ConsumerState<TabletReturnDetailsDialog> {
  final _currencyFmt = NumberFormat('#,###', 'vi_VN');
  final _dateFmt = DateFormat('dd/MM HH:mm');

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(returnDetailsProvider(widget.returnId));
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 100, 
        vertical: isMobile ? 32 : 50,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: isMobile ? double.infinity : 950,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withOpacity(0.85),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(isMobile ? 24 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
          ),
          child: Column(
            children: [
              _buildHeader(isMobile),
              Expanded(
                child: detailsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                  error: (e, _) => AppErrorWidget(
                    message: "Lỗi tải chi tiết yêu cầu.",
                    onRetry: () => ref.refresh(returnDetailsProvider(widget.returnId)),
                  ),
                  data: (data) => _buildBody(data, isMobile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 40, 
        vertical: isMobile ? 24 : 36,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                HapticFeedback.mediumImpact();
                // Force a hard refresh of the details
                await ref.refresh(returnDetailsProvider(widget.returnId).future);
                // Also trigger a refresh for the background list
                ref.read(staffReturnsProvider.notifier).loadReturns();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.refresh_rounded, color: AppTheme.accentGold, size: isMobile ? 24 : 28),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 16 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CHI TIẾT YÊU CẦU",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isMobile ? 20 : 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  "MÃ TRUY XUẤT HỆ THỐNG",
                  style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white38, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data, bool isMobile) {
    final status = data['status'] as String;
    final items = data['items'] as List;
    final audits = data['audits'] as List;

    if (isMobile) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInfoSection(data, status, isMobile),
            const SizedBox(height: 32),
            _buildActionPanel(data, isMobile),
            const SizedBox(height: 48),
            _buildItemsList(items),
            const SizedBox(height: 48),
            _buildAuditTrail(audits),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(40, 40, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(data, status, isMobile),
                const SizedBox(height: 48),
                _buildItemsList(items),
                const SizedBox(height: 48),
                _buildAuditTrail(audits),
              ],
            ),
          ),
        ),
        
        const VerticalDivider(color: Colors.white10, width: 1),

        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(40),
            color: Colors.white.withOpacity(0.01),
            child: _buildActionPanel(data, isMobile),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data, String status, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _InfoTile(label: "MÃ YÊU CẦU", value: "#${data['id'].toString().substring(0, 8).toUpperCase()}", isGold: true)),
            const SizedBox(width: 24),
            Expanded(child: _InfoTile(label: "MÃ ĐƠN HÀNG", value: "#${data['orderId'].toString().substring(0, 8).toUpperCase()}")),
          ],
        ),
        const SizedBox(height: 32),
        _InfoTile(label: "LÝ DO ĐỔI TRẢ", value: data['reason']?.toUpperCase() ?? "KHÔNG CÓ LÝ DO CỤ THỂ", isLarge: true),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _InfoTile(label: "KHÁCH HÀNG", value: data['user']?['fullName'] ?? "KHÁCH LẺ")),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TRẠNG THÁI",
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      color: Colors.white38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StatusBadge(status: status),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsList(List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("DANH SÁCH SẢN PHẨM", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
          ],
        ),
        const SizedBox(height: 24),
        ...items.map((item) {
          final v = item['variant'];
          final p = v?['product'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildProductImage(p?['images']?[0]?['url']),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p?['name']?.toUpperCase() ?? "UNKNOWN", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text("${v?['name']} | SL YÊU CẦU: ${item['quantity']}", style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (item['qtyReceived'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("THỰC NHẬN", style: GoogleFonts.montserrat(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.bold)),
                      Text("${item['qtyReceived']}", style: GoogleFonts.robotoMono(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAuditTrail(List audits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("LỊCH SỬ XỬ LÝ", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
          ],
        ),
        const SizedBox(height: 24),
        ...audits.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          final isLast = i == audits.length - 1;
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: entry.key == 0 ? AppTheme.accentGold : Colors.white10,
                        shape: BoxShape.circle,
                        boxShadow: entry.key == 0 ? [BoxShadow(color: AppTheme.accentGold.withOpacity(0.5), blurRadius: 4)] : null,
                      ),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(vertical: 4))),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_dateFmt.format(DateTime.parse(a['createdAt'])), style: GoogleFonts.robotoMono(fontSize: 10, color: i == 0 ? Colors.white70 : Colors.white38, fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal)),
                        const SizedBox(height: 4),
                        Text(a['action'].toUpperCase(), style: GoogleFonts.montserrat(fontSize: 11, color: i == 0 ? Colors.white : Colors.white38, fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProductImage(String? url) {
    final normalizedUrl = url != null 
      ? (url.startsWith('http') ? url : '${EnvConfig.apiBaseUrl}$url')
      : null;
      
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        image: normalizedUrl != null ? DecorationImage(image: NetworkImage(normalizedUrl), fit: BoxFit.cover) : null,
      ),
      child: normalizedUrl == null ? const Icon(Icons.inventory_2_outlined, color: Colors.white10, size: 20) : null,
    );
  }

  Widget _buildActionPanel(Map<String, dynamic> data, bool isMobile) {
    final status = data['status'] as String;
    final origin = data['origin'] as String;

    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                "TỔNG TIỀN HOÀN DỰ KIẾN", 
                style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold.withOpacity(0.6), fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${_currencyFmt.format(data['totalAmount'] ?? 0)}đ", 
                  style: GoogleFonts.robotoMono(
                    fontSize: isMobile ? 32 : 42, 
                    fontWeight: FontWeight.w300, 
                    color: AppTheme.accentGold, 
                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 32 : 60),
        
        if (status == 'RETURNING' || (status == 'APPROVED' && origin == 'POS'))
          _buildActionButton(
            label: "XÁC NHẬN NHẬN HÀNG",
            icon: Icons.inventory_2_outlined,
            onTap: () => _openReceiveDialog(data),
            isMobile: isMobile,
          ),
        
        if (status == 'RECEIVED' || status == 'REFUND_FAILED')
          _buildActionButton(
            label: "XỬ LÝ HOÀN TIỀN",
            icon: Icons.payments_outlined,
            onTap: () => _openRefundDialog(data),
            isMobile: isMobile,
          ),

        if (status == 'REJECTED_AFTER_RETURN' && !(data['shipments'] as List? ?? []).any((s) => s['type'] == 'RETURN_TO_SENDER'))
          _buildActionButton(
            label: "GỬI TRẢ LẠI KHÁCH",
            icon: Icons.local_shipping_outlined,
            onTap: () => _shipBackAutomated(data),
            isMobile: isMobile,
          ),

        if (status == 'COMPLETED') ...[
          if ((data['refunds'] as List? ?? []).any((r) => r['receiptImage'] != null))
            _buildActionButton(
              label: "XEM MINH CHỨNG",
              icon: Icons.receipt_long_outlined,
              onTap: () {
                final refund = (data['refunds'] as List).firstWhere((r) => r['receiptImage'] != null);
                _showProofImage(refund['receiptImage']);
              },
              isMobile: isMobile,
            ),
        ],
        
        if (!isMobile) const Spacer(),
        if (isMobile) const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: Colors.white24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Hệ thống sẽ tự động điều chỉnh tồn kho sau khi xác nhận nhận hàng.",
                  style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white24, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label, 
    required IconData icon, 
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -10,
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: isMobile ? 18 : 20),
        label: Text(
          label, 
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900, 
            fontSize: isMobile ? 12 : 13, 
            letterSpacing: 2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGold,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  void _openReceiveDialog(Map<String, dynamic> data) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => TabletReturnReceiveDialog(returnData: data),
    );
    if (success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xác nhận nhận hàng thành công."), backgroundColor: Colors.greenAccent),
        );
      }
    }
  }

  void _openRefundDialog(Map<String, dynamic> data) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => TabletReturnRefundDialog(returnData: data),
    );
    if (success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giao dịch hoàn tiền đã được ghi nhận."), backgroundColor: Colors.greenAccent),
        );
      }
    }
  }

  void _shipBackAutomated(Map<String, dynamic> data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        title: Text("XÁC NHẬN GỬI TRẢ KHÁCH", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text("Hệ thống sẽ tự động tạo vận đơn GHN gửi trả hàng lỗi cho khách. Phí vận chuyển sẽ do KHÁCH HÀNG thanh toán khi nhận hàng.", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("HỦY")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, foregroundColor: Colors.black),
            child: const Text("XÁC NHẬN"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await ref.read(staffReturnsProvider.notifier).shipBackAutomated(data['id']);
      if (res != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã tạo vận đơn GHN: ${res['orderCode']}. Phí ship do khách trả."), backgroundColor: Colors.greenAccent),
        );
        ref.invalidate(returnDetailsProvider(data['id']));
        ref.read(staffReturnsProvider.notifier).loadReturns();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi tạo vận đơn tự động."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
  void _showProofImage(String url) {
    final normalizedUrl = url.startsWith('http') ? url : '${EnvConfig.apiBaseUrl}$url';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text("MINH CHỨNG HOÀN TIỀN", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  normalizedUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  String get localized {
    switch (status) {
      case "REQUESTED": return "CHỜ DUYỆT";
      case "AWAITING_CUSTOMER": return "CHỜ KHÁCH HÀNG";
      case "REVIEWING": return "ĐANG XEM XÉT";
      case "APPROVED": return "ĐÃ DUYỆT";
      case "RETURNING": return "ĐANG GỬI LẠI";
      case "RECEIVED": return "ĐÃ NHẬN HÀNG";
      case "REFUNDING": return "ĐANG HOÀN TIỀN";
      case "REFUND_FAILED": return "HOÀN TIỀN LỖI";
      case "COMPLETED": return "HOÀN TẤT";
      case "REJECTED": return "ĐÃ TỪ CHỐI";
      case "REJECTED_AFTER_RETURN": return "TỪ CHỐI SAU NHẬN";
      case "CANCELLED": return "ĐÃ HUỶ";
      default: return status;
    }
  }

  Color get color {
    switch (status) {
      case "REQUESTED": return Colors.blueAccent;
      case "REVIEWING": return Colors.purpleAccent;
      case "APPROVED": return Colors.greenAccent;
      case "RETURNING": return Colors.orangeAccent;
      case "RECEIVED": return Colors.tealAccent;
      case "COMPLETED": return Colors.lightGreenAccent;
      case "REFUNDING": return Colors.indigoAccent;
      case "REJECTED":
      case "REJECTED_AFTER_RETURN":
      case "CANCELLED":
      case "REFUND_FAILED":
        return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        localized,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;
  final bool isStatus; // Kept for compatibility if used elsewhere
  final bool isLarge;
  final bool isMobile;
  const _InfoTile({
    required this.label, 
    required this.value, 
    this.isGold = false, 
    this.isStatus = false,
    this.isLarge = false,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.montserrat(
            fontSize: 9, 
            color: Colors.white38, 
            fontWeight: FontWeight.w800, 
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: isLarge ? 16 : 14, 
            fontWeight: isGold ? FontWeight.w900 : FontWeight.w600, 
            color: isGold ? AppTheme.accentGold : Colors.white, 
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
