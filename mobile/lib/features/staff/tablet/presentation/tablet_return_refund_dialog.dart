import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../returns/providers/returns_provider.dart';

class TabletReturnRefundDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> returnData;
  const TabletReturnRefundDialog({super.key, required this.returnData});

  @override
  ConsumerState<TabletReturnRefundDialog> createState() => _TabletReturnRefundDialogState();
}

class _TabletReturnRefundDialogState extends ConsumerState<TabletReturnRefundDialog> {
  String _method = 'cash';
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  final _currencyFmt = NumberFormat('#,###', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    final suggestedAsync = ref.watch(suggestedRefundProvider(widget.returnData['id']));

    return AlertDialog(
      backgroundColor: const Color(0xFF151515),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.white10),
      ),
      title: Text("XỬ LÝ HOÀN TIỀN", style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SỐ TIỀN HOÀN (DỰA TRÊN THỰC NHẬN)", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
            const SizedBox(height: 8),
            suggestedAsync.when(
              loading: () => const LinearProgressIndicator(color: AppTheme.accentGold, backgroundColor: Colors.white10),
              error: (_, __) => Text("Lỗi tính toán số tiền", style: TextStyle(color: Colors.redAccent)),
              data: (amount) => Text("${_currencyFmt.format(amount)}đ", style: GoogleFonts.robotoMono(fontSize: 32, color: AppTheme.accentGold, fontWeight: FontWeight.w300)),
            ),
            const SizedBox(height: 32),
            Text("PHƯƠNG THỨC HOÀN TIỀN", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildMethodOption('cash', "TIỀN MẶT (CASH)", Icons.payments_outlined),
            const SizedBox(height: 12),
            _buildMethodOption('bank_transfer', "CHUYỂN KHOẢN (TRANSFER)", Icons.account_balance_outlined),
            const SizedBox(height: 32),
            TextField(
              controller: _noteController,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: "GHI CHÚ HOÀN TIỀN",
                  labelStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 10),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentGold)),
                ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("HỦY", style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSubmitting ? null : () => _submit(suggestedAsync.value ?? 0),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, foregroundColor: Colors.black),
          child: _isSubmitting 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text("XÁC NHẬN CHI TIỀN", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildMethodOption(String id, String label, IconData icon) {
    final isSelected = _method == id;
    return InkWell(
      onTap: () => setState(() => _method = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold.withOpacity(0.05) : Colors.transparent,
          border: Border.all(color: isSelected ? AppTheme.accentGold.withOpacity(0.3) : Colors.white10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.accentGold : Colors.white24, size: 20),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : Colors.white38)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.accentGold, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(double amount) async {
    setState(() => _isSubmitting = true);
    final success = await ref.read(staffReturnsProvider.notifier).triggerRefund(
      widget.returnData['id'], 
      method: _method, 
      amount: amount,
      note: _noteController.text.trim(),
    );

    if (success && mounted) {
      ref.invalidate(returnDetailsProvider(widget.returnData['id']));
      ref.read(staffReturnsProvider.notifier).loadReturns();
      Navigator.pop(context, true);
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi xử lý hoàn tiền."), backgroundColor: Colors.redAccent),
      );
    }
  }
}
