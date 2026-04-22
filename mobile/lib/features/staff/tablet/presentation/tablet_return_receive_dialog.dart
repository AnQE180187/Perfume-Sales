import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../returns/providers/returns_provider.dart';

class TabletReturnReceiveDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> returnData;
  const TabletReturnReceiveDialog({super.key, required this.returnData});

  @override
  ConsumerState<TabletReturnReceiveDialog> createState() => _TabletReturnReceiveDialogState();
}

class _TabletReturnReceiveDialogState extends ConsumerState<TabletReturnReceiveDialog> {
  final Map<String, int> _receivedQtys = {};
  final Map<String, bool> _sealIntact = {};
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final items = widget.returnData['items'] as List;
    for (var item in items) {
      final vId = item['variantId'];
      _receivedQtys[vId] = item['quantity'];
      _sealIntact[vId] = true;
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final itemsPayload = _receivedQtys.entries.map((e) => {
      'variantId': e.key,
      'qtyReceived': e.value,
      'sealIntact': _sealIntact[e.key] ?? true,
    }).toList();

    final success = await ref.read(staffReturnsProvider.notifier).receiveReturn(
      widget.returnData['id'],
      items: itemsPayload,
      receivedLocation: widget.returnData['origin'] == 'POS' ? 'POS' : 'WAREHOUSE',
      note: _noteController.text.trim(),
    );

    if (success && mounted) {
      ref.invalidate(returnDetailsProvider(widget.returnData['id']));
      ref.read(staffReturnsProvider.notifier).loadReturns();
      Navigator.pop(context, true);
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi xác nhận nhận hàng."), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.returnData['items'] as List;

    return AlertDialog(
      backgroundColor: const Color(0xFF151515),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.white10),
      ),
      title: Text("XÁC NHẬN NHẬN HÀNG HÀNG THỰC TẾ", style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...items.map((item) {
                final vId = item['variantId'];
                final v = item['variant'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), border: Border.all(color: Colors.white10)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v?['product']?['name']?.toUpperCase() ?? "SẢN PHẨM", style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text("YÊU CẦU: ${item['quantity']}", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Qty Input
                      _buildQtyCounter(vId, item['quantity']),
                      const SizedBox(width: 20),
                      // Seal Check
                      GestureDetector(
                        onTap: () => setState(() => _sealIntact[vId] = !(_sealIntact[vId] ?? true)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: (_sealIntact[vId] ?? true) ? Colors.greenAccent.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3)),
                            color: (_sealIntact[vId] ?? true) ? Colors.greenAccent.withOpacity(0.05) : Colors.redAccent.withOpacity(0.05),
                          ),
                          child: Text(
                            (_sealIntact[vId] ?? true) ? "CÒN SEAL" : "MẤT SEAL",
                            style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: (_sealIntact[vId] ?? true) ? Colors.greenAccent : Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              TextField(
                controller: _noteController,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: "GHI CHÚ KIỂM HÀNG",
                  labelStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 10),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentGold)),
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
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, foregroundColor: Colors.black),
          child: _isSubmitting 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text("XÁC NHẬN", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildQtyCounter(String vId, int max) {
    final val = _receivedQtys[vId] ?? 0;
    return Row(
      children: [
        IconButton(
          onPressed: val > 0 ? () => setState(() => _receivedQtys[vId] = val - 1) : null,
          icon: const Icon(Icons.remove_circle_outline, color: Colors.white38, size: 20),
        ),
        Text("$val", style: GoogleFonts.robotoMono(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: val < max ? () => setState(() => _receivedQtys[vId] = val + 1) : null,
          icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentGold, size: 20),
        ),
      ],
    );
  }
}
