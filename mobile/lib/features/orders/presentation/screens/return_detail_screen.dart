import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/order.dart';
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
  bool _submittingHandover = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _returnFuture = ref.read(returnServiceProvider).getReturnById(widget.returnId);
  }

  Future<void> _cancelReturn() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.cancelRequest,
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.cancelRequestConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yesCancel, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(returnServiceProvider).cancelReturn(widget.returnId, l10n.userCancelled);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cancelSuccess)),
          );
          setState(() {
            _loadData();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.cancelError}: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleHandover() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submittingHandover = true);
    try {
      await ref.read(returnServiceProvider).confirmHandover(widget.returnId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.confirmHandoverSuccess)),
        );
        setState(() {
          _loadData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submittingHandover = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        title: Text(
          l10n.returnDetail.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 14,
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
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
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
                _buildHeader(ret['id'], status, l10n),
                const SizedBox(height: 24),

                Text(
                  l10n.returnedProducts.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutedSilver,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ...items.map((item) => _buildItemTile(item, l10n)),
                const SizedBox(height: 24),

                Text(
                  l10n.evidenceImages.toUpperCase(),
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

                if (status == ReturnStatus.approved || status == ReturnStatus.returning)
                  _buildShipmentSection(ret, status, l10n),

                if (status == ReturnStatus.received || status == ReturnStatus.refunding)
                  _buildRefundNoticeSection(l10n),

                if (status == ReturnStatus.completed)
                  _buildRefundCompletionSection(ret, l10n),

                const SizedBox(height: 48),

                _buildInfoSection(ret, refundInfo, orderCode, totalAmount, l10n),
                const SizedBox(height: 32),

                if (status == ReturnStatus.requested || status == ReturnStatus.reviewing)
                  Center(
                    child: TextButton.icon(
                      onPressed: _cancelReturn,
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                      label: Text(
                        l10n.cancelRequest,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
                  l10n.returnIdLabel,
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

  Widget _buildItemTile(Map<String, dynamic> item, AppLocalizations l10n) {
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
                  '${l10n.quantity}: ${item['quantity']}',
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
        _infoRow(l10n.relatedOrder, '#$orderCode'),
        const Divider(height: 24),
        _infoRow(l10n.reasonLabel, ret['reason'] ?? l10n.noReason),
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
                  l10n.refundInfo.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutedSilver,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                _refundLine(l10n.refundBankLabel, refundInfo['bankName'] ?? ''),
                _refundLine(l10n.refundAccountNameLabel, refundInfo['accountName'] ?? ''),
                _refundLine(l10n.refundAccountNumberLabel, refundInfo['accountNumber'] ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalAmount.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
              ),
            ),
            Text(
              formatVND(totalAmount),
              style: GoogleFonts.montserrat(
                fontSize: 18,
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

  Widget _buildShipmentSection(Map<String, dynamic> ret, ReturnStatus status, AppLocalizations l10n) {
    final shipments = (ret['shipments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final isOnline = ret['origin'] == 'ONLINE';
    final ghnShipment = shipments.firstWhere((s) => s['courier'] == 'GHN', orElse: () => {});
    final hasGhnPickup = isOnline && ghnShipment.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.shipmentTitle,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.mutedSilver,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            if (hasGhnPickup)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B67F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2B67F6).withValues(alpha: 0.3)),
                ),
                child: Text(
                  l10n.supportPickup,
                  style: const TextStyle(color: Color(0xFF2B67F6), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasGhnPickup)
          _buildGhnPickupView(ghnShipment, status, l10n)
        else if (shipments.isNotEmpty)
          ...shipments.map((s) => _buildManualShipmentTile(s, l10n))
        else
          _buildManualShipmentPrompt(l10n),
      ],
    );
  }

  Widget _buildGhnPickupView(Map<String, dynamic> shipment, ReturnStatus status, AppLocalizations l10n) {
    final trackingNumber = shipment['trackingNumber'] ?? '';
    final trackingUrl = 'https://ghn.vn/blogs/trang-thai-don-hang?order_code=$trackingNumber';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B67F6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2B67F6).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2B67F6), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.ghnPickupNotice,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF1A45A0),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.ghnPickupDesc,
            style: GoogleFonts.montserrat(
              color: const Color(0xFF1A45A0).withValues(alpha: 0.8),
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B67F6).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GHN TRACKING',
                        style: GoogleFonts.montserrat(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trackingNumber,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2B67F6),
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse(trackingUrl)),
                  icon: const Icon(Icons.open_in_new, size: 12, color: AppTheme.accentGold),
                  label: Text(
                    l10n.trackMovement,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (status == ReturnStatus.approved) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submittingHandover ? null : _handleHandover,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B67F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF2B67F6).withValues(alpha: 0.4),
                ),
                icon: _submittingHandover
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.handshake_rounded, size: 18),
                label: Text(
                  l10n.confirmHandover,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualShipmentTile(Map<String, dynamic> shipment, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shipment['courier'] ?? l10n.shipmentTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(shipment['trackingNumber'] ?? '', style: GoogleFonts.montserrat(fontSize: 13, color: AppTheme.mutedSilver)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualShipmentPrompt(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.softTaupe.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            l10n.supportShowroomReturn,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.mutedSilver),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRefundNoticeSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD666)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFD48806)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.adminRefundNotice,
              style: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFFD48806), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCompletionSection(Map<String, dynamic> ret, AppLocalizations l10n) {
    final refunds = (ret['refunds'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (refunds.isEmpty) return const SizedBox.shrink();
    
    final refund = refunds.first;
    final amount = refund['amount'] ?? 0;
    final createdAt = refund['createdAt'] != null ? DateTime.parse(refund['createdAt']) : DateTime.now();
    final timeStr = DateFormat('HH:mm dd/MM/yyyy').format(createdAt);
    final proofImages = _extractRefundProofImages(ret, refund);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB9F6CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.refundConfirmed,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.statusSuccess,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(l10n.refundedAmount, formatVND((amount as num).toDouble())),
          const SizedBox(height: 8),
          _infoRow(l10n.timeUpper, timeStr),
          if (proofImages.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildRefundProofImages(proofImages, l10n),
          ],
        ],
      ),
    );
  }

  List<String> _extractRefundProofImages(
    Map<String, dynamic> ret,
    Map<String, dynamic> refund,
  ) {
    final urls = <String>[];

    void addFrom(dynamic raw) {
      if (raw is List) {
        for (final it in raw) {
          if (it == null) continue;
          if (it is String && it.trim().isNotEmpty) urls.add(it.trim());
          if (it is Map && it['url'] != null) {
            final u = it['url'].toString().trim();
            if (u.isNotEmpty) urls.add(u);
          }
        }
      }
    }

    addFrom(ret['refundProofImages']);
    addFrom(ret['refundImages']);
    addFrom(refund['images']);
    addFrom(refund['evidenceImages']);
    addFrom(refund['proofImages']);

    // de-duplicate while preserving order
    final seen = <String>{};
    final deduped = <String>[];
    for (final u in urls) {
      if (seen.add(u)) deduped.add(u);
    }
    return deduped;
  }

  Widget _buildRefundProofImages(List<String> urls, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.evidenceImages.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: const Color(0xFF1B5E20).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: urls
                .map(
                  (u) => GestureDetector(
                    onTap: () => _openImagePreview(context, u),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          u,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white.withValues(alpha: 0.35),
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 26,
                              color: const Color(0xFF1B5E20)
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  void _openImagePreview(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withValues(alpha: 0.9),
          insetPadding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ReturnStatus _parseReturnStatus(String status) {
    return ReturnStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase() || e.name == status,
      orElse: () => ReturnStatus.requested,
    );
  }
}
