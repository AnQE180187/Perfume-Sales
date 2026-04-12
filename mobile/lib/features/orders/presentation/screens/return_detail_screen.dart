import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_async_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../services/return_service.dart';
import '../../providers/order_provider.dart';
import '../widgets/return_status_badge.dart';

class ReturnDetailScreen extends ConsumerStatefulWidget {
  final String returnId;
  const ReturnDetailScreen({super.key, required this.returnId});

  @override
  ConsumerState<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends ConsumerState<ReturnDetailScreen> {
  late Future<Map<String, dynamic>> _returnFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _returnFuture = ref.read(returnServiceProvider).getReturnById(widget.returnId);
  }

  Future<void> _cancelReturn() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hủy yêu cầu',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: const Text('Bạn có chắc chắn muốn hủy yêu cầu trả hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('KHÔNG'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CÓ, HỦY', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(returnServiceProvider).cancelReturn(widget.returnId, 'User cancelled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hủy yêu cầu thành công')),
          );
          setState(() {
            _loadData();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi hủy: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        title: Text(
          'CHI TIẾT TRẢ HÀNG',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _returnFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final ret = snapshot.data!;
          final statusStr = ret['status'] as String;
          final status = _parseReturnStatus(statusStr);
          final items = (ret['items'] as List).cast<Map<String, dynamic>>();
          final images = (ret['images'] as List?)?.cast<String>() ?? [];
          final videoUrl = ret['videoUrl'] as String?;
          final refundInfo = ret['paymentInfo'] as Map<String, dynamic>?;
          final totalAmount = (ret['totalAmount'] ?? 0).toDouble();
          final orderCode = ret['order']?['code'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                _buildHeader(ret['id'], status, l10n),
                const SizedBox(height: 24),

                // Items section
                Text(
                  'SẢN PHẨM TRẢ',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutedSilver,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ...items.map((item) => _buildItemTile(item)),
                const SizedBox(height: 24),

                // Evidence section
                Text(
                  'HÌNH ẢNH MINH CHỨNG',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutedSilver,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEvidenceGrid(images, videoUrl),
                const SizedBox(height: 24),

                // Info section
                _buildInfoSection(ret, refundInfo, orderCode, totalAmount, l10n),
                const SizedBox(height: 32),

                // Cancel button
                if (status == ReturnStatus.requested || status == ReturnStatus.reviewing)
                  Center(
                    child: TextButton.icon(
                      onPressed: _cancelReturn,
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                      label: const Text(
                        'Hủy yêu cầu',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String id, ReturnStatus status, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mã trả hàng',
                  style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.mutedSilver),
                ),
                Text(
                  '#${id.substring(id.length - 8).toUpperCase()}',
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ReturnStatusBadge(status: status),
        ],
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    final variant = item['variant'];
    final product = variant?['product'];
    final productName = product?['name'] ?? 'Product';
    final imageUrl = (product?['images'] as List?)?.first?['url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: AppTheme.softTaupe),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Số lượng: ${item['quantity']}',
                  style: GoogleFonts.montserrat(fontSize: 13, color: AppTheme.mutedSilver),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceGrid(List<String> images, String? videoUrl) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...images.map((url) => _buildEvidenceMedia(url, isVideo: false)),
          if (videoUrl != null) _buildEvidenceMedia(videoUrl, isVideo: true),
        ],
      ),
    );
  }

  Widget _buildEvidenceMedia(String url, {required bool isVideo}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.4)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: isVideo
                ? Container(
                    color: Colors.black87,
                    child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                  )
                : Image.network(url, fit: BoxFit.cover),
          ),
          if (isVideo)
            const Positioned(
              bottom: 4,
              right: 4,
              child: Icon(Icons.videocam, color: Colors.white, size: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    Map<String, dynamic> ret,
    Map<String, dynamic>? refundInfo,
    String orderCode,
    double totalAmount,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Đơn hàng liên quan', '#$orderCode'),
        const Divider(height: 24),
        _infoRow('Lý do', ret['reason'] ?? 'Không có'),
        const SizedBox(height: 24),
        if (refundInfo != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THÔNG TIN NHẬN HOÀN TIỀN',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutedSilver,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                _refundLine('Ngân hàng', refundInfo['bankName'] ?? ''),
                _refundLine('Chủ tài khoản', refundInfo['accountName'] ?? ''),
                _refundLine('Số tài khoản', refundInfo['accountNumber'] ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TỔNG GIÁ TRỊ TRẢ',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
              ),
            ),
            Text(
              formatVND(totalAmount),
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.accentGold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.mutedSilver),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _refundLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.deepCharcoal)),
          Text(value, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  ReturnStatus _parseReturnStatus(String value) {
    final val = value.toUpperCase();
    switch (val) {
      case 'AWAITING_CUSTOMER': return ReturnStatus.awaitingCustomer;
      case 'REVIEWING': return ReturnStatus.reviewing;
      case 'APPROVED': return ReturnStatus.approved;
      case 'RETURNING': return ReturnStatus.returning;
      case 'RECEIVED': return ReturnStatus.received;
      case 'REFUNDING': return ReturnStatus.refunding;
      case 'REFUND_FAILED': return ReturnStatus.refundFailed;
      case 'COMPLETED': return ReturnStatus.completed;
      case 'REJECTED': return ReturnStatus.rejected;
      case 'REJECTED_AFTER_RETURN': return ReturnStatus.rejectedAfterReturn;
      case 'CANCELLED': return ReturnStatus.cancelled;
      case 'REQUESTED':
      default: return ReturnStatus.requested;
    }
  }
}
