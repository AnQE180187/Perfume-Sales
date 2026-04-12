import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/order_item.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class ReturnOrderScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ReturnOrderScreen({super.key, required this.orderId});

  @override
  ConsumerState<ReturnOrderScreen> createState() => _ReturnOrderScreenState();
}

class _ReturnOrderScreenState extends ConsumerState<ReturnOrderScreen> {
  final _reasonController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  
  final List<File> _images = [];
  File? _video;
  final ImagePicker _picker = ImagePicker();
  
  // variantId -> quantity
  final Map<String, int> _selectedItems = {};
  String? _selectedQuickReason;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(
      imageQuality: 70,
    );
    if (picked.isNotEmpty) {
      setState(() {
        for (var p in picked) {
          if (_images.length < 5) {
            _images.add(File(p.path));
          }
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (picked != null) {
      setState(() {
        _video = File(picked.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _video = null;
    });
  }

  void _submitReturn() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_selectedItems.isEmpty) {
      _showError(l10n.errorSelectItems);
      return;
    }
    if (_selectedQuickReason == null && _reasonController.text.trim().isEmpty) {
      _showError(l10n.errorReason);
      return;
    }
    if (_bankNameController.text.trim().isEmpty || 
        _accountNumberController.text.trim().isEmpty || 
        _accountNameController.text.trim().isEmpty) {
      _showError(l10n.errorBankInfo);
      return;
    }
    
    if (_images.length < 3) {
      _showError(l10n.errorPhotoCount);
      return;
    }

    if (_video == null) {
      _showError(l10n.errorVideoMissing);
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final service = ref.read(returnServiceProvider);
      
      // 1. Upload images
      final imageUrls = await service.uploadImages(_images);
      
      // 3. Prepare payload
      final String finalReason = _selectedQuickReason != null 
        ? '[$_selectedQuickReason] ${_reasonController.text.trim()}'
        : _reasonController.text.trim();

      final String? videoUrl = _video != null ? await service.uploadVideo(_video!) : null;
      final idempotencyKey = const Uuid().v4();

      final Map<String, dynamic> payload = {
        'orderId': widget.orderId,
        'origin': 'ONLINE',
        'items': _selectedItems.entries.map((e) => {
          'variantId': e.key, 
          'quantity': e.value,
          'images': [
            ...imageUrls,
            if (videoUrl != null) videoUrl,
          ],
        }).toList(),
        'reason': finalReason,
        'videoUrl': videoUrl,
        'paymentInfo': {
          'bankName': _bankNameController.text.trim(),
          'accountNumber': _accountNumberController.text.trim(),
          'accountName': _accountNameController.text.trim(),
        }
      };
      
      await service.createReturn(payload, idempotencyKey: idempotencyKey);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.returnSuccess),
            backgroundColor: const Color(0xFF12B76A),
          ),
        );
        context.pop();
        ref.invalidate(orderProvider);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFD92D20)),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.returnRequestTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.deepCharcoal,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        data: (order) => Column(
          children: [
            // 14-day policy notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.accentGold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.freeReturns,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(order, l10n)),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGold),
        ),
        error: (err, _) => Center(
          child: Text(l10n.failedLoadOrder, style: const TextStyle(color: Color(0xFFD92D20))),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  Widget _buildContent(Order order, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Items Selection
          _buildSectionHeader(l10n.selectReturnItems),
          const SizedBox(height: 16),
          ...order.items.map((item) => _buildProductCard(item)),
          
          const SizedBox(height: 32),
          
          // 2. Return Reason
          _buildSectionHeader(l10n.returnReason),
          const SizedBox(height: 16),
          _buildReasonChips(l10n),
          const SizedBox(height: 12),
          _buildElegantTextField(
            controller: _reasonController,
            hint: l10n.returnReasonHint,
            maxLines: 3,
          ),
          
          const SizedBox(height: 32),
          
          // 3. Refund Info
          _buildSectionHeader(l10n.refundInfo),
          const SizedBox(height: 16),
          _buildRefundForm(l10n),
          
          const SizedBox(height: 32),
          
          // 4. Evidence
          _buildEvidenceSection(l10n),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildProductCard(OrderItem item) {
    final isSelected = _selectedItems.containsKey(item.variantId);
    final qty = _selectedItems[item.variantId] ?? 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedItems.remove(item.variantId);
          } else {
            _selectedItems[item.variantId] = item.quantity;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.mutedSilver.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          children: [
            // Checkmark Overlay
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.accentGold : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.accentGold : AppTheme.mutedSilver.withValues(alpha: 0.4),
                ),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImage.isNotEmpty
                ? Image.network(item.productImage, width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: Colors.grey[100]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: GoogleFonts.montserrat(
                      color: AppTheme.deepCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.variantLabel,
                    style: GoogleFonts.montserrat(color: AppTheme.mutedSilver, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected) 
              _buildQtyPicker(item, qty),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyPicker(OrderItem item, int currentQty) {
    if (item.quantity <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (currentQty > 1) {
              setState(() => _selectedItems[item.variantId] = currentQty - 1);
            }
          },
          icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppTheme.mutedSilver),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '$currentQty',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        IconButton(
          onPressed: () {
            if (currentQty < item.quantity) {
              setState(() => _selectedItems[item.variantId] = currentQty + 1);
            }
          },
          icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.accentGold),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildReasonChips(AppLocalizations l10n) {
    final reasons = [
      {'val': 'DAMAGED', 'label': l10n.reasonDamaged},
      {'val': 'WRONG_ITEM', 'label': l10n.reasonWrongItem},
      {'val': 'NOT_EXPECTED', 'label': l10n.reasonScentNotExpected},
    ];

    return Wrap(
      spacing: 8,
      children: reasons.map((r) {
        final isSelected = _selectedQuickReason == r['val'];
        return ChoiceChip(
          label: Text(r['label']!),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              _selectedQuickReason = val ? r['val'] : null;
            });
          },
          selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
          backgroundColor: Colors.white,
          labelStyle: GoogleFonts.montserrat(
            fontSize: 12,
            color: isSelected ? AppTheme.accentGold : AppTheme.deepCharcoal,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: isSelected ? AppTheme.accentGold : AppTheme.mutedSilver.withValues(alpha: 0.3),
            ),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildElegantTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mutedSilver.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.deepCharcoal),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 20, color: AppTheme.mutedSilver) : null,
          hintStyle: GoogleFonts.montserrat(color: AppTheme.mutedSilver, fontSize: 13),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRefundForm(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F2), // Premium cream background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildElegantTextField(
            controller: _bankNameController,
            hint: l10n.bankName,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          _buildElegantTextField(
            controller: _accountNumberController,
            hint: l10n.accountNumber,
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildElegantTextField(
            controller: _accountNameController,
            hint: l10n.accountName,
            icon: Icons.person_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(l10n.evidenceTitle),
            Text(
              '${_images.length}/5 images',
              style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.mutedSilver),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Image Horizontal List
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              if (_images.length < 5)
                _buildDashedPicker(
                  onTap: _pickImages,
                  icon: Icons.add_a_photo_outlined,
                  label: l10n.addPhoto,
                ),
              
              ..._images.asMap().entries.map((e) => _buildThumbnail(
                    File(e.value.path),
                    onRemove: () => _removeImage(e.key),
                  )),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Video Section
        _buildSectionHeader(l10n.videoEvidence),
        const SizedBox(height: 12),
        if (_video == null)
           _buildDashedPicker(
            onTap: _pickVideo,
            icon: Icons.videocam_outlined,
            label: l10n.addVideo,
            width: double.infinity,
          )
        else
          _buildVideoPreview(),
      ],
    );
  }

  Widget _buildDashedPicker({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    double width = 90,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 90,
        margin: const EdgeInsets.only(right: 12),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: AppTheme.mutedSilver.withValues(alpha: 0.4)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.accentGold, size: 28),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.mutedSilver)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(File file, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 90,
      height: 90,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.video_file_outlined, color: AppTheme.accentGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _video!.path.split('/').last,
              style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.deepCharcoal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _removeVideo,
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepCharcoal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    l10n.submitReturn.toUpperCase(),
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.1),
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppTheme.mutedSilver),
              const SizedBox(width: 6),
              Text(
                l10n.returnProcessNotice,
                style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.mutedSilver),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    const borderRadius = 16.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    for (var metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
