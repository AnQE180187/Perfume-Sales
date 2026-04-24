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
          // Invalidate order providers so the Return button reappears
          ref.invalidate(orderProvider);
          // We don't have the orderId easily here, but we can invalidate the entire family if needed
          // or just the list. Actually, let's refresh the list.
          ref.read(orderProvider.notifier).refresh();
          
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
          final items = (ret['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          
          // Aggregate images from top-level (if any) and all items
          final Set<String> imagesSet = {};
          if (ret['images'] != null) {
            imagesSet.addAll((ret['images'] as List).cast<String>());
          }
          for (var item in items) {
            if (item['images'] != null) {
              final itemImages = (item['images'] as List).cast<String>();
              // Filter out the videoUrl if it was accidentally added to images list
              final videoUrl = ret['videoUrl'] as String?;
              imagesSet.addAll(itemImages.where((img) => img != videoUrl));
            }
          }
          final images = imagesSet.toList();
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
                const SizedBox(height: 16),
                _buildSummaryCard(ret, l10n),
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

                if (status == ReturnStatus.rejectedAfterReturn)
                  _buildRejectedEvidenceSection(ret, l10n),

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
          _buildGhnPickupView(ghnShipment, status, l10n, ret)
        else if (shipments.isNotEmpty)
          ...shipments.map((s) => _buildManualShipmentTile(s, l10n))
        else
          _buildManualShipmentPrompt(l10n),
      ],
    );
  }

  Widget _buildGhnPickupView(Map<String, dynamic> shipment, ReturnStatus status, AppLocalizations l10n, Map<String, dynamic> ret) {
    final trackingNumber = shipment['trackingNumber'] ?? '';
    final trackingUrl = 'https://ghn.vn/blogs/trang-thai-don-hang?order_code=$trackingNumber';
    
    final reason = ret['reason'] ?? '';
    final shopPays = _isShopFault(reason);

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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: shopPays ? const Color(0xFF12B76A).withValues(alpha: 0.1) : const Color(0xFFF79009).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  shopPays ? Icons.info_outline : Icons.warning_amber_rounded,
                  size: 14,
                  color: shopPays ? const Color(0xFF027A48) : const Color(0xFFB54708),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    shopPays 
                      ? l10n.returnShopPaysShipping
                      : l10n.returnCustomerPaysShipping,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: shopPays ? const Color(0xFF027A48) : const Color(0xFFB54708),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B67F6).withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: const Color(0xFF2B67F6).withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${l10n.trackingNumber} GHN'.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade400,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trackingNumber,
                        style: GoogleFonts.robotoMono(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B67F6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse(trackingUrl)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.accentGold),
                    label: Text(
                      l10n.traceOrder,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentGold,
                      ),
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
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                icon: _submittingHandover
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.handshake_outlined, size: 20),
                label: Text(
                  l10n.confirmHandover.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_shipping_outlined, color: AppTheme.accentGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (shipment['courier'] ?? l10n.shipmentTitle).toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppTheme.mutedSilver,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shipment['trackingNumber'] ?? '',
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
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

  Widget _buildRejectedEvidenceSection(Map<String, dynamic> ret, AppLocalizations l10n) {
    // Extract evidence from the RECEIVED audit
    final audits = (ret['audits'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final receivedAudit = audits.firstWhere(
      (a) => a['action'] == 'RECEIVED' && (a['payload']?['evidenceImages'] as List?)?.isNotEmpty == true,
      orElse: () => <String, dynamic>{},
    );
    final evidenceImages = (receivedAudit['payload']?['evidenceImages'] as List?)?.cast<String>() ?? [];

    // Extract return-to-customer shipments
    final shipments = (ret['shipments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final returnShipments = shipments.where((s) => s['status'] == 'RETURN_TO_CUSTOMER').toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF9A8D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel, color: Color(0xFFE02424)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.returnRejectedRequestLabel,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF9B1C1C),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9B1C1C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.returnRejectedReasonCompromised,
              style: GoogleFonts.montserrat(
                color: const Color(0xFF771D1D),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Shipping Fee Responsibility Transparency Block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.returnShippingResponsibility.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.returnShippingFeeCustomerRejected,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (evidenceImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${l10n.shopEvidenceLabel} (${evidenceImages.length})',
              style: GoogleFonts.montserrat(
                color: const Color(0xFFE02424),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: evidenceImages.map((url) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF9A8D4)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                )).toList(),
              ),
            ),
          ],
          if (returnShipments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.returnSendingBackToCustomer,
              style: GoogleFonts.montserrat(
                color: const Color(0xFFD97706),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...returnShipments.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE68A).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.trackingNumber} ${s['courier'] ?? ''}',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFFB45309),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          s['trackingNumber'] ?? '',
                          style: GoogleFonts.robotoMono(
                            color: const Color(0xFF92400E),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (s['courier'] == 'GHN' && s['trackingNumber'] != null)
                    TextButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://ghn.vn/blogs/trang-thai-don-hang?order_code=${s['trackingNumber']}')),
                      icon: const Icon(Icons.location_on, size: 14, color: Color(0xFFD97706)),
                      label: Text(
                        l10n.trackOrderCta,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFFD97706),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFCD34D).withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            )),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.returnPreparingToSendBack,
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFFB45309),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildSummaryCard(Map<String, dynamic> ret, AppLocalizations l10n) {
    final reason = ret['reason'] ?? '';
    final isShopFault = _isShopFault(reason);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.softTaupe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.help_outline, size: 16, color: AppTheme.mutedSilver),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.returnReason.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.mutedSilver,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _getReasonText(reason, l10n),
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.softTaupe),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isShopFault 
                    ? const Color(0xFF12B76A).withValues(alpha: 0.1) 
                    : const Color(0xFFF79009).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isShopFault ? Icons.check_circle_outline : Icons.info_outline, 
                  size: 16, 
                  color: isShopFault ? const Color(0xFF027A48) : const Color(0xFFB54708)
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.returnShippingResponsibility.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.mutedSilver,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      isShopFault ? l10n.returnShopPaysShipping : l10n.returnCustomerPaysShipping,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isShopFault ? const Color(0xFF027A48) : const Color(0xFFB54708),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isShopFault(String reason) {
    return reason.contains('[DAMAGED]') ||
           reason.contains('[WRONG_ITEM]') ||
           reason.contains('[EXPIRED]') ||
           reason == 'DAMAGED' ||
           reason == 'WRONG_ITEM' ||
           reason == 'EXPIRED';
  }

  String _getReasonText(String reason, AppLocalizations l10n) {
    String label = reason;
    if (reason.contains('[DAMAGED]') || reason == 'DAMAGED') {
      label = l10n.reasonDamaged;
    } else if (reason.contains('[WRONG_ITEM]') || reason == 'WRONG_ITEM') {
      label = l10n.reasonWrongItem;
    } else if (reason.contains('[EXPIRED]') || reason == 'EXPIRED') {
      label = l10n.reasonExpired;
    } else if (reason.contains('[SCENT_PREFERENCE]') || reason == 'SCENT_PREFERENCE') {
      label = l10n.reasonScentPreference;
    } else if (reason.contains('[COLOR_MISMATCH]') || reason == 'COLOR_MISMATCH') {
      label = l10n.reasonColorMismatch;
    } else if (reason.contains('[QUALITY_NOT_EXPECTED]') || reason == 'QUALITY_NOT_EXPECTED') {
      label = l10n.reasonQualityNotAsExpected;
    } else if (reason.contains('[CHANGE_OF_MIND]') || reason == 'CHANGE_OF_MIND') {
      label = l10n.reasonChangeOfMind;
    }

    // Extract detail by removing the bracketed part [TAG]
    final detail = reason.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    if (detail.isNotEmpty && detail != label && detail != reason) {
      return '$label: $detail';
    }
    return label;
  }

  ReturnStatus _parseReturnStatus(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'REQUESTED':
        return ReturnStatus.requested;
      case 'AWAITING_CUSTOMER':
        return ReturnStatus.awaitingCustomer;
      case 'REVIEWING':
        return ReturnStatus.reviewing;
      case 'APPROVED':
        return ReturnStatus.approved;
      case 'RETURNING':
        return ReturnStatus.returning;
      case 'RECEIVED':
        return ReturnStatus.received;
      case 'REFUNDING':
        return ReturnStatus.refunding;
      case 'REFUND_FAILED':
        return ReturnStatus.refundFailed;
      case 'COMPLETED':
        return ReturnStatus.completed;
      case 'REJECTED':
        return ReturnStatus.rejected;
      case 'REJECTED_AFTER_RETURN':
        return ReturnStatus.rejectedAfterReturn;
      case 'CANCELLED':
        return ReturnStatus.cancelled;
      default:
        return ReturnStatus.requested;
    }
  }
}
