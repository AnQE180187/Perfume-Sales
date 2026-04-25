import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  final _currencyFmt = NumberFormat('#,###', 'vi_VN');

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _receiptImage = File(picked.path));
    }
  }

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
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SỐ TIỀN HOÀN (DỰA TRÊN THỰC NHẬN)", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
              const SizedBox(height: 8),
              suggestedAsync.when(
                loading: () => const LinearProgressIndicator(color: AppTheme.accentGold, backgroundColor: Colors.white10),
                error: (_, __) => const Text("Lỗi tính toán số tiền", style: TextStyle(color: Colors.redAccent)),
                data: (amount) => Text("${_currencyFmt.format(amount)}đ", style: GoogleFonts.robotoMono(fontSize: 32, color: AppTheme.accentGold, fontWeight: FontWeight.w300)),
              ),
              const SizedBox(height: 32),
              Text("PHƯƠNG THỨC HOÀN TIỀN", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
              const SizedBox(height: 16),
              _buildMethodOption('cash', "TIỀN MẶT (CASH)", Icons.payments_outlined),
              const SizedBox(height: 12),
              _buildMethodOption('bank_transfer', "CHUYỂN KHOẢN (TRANSFER)", Icons.account_balance_outlined),
              const SizedBox(height: 32),
              if (_method != 'cash') ...[
                Text("ẢNH HÓA ĐƠN / BIÊN LAI", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                      image: _receiptImage != null 
                        ? DecorationImage(image: FileImage(_receiptImage!), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _receiptImage == null 
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: Colors.white10, size: 32),
                            const SizedBox(height: 8),
                            Text("NHẤN ĐỂ CHỌN ẢNH MINH CHỨNG", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white10, fontWeight: FontWeight.w600)),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => setState(() => _receiptImage = null),
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              TextField(
                controller: _noteController,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "GHI CHÚ HOÀN TIỀN",
                  labelStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 10),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppTheme.accentGold), borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("HỦY", style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: (_isSubmitting || suggestedAsync.isLoading || suggestedAsync.value == null || suggestedAsync.value! <= 0 || (_method != 'cash' && _receiptImage == null)) 
            ? null 
            : () => _submit(suggestedAsync.value!),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGold, 
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppTheme.accentGold.withOpacity(0.1),
            disabledForegroundColor: Colors.white24,
          ),
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
      onTap: () => setState(() {
        _method = id;
        if (id == 'cash') _receiptImage = null;
      }),
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
            Expanded(
              child: Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : Colors.white38), overflow: TextOverflow.ellipsis),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.accentGold, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(double amount) async {
    setState(() => _isSubmitting = true);
    
    String? receiptImageUrl;
    if (_receiptImage != null) {
      final urls = await ref.read(staffReturnsProvider.notifier).uploadImages([_receiptImage!]);
      if (urls.isNotEmpty) receiptImageUrl = urls.first;
    }

    final success = await ref.read(staffReturnsProvider.notifier).triggerRefund(
      widget.returnData['id'], 
      method: _method, 
      note: _noteController.text.trim(),
      receiptImage: receiptImageUrl,
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
