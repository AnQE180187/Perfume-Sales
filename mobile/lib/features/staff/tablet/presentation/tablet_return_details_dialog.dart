import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: 900,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(color: Colors.white10, height: 1),
              Expanded(
                child: detailsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                  error: (e, _) => AppErrorWidget(
                    message: "Lỗi tải chi tiết yêu cầu.",
                    onRetry: () => ref.refresh(returnDetailsProvider(widget.returnId)),
                  ),
                  data: (data) => _buildBody(data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Row(
        children: [
          const Icon(Icons.rotate_left_rounded, color: AppTheme.accentGold, size: 28),
          const SizedBox(width: 20),
          Text(
            "CHI TIẾT YÊU CẦU ĐỔI TRẢ",
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white24, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    final status = data['status'] as String;
    final items = data['items'] as List;
    final audits = data['audits'] as List;

    return Row(
      children: [
        // Left: Items List & Info
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(data, status),
                const SizedBox(height: 48),
                _buildItemsList(items),
                const SizedBox(height: 48),
                _buildAuditTrail(audits),
              ],
            ),
          ),
        ),
        
        const VerticalDivider(color: Colors.white10, width: 1),

        // Right: Actions Area
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(40),
            color: Colors.black26,
            child: _buildActionPanel(data),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoTile(label: "MÃ YÊU CẦU", value: "#${data['id'].toString().substring(0, 8).toUpperCase()}", isGold: true),
            _InfoTile(label: "MÃ ĐƠN HÀNG", value: "#${data['orderId'].toString().substring(0, 8).toUpperCase()}"),
          ],
        ),
        const SizedBox(height: 32),
        _InfoTile(label: "LÝ DO ĐỔI TRẢ", value: data['reason'] ?? "KHÔNG CÓ LÝ DO CỤ THỂ"),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoTile(label: "KHÁCH HÀNG", value: data['user']?['fullName'] ?? "KHÁCH LẺ"),
            _InfoTile(label: "TRẠNG THÁI", value: status, isStatus: true),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsList(List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DANH SÁCH SẢN PHẨM", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 20),
        ...items.map((item) {
          final v = item['variant'];
          final p = v?['product'];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                _buildProductImage(p?['images']?[0]?['url']),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p?['name']?.toUpperCase() ?? "UNKNOWN", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("${v?['name']} | SL YÊU CẦU: ${item['quantity']}", style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold)),
                    ],
                  ),
                ),
                if (item['qtyReceived'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("THỰC NHẬN", style: GoogleFonts.montserrat(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.bold)),
                      Text("${item['qtyReceived']}", style: GoogleFonts.robotoMono(fontSize: 16, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
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
        Text("LỊCH SỬ XỬ LÝ", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 20),
        ...audits.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(_dateFmt.format(DateTime.parse(a['createdAt'])), style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white24)),
              const SizedBox(width: 16),
              Expanded(child: Text(a['action'], style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white60))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildProductImage(String? url) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(4),
        image: url != null ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
      ),
    );
  }

  Widget _buildActionPanel(Map<String, dynamic> data) {
    final status = data['status'] as String;
    final origin = data['origin'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TỔNG TIỀN HOÀN DỰ KIẾN", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 12),
        Text("${_currencyFmt.format(data['totalRefundAmount'] ?? 0)}đ", style: GoogleFonts.robotoMono(fontSize: 32, fontWeight: FontWeight.w300, color: AppTheme.accentGold, letterSpacing: 2)),
        const SizedBox(height: 60),
        
        if (status == 'RETURNING' || (status == 'APPROVED' && origin == 'POS'))
          _buildActionButton(
            label: "XÁC NHẬN NHẬN HÀNG",
            icon: Icons.inventory_2_outlined,
            onTap: () => _openReceiveDialog(data),
          ),
        
        if (status == 'RECEIVED' || status == 'REFUND_FAILED')
          _buildActionButton(
            label: "XỬ LÝ HOÀN TIỀN",
            icon: Icons.payments_outlined,
            onTap: () => _openRefundDialog(data),
          ),
        
        const Spacer(),
        Text(
          "HỆ THỐNG TỰ ĐỘNG ĐIỀU CHỈNH TỔN KHO SAU KHI XÁC NHẬN NHẬN HÀNG.",
          style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white10, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;
  final bool isStatus;
  const _InfoTile({required this.label, required this.value, this.isGold = false, this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(
          value,
          style: isStatus 
            ? GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.accentGold, letterSpacing: 1)
            : GoogleFonts.montserrat(fontSize: 14, fontWeight: isGold ? FontWeight.w900 : FontWeight.w600, color: isGold ? AppTheme.accentGold : Colors.white, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
