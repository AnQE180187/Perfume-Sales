import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
  final List<File> _evidenceFiles = [];
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _pickEvidence() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _evidenceFiles.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  void _removeEvidence(int idx) {
    setState(() => _evidenceFiles.removeAt(idx));
  }

  Future<void> _submit() async {
    final hasCompromised = _sealIntact.values.any((v) => !v);
    if (hasCompromised && _evidenceFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bắt buộc phải có ảnh bằng chứng khi hàng bị lỗi/mất seal."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final notifier = ref.read(staffReturnsProvider.notifier);
      
      // 1. Upload evidence if any
      List<String>? evidenceUrls;
      if (_evidenceFiles.isNotEmpty) {
        evidenceUrls = await notifier.uploadImages(_evidenceFiles);
      }

      final itemsPayload = _receivedQtys.entries.map((e) => {
        'variantId': e.key,
        'qtyReceived': e.value,
        'sealIntact': _sealIntact[e.key] ?? true,
      }).toList();

      final success = await notifier.receiveReturn(
        widget.returnData['id'],
        items: itemsPayload,
        receivedLocation: widget.returnData['origin'] == 'POS' ? 'POS' : 'WAREHOUSE',
        note: _noteController.text.trim(),
        evidenceImages: evidenceUrls,
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
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.redAccent),
        );
      }
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
              const SizedBox(height: 24),
              if (_sealIntact.values.any((v) => !v)) ...[
                _buildEvidencePicker(),
                const SizedBox(height: 24),
              ],
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

  Widget _buildEvidencePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
            const SizedBox(width: 8),
            Text("BẰNG CHỨNG HÀNG LỖI (BẮT BUỘC)", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _pickEvidence,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10),
                    color: Colors.white.withOpacity(0.02),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: Colors.white24, size: 20),
                      SizedBox(height: 4),
                      Text("THÊM ẢNH", style: TextStyle(fontSize: 8, color: Colors.white24)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ..._evidenceFiles.asMap().entries.map((e) => Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10),
                      image: DecorationImage(image: FileImage(e.value), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeEvidence(e.key),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        color: Colors.black54,
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
}
