import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/daily_report.dart';

class DailyClosingDialog extends ConsumerStatefulWidget {
  final DailyReport report;
  final String storeId;
  const DailyClosingDialog({super.key, required this.report, required this.storeId});

  @override
  ConsumerState<DailyClosingDialog> createState() => _DailyClosingDialogState();
}

class _DailyClosingDialogState extends ConsumerState<DailyClosingDialog> {
  final _actualCashController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  final currencyFmt = NumberFormat('#,###', 'vi_VN');

  double get systemCash => widget.report.totalRevenue * 0.4; // Giả định 40% là tiền mặt (Demo)
  double get systemTransfer => widget.report.totalRevenue * 0.6; // Giả định 60% là ck (Demo)

  @override
  void dispose() {
    _actualCashController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitClosing() async {
    final actualCashStr = _actualCashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final actualCash = double.tryParse(actualCashStr) ?? 0;
    final diff = actualCash - systemCash;

    setState(() => _isSubmitting = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      
      await apiClient.post(
        '/daily-closing',
        data: {
          'storeId': widget.storeId,
          'systemTotal': widget.report.totalRevenue.toInt(),
          'systemCash': systemCash.toInt(),
          'systemTransfer': systemTransfer.toInt(),
          'actualCash': actualCash.toInt(),
          'difference': diff.toInt(),
          'note': _noteController.text,
          'orderCount': widget.report.totalOrders,
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Chốt doanh thu thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: AppTheme.accentGold, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CHỐT DOANH THU",
                          style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                        ),
                        Text(
                          "Đối soát tiền mặt thực tế cuối ngày",
                          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                _buildInfoRow("Tổng đơn hàng", "${widget.report.totalOrders}"),
                _buildInfoRow("Tổng doanh thu (Hệ thống)", "${currencyFmt.format(widget.report.totalRevenue)}đ", isGold: true),
                const Divider(color: Colors.white10, height: 32),
                _buildInfoRow("Tiền mặt (Hệ thống)", "${currencyFmt.format(systemCash)}đ"),
                _buildInfoRow("Chuyển khoản (Hệ thống)", "${currencyFmt.format(systemTransfer)}đ"),
                
                const SizedBox(height: 32),
                Text(
                  "TIỀN MẶT THỰC TẾ",
                  style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _actualCashController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(color: Colors.white10),
                    suffixText: "VNĐ",
                    suffixStyle: GoogleFonts.montserrat(color: Colors.white38, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
                
                const SizedBox(height: 24),
                Text(
                  "GHI CHÚ / LÝ DO CHÊNH LỆCH",
                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Nhập lý do nếu có chênh lệch tiền mặt...",
                    hintStyle: TextStyle(color: Colors.white10),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitClosing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                        )
                      : Text("XÁC NHẬN CHỐT DOANH THU", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("HỦY BỎ", style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 14)),
          Text(
            value, 
            style: GoogleFonts.robotoMono(
              color: isGold ? AppTheme.accentGold : Colors.white, 
              fontSize: 16, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}
