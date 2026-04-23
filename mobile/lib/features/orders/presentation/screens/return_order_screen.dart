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
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  bool _policyAccepted = false;
  bool _confirmedStatus = false;
  bool _showingPolicyOnly = true;

  void _nextStep() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      if (_selectedItems.isEmpty) {
        _showError(l10n.errorSelectItems);
        return;
      }
      if (_selectedQuickReason == null) {
        _showError(l10n.errorReason);
        return;
      }
    } else if (_currentStep == 1) {
      if (_bankNameController.text.trim().isEmpty ||
          _accountNumberController.text.trim().isEmpty ||
          _accountNameController.text.trim().isEmpty) {
        _showError(l10n.errorBankInfo);
        return;
      }
    }
    setState(() => _currentStep++);
  }

  void _prevStep() {
    setState(() => _currentStep--);
  }

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

      final String? videoUrl =
          _video != null ? await service.uploadVideo(_video!) : null;
      final idempotencyKey = const Uuid().v4();

      final Map<String, dynamic> payload = {
        'orderId': widget.orderId,
        'origin': 'ONLINE',
        'items': _selectedItems.entries.map((e) => {
              'variantId': e.key,
              'quantity': e.value,
              'images': imageUrls,
            }).toList(),
        'reason': finalReason,
        'videoUrl': videoUrl,
        'paymentInfo': {
          'bankName': _bankNameController.text.trim(),
          'accountNumber': _accountNumberController.text.trim(),
          'accountName': _accountNameController.text.trim(),
        }
      };

      final returnId = await service.createReturn(payload, idempotencyKey: idempotencyKey);

      if (mounted) {
        ref.invalidate(orderProvider);
        ref.invalidate(orderDetailProvider(widget.orderId));
        
        if (returnId != null) {
          context.pushReplacement('/return-success?returnId=$returnId');
        } else {
          // Fallback if ID not returned for some reason
          context.pop();
        }
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
            content: Text('${l10n.error}: $errorMessage'),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
          color: AppTheme.deepCharcoal,
        ),
        title: Text(
          l10n.returnRequest.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.deepCharcoal,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: orderAsync.when(
        data: (order) {
          if (_showingPolicyOnly) {
            return _buildPolicySequence(l10n);
          }
          return _buildFormFlow(order, l10n);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(err.toString())),
      ),
    );
  }

  Widget _buildPolicySequence(AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: !_policyAccepted 
        ? _buildPolicyView(l10n)
        : _buildConfirmView(l10n),
    );
  }

  Widget _buildPolicyView(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        "CHÍNH SÁCH ĐỔI TRẢ VÀ HOÀN TIỀN",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "(RETURN POLICY)",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.mutedSilver,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildPolicyItem(
                  "1",
                  "Điều kiện đổi trả chung",
                  "Khách hàng có quyền yêu cầu trả hàng/hoàn tiền trong vòng 07 ngày kể từ khi nhận hàng thành công. Mọi yêu cầu phải kèm theo hình ảnh/video bằng chứng.",
                ),
                _buildPolicyItem(
                  "2",
                  "Phân định trách nhiệm",
                  "• Lỗi Shop (Sai mẫu, hỏng): Shop chịu 100% phí ship, hoàn 100% giá trị.\n• Lỗi Khách (Đổi ý): Khách chịu phí ship trả hàng, chỉ hoàn giá trị sản phẩm (không hoàn ship đầu).",
                ),
                _buildPolicyItem(
                  "3",
                  "Kiểm định hàng lỗi",
                  "Sản phẩm phải CÒN NGUYÊN SEAL nếu do khách đổi ý. Nếu mất seal hoặc hư hại do khách, Shop có quyền từ chối hoàn tiền và gửi trả lại (Khách chịu phí ship COD).",
                ),
                _buildPolicyItem(
                  "4",
                  "Yêu cầu bằng chứng",
                  "Khuyến khích quay video unboxing và đóng gói trả hàng để bảo vệ quyền lợi.",
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton(
          "TÔI ĐÃ ĐỌC VÀ ĐỒNG Ý",
          () => setState(() => _policyAccepted = true),
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildConfirmView(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined, size: 64, color: AppTheme.accentGold),
          ),
          const SizedBox(height: 32),
          Text(
            "XÁC NHẬN TÌNH TRẠNG",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "\"Tôi xác nhận sản phẩm vẫn còn nguyên seal. Tôi hiểu rằng nếu sản phẩm bị mất seal, tôi sẽ bị từ chối hoàn tiền và phải trả phí ship để nhận lại hàng.\"",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          _buildElegantButton(
            "XÁC NHẬN & TIẾP TỤC",
            () => setState(() => _showingPolicyOnly = false),
          ),
          TextButton(
            onPressed: () => setState(() => _policyAccepted = false),
            child: Text(
              "QUAY LẠI",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.mutedSilver,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String index, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentGold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFlow(Order order, AppLocalizations l10n) {
    return Column(
      children: [
        _buildStepper(l10n),
        const SizedBox(height: 12),
        _buildGuidanceCard(l10n),
        const SizedBox(height: 16),
        Expanded(child: _buildContent(order, l10n)),
        _buildBottomBar(l10n),
      ],
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    final steps = [
      l10n.returnStep1,
      l10n.returnStep2,
      l10n.returnStep3,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final isActive = stepIndex <= _currentStep;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppTheme.accentGold : Colors.transparent,
                    border: Border.all(
                      color: isActive
                          ? AppTheme.accentGold
                          : AppTheme.mutedSilver.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${stepIndex + 1}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isActive ? Colors.white : AppTheme.mutedSilver,
                      ),
                    ),
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    steps[stepIndex],
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                ],
              ],
            );
          } else {
            final lineIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: lineIndex < _currentStep
                    ? AppTheme.accentGold
                    : AppTheme.mutedSilver.withValues(alpha: 0.2),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildBottomButton(String text, VoidCallback onPressed, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
      child: _buildElegantButton(text, onPressed),
    );
  }

  Widget _buildElegantButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGold,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.accentGold.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }


  Widget _buildGuidanceCard(AppLocalizations l10n) {
    final guidance = switch (_currentStep) {
      0 => l10n.returnGuidanceStep1,
      1 => l10n.returnGuidanceStep2,
      2 => l10n.returnGuidanceStep3,
      _ => '',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_outlined,
                  color: AppTheme.accentGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.returnGuidanceTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            guidance,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Order order, AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        key: ValueKey(_currentStep),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) ...[
              _buildSectionHeader(l10n.selectReturnItems),
              const SizedBox(height: 16),
              ...order.items.map((item) => _buildProductCard(item)),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.returnReason),
              const SizedBox(height: 12),
              _buildReasonChips(l10n),
            ] else if (_currentStep == 1) ...[
              _buildSectionHeader(l10n.returnReasonHint),
              const SizedBox(height: 12),
              _buildElegantTextField(
                controller: _reasonController,
                hint: l10n.returnReasonExample,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.refundInfo),
              const SizedBox(height: 12),
              _buildRefundForm(l10n),
            ] else if (_currentStep == 2) ...[
              _buildEvidenceSection(l10n),
            ],
            const SizedBox(height: 40),
          ],
        ),
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
            color: isSelected
                ? AppTheme.accentGold
                : AppTheme.mutedSilver.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.accentGold : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accentGold
                      : AppTheme.mutedSilver.withValues(alpha: 0.4),
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImage.isNotEmpty
                  ? Image.network(item.productImage,
                      width: 60, height: 60, fit: BoxFit.cover)
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
                    style: GoogleFonts.montserrat(
                        color: AppTheme.mutedSilver, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected) _buildQtyPicker(item, qty),
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
          icon: const Icon(Icons.remove_circle_outline,
              size: 20, color: AppTheme.mutedSilver),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '$currentQty',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        IconButton(
          onPressed: () {
            if (currentQty < item.quantity) {
              setState(() => _selectedItems[item.variantId] = currentQty + 1);
            }
          },
          icon: const Icon(Icons.add_circle_outline,
              size: 20, color: AppTheme.accentGold),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildReasonChips(AppLocalizations l10n) {
    final storeFaults = [
      {'val': 'DAMAGED', 'label': l10n.reasonDamaged},
      {'val': 'WRONG_ITEM', 'label': l10n.reasonWrongItem},
      {'val': 'EXPIRED', 'label': l10n.reasonExpired},
    ];

    final otherReasons = [
      {'val': 'SCENT_PREFERENCE', 'label': l10n.reasonScentPreference},
      {'val': 'COLOR_MISMATCH', 'label': l10n.reasonColorMismatch},
      {'val': 'QUALITY_EXPECTATION', 'label': l10n.reasonQualityNotAsExpected},
      {'val': 'CHANGE_OF_MIND', 'label': l10n.reasonChangeOfMind},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReasonCategoryHeader(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF12B76A),
          title: l10n.returnCategoryStoreFault,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: storeFaults.map((r) => _buildReasonChip(r)).toList(),
        ),
        const SizedBox(height: 24),
        _buildReasonCategoryHeader(
          icon: Icons.error_outline,
          color: const Color(0xFFF79009),
          title: l10n.returnCategoryOther,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: otherReasons.map((r) => _buildReasonChip(r)).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonCategoryHeader({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonChip(Map<String, String> r) {
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
          color: isSelected
              ? AppTheme.accentGold
              : AppTheme.mutedSilver.withValues(alpha: 0.3),
        ),
      ),
      showCheckmark: false,
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
        style:
            GoogleFonts.montserrat(fontSize: 14, color: AppTheme.deepCharcoal),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: AppTheme.mutedSilver)
              : null,
          hintStyle:
              GoogleFonts.montserrat(color: AppTheme.mutedSilver, fontSize: 13),
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
              '${_images.length}/5',
              style: GoogleFonts.montserrat(
                  fontSize: 11, color: AppTheme.mutedSilver),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.returnEvidenceTip1,
          style: GoogleFonts.montserrat(
              fontSize: 11,
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
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
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.videoEvidence),
        const SizedBox(height: 8),
        Text(
          l10n.returnEvidenceTip2,
          style: GoogleFonts.montserrat(
              fontSize: 11,
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w600),
        ),
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
          painter: _DashedBorderPainter(
              color: AppTheme.mutedSilver.withValues(alpha: 0.4)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.accentGold, size: 28),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.montserrat(
                      fontSize: 10, color: AppTheme.mutedSilver)),
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
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
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
              style: GoogleFonts.montserrat(
                  fontSize: 12, color: AppTheme.deepCharcoal),
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
    final isLastStep = _currentStep == 2;
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
          Row(
            children: [
              if (_currentStep > 0) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _prevStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(
                          color: AppTheme.deepCharcoal.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      l10n.returnBack,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : (isLastStep ? _submitReturn : _nextStep),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepCharcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          (isLastStep ? l10n.submitReturn : l10n.returnNext)
                              .toUpperCase(),
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 1.1),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppTheme.mutedSilver),
              const SizedBox(width: 6),
              Text(
                l10n.returnProcessNotice,
                style: GoogleFonts.montserrat(
                    fontSize: 10, color: AppTheme.mutedSilver),
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
