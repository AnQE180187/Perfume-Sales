import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../pos/providers/pos_provider.dart';
import '../../pos/models/pos_models.dart';
import 'package:perfume_gpt_app/features/staff/tablet/presentation/boutique_success_overlay.dart';
import 'dart:ui';
import 'package:perfume_gpt_app/core/utils/responsive.dart';
import 'package:perfume_gpt_app/features/staff/models/staff_store.dart' as staff;
import 'package:perfume_gpt_app/features/stores/services/stores_service.dart' as stores;

class TabletPosCart extends ConsumerStatefulWidget {
  const TabletPosCart({super.key});

  @override
  ConsumerState<TabletPosCart> createState() => _TabletPosCartState();
}

class _TabletPosCartState extends ConsumerState<TabletPosCart> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencyFmt = NumberFormat('#,###', 'vi_VN');

    final isMobile = MediaQuery.of(context).size.width < 600;

    // Sync controller with state (e.g. when customer is cleared)
    ref.listen(posProvider.select((s) => s.customerPhone), (prev, next) {
      if ((next == null || next.isEmpty) && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    ref.listen(posProvider.select((s) => s.error), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    ref.listen(posProvider.select((s) => s.successMessage), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.green.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                "ĐƠN HIỆN TẠI",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentGold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              const Icon(Icons.receipt_outlined, color: Colors.white60, size: 16),
            ],
          ),
          const SizedBox(height: 16),

          _buildMemberSearchCompact(context, ref, l10n, posState, isMobile),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildMinimalCartList(ref, posState, currencyFmt, l10n),
            ),
          ),

          _buildLuxuryCheckoutFooter(context, ref, posState, currencyFmt, l10n),
        ],
      ),
    );
  }

  Widget _buildMemberSearchCompact(BuildContext context, WidgetRef ref, AppLocalizations l10n, PosState state, bool isMobile) {
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: "GẮN SĐT KHÁCH HÀNG...",
              hintStyle: GoogleFonts.montserrat(color: Colors.white60, fontSize: 10, letterSpacing: 1),
              prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 16),
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => ref.read(posProvider.notifier).autoSearchCustomers(v),
            onSubmitted: (v) {
              if (v.isNotEmpty) ref.read(posProvider.notifier).lookupLoyalty(v);
            },
          ),
        ),
        if (state.customerSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: state.customerSuggestions.map((s) => InkWell(
                  onTap: () {
                    _searchController.text = s.phone ?? "";
                    ref.read(posProvider.notifier).selectCustomerSuggestion(s);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.person_search_rounded, color: AppTheme.accentGold, size: 14),
                        const SizedBox(width: 8),
                        Text(s.phone ?? "", style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            s.fullName ?? "", 
                            style: GoogleFonts.playfairDisplay(color: Colors.white70, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("${s.loyaltyPoints} pts", style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        if (state.customerPhone != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.2), width: 0.5),
                    ),
                    child: const Icon(Icons.person_pin_rounded, color: AppTheme.accentGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${l10n.client} / ", style: GoogleFonts.montserrat(fontSize: 8, color: AppTheme.accentGold, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(color: AppTheme.accentGold.withOpacity(0.1), borderRadius: BorderRadius.circular(2)),
                                child: Text(
                                  state.customerInfo?.tier?.toUpperCase() ?? l10n.member,
                                  style: GoogleFonts.montserrat(fontSize: 7, color: AppTheme.accentGold, fontWeight: FontWeight.w900, letterSpacing: 1),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.customerInfo?.fullName ?? state.customerPhone!,
                          style: GoogleFonts.playfairDisplay(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (state.customerInfo != null)
                          Text(
                            "${state.customerInfo!.loyaltyPoints} ${l10n.loyaltyPoints}",
                            style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (state.customerPhone != null)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.card_membership_rounded, size: 22, color: AppTheme.accentGold),
                      onPressed: () => _showVoucherDialog(context, ref, state),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white24),
                    onPressed: () => ref.read(posProvider.notifier).setCustomerPhone(''),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMinimalCartList(WidgetRef ref, PosState state, NumberFormat fmt, AppLocalizations l10n) {
    return ListView.builder(
      itemCount: state.localCart.length,
      itemBuilder: (ctx, i) {
        final item = state.localCart[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName.toUpperCase(), style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("${item.variantName} @ ${fmt.format(item.price)}đ", style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                  Text("${fmt.format(item.totalPrice)}đ", style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MinimalQtyBtn(icon: Icons.remove, onTap: () => ref.read(posProvider.notifier).updateCartQuantity(item.variantId, item.quantity - 1)),
                  const SizedBox(width: 24),
                  Text("${item.quantity}", style: GoogleFonts.robotoMono(fontSize: 16, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 24),
                  _MinimalQtyBtn(icon: Icons.add, onTap: () => ref.read(posProvider.notifier).updateCartQuantity(item.variantId, item.quantity + 1)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLuxuryCheckoutFooter(BuildContext context, WidgetRef ref, PosState state, NumberFormat fmt, AppLocalizations l10n) {
    final subtotal = state.localCart.fold<double>(0, (sum, it) => sum + it.totalPrice);
    final discount = state.currentOrder?.discountAmount ?? 0.0;
    final total = subtotal - discount;

    return Column(
      children: [
        const Divider(color: Colors.white10),
        const SizedBox(height: 8),
        _PriceLine(label: l10n.subtotal.toUpperCase(), value: "${fmt.format(subtotal)}đ"),
        if (discount > 0) 
          _PriceLine(
            label: l10n.memberDiscount.toUpperCase(), 
            value: "-${fmt.format(discount)}đ", 
            isGold: true,
            onRemove: () => ref.read(posProvider.notifier).removePromotion(),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(l10n.totalAmount.toUpperCase(), 
              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  "${fmt.format(total)}đ",
                  style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accentGold),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.isMobile(context) ? 12 : 24),
        Row(
          children: [
            Expanded(
              child: _ActionBtn(
                label: "TIỀN MẶT",
                onTap: () => _handleCheckout(context, ref, "CASH", l10n),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionBtn(
                label: "QR / THẺ",
                isOutline: true,
                onTap: () => _handleCheckout(context, ref, "QR", l10n),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _ActionBtn(
            label: "LƯU ĐƠN NHÁP",
            isGhost: true,
            onTap: () => _handleSaveDraft(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSaveDraft(BuildContext context, WidgetRef ref) async {
    final storeId = ref.read(posSelectedStoreIdProvider);
    if (storeId == null) return;

    final success = await ref.read(posProvider.notifier).saveAsDraft(storeId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đơn hàng đã được lưu nháp thành công")),
      );
    }
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref, String method, AppLocalizations l10n) async {
    final storeId = ref.read(posSelectedStoreIdProvider);
    if (storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn cửa hàng trước khi thanh toán")),
      );
      return;
    }

    final notifier = ref.read(posProvider.notifier);
    
    final storesAsync = ref.read(posStoresProvider);
    final selectedStoreId = storeId;
    stores.Store? currentStore;
    
    storesAsync.whenData((list) {
      final staffStore = list.firstWhere((s) => s.id == selectedStoreId);
      currentStore = stores.Store(
        id: staffStore.id,
        name: staffStore.name,
        address: staffStore.address,
      );
    });

    if (method == "CASH") {
      final res = await notifier.checkoutCash(storeId);
      if (res != null) {
        final order = PosOrder.fromJson(res);
        _showSuccessDialog(context, "THANH TOÁN TIỀN MẶT THÀNH CÔNG", order, currentStore);
      }
    } else {
      final res = await notifier.checkoutQr(storeId);
      if (res != null) {
        final url = res['checkoutUrl'] as String?;
        final orderJson = res['order'] as Map<String, dynamic>?;
        if (url != null) {
          final order = orderJson != null ? PosOrder.fromJson(orderJson) : null;
          _showQrDialog(context, url, l10n, order, currentStore);
        }
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String title, [PosOrder? order, stores.Store? store]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, _, __) => BoutiqueSuccessOverlay(
        title: title,
        order: order,
        store: store,
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showQrDialog(BuildContext context, String url, AppLocalizations l10n, [PosOrder? order, stores.Store? store]) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          title: Column(
            children: [
              Text(l10n.loyaltyGateway, style: GoogleFonts.montserrat(fontSize: 8, color: Colors.black38, fontWeight: FontWeight.w800, letterSpacing: 3)),
              const SizedBox(height: 8),
              Text(l10n.scanToPay, style: GoogleFonts.playfairDisplay(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 260,
                height: 260,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, spreadRadius: -10)],
                ),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                  size: 220.0,
                ),
              ),
              const SizedBox(height: 32),
              Text(l10n.encryptionActive, style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SelectableText(url, style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.black12), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (order != null) _showSuccessDialog(context, "THANH TOÁN THÀNH CÔNG", order, store);
              },
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
              child: Center(child: Text(l10n.confirm, style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
              child: Center(child: Text(l10n.terminateRequest, style: GoogleFonts.montserrat(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoucherDialog(BuildContext context, WidgetRef ref, PosState state) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFmt = NumberFormat('#,###', 'vi_VN');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppTheme.accentGold.withOpacity(0.1))),
        title: Row(
          children: [
            const Icon(Icons.card_membership_rounded, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 12),
            Text(
              l10n.availableVouchers.toUpperCase(),
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: state.customerPromotions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final up = state.customerPromotions[i];
              final promo = up['promotion'] as Map<String, dynamic>;
              final code = promo['code'] as String;
              final desc = promo['description'] as String? ?? '';
              final discountType = promo['discountType'] as String;
              final discountValue = (promo['discountValue'] as num?)?.toDouble() ?? 0.0;
              final minOrder = (promo['minOrderAmount'] as num?)?.toDouble() ?? 0.0;
              
              final subtotal = state.localCart.fold<double>(0, (sum, it) => sum + it.totalPrice);
              final isEligible = subtotal >= minOrder;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(code, style: GoogleFonts.robotoMono(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          discountType == 'PERCENTAGE' ? "-${discountValue.toInt()}%" : "-${currencyFmt.format(discountValue)}đ",
                          style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hết hạn: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(promo['endDate']))}",
                          style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 9),
                        ),
                        ElevatedButton(
                          onPressed: !isEligible ? null : () {
                            Navigator.pop(ctx);
                            ref.read(posProvider.notifier).applyPromotion(
                              code,
                              storeId: ref.read(posSelectedStoreIdProvider),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.white10,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            !isEligible 
                              ? l10n.minOrderRequired(currencyFmt.format(minOrder)) 
                              : l10n.apply,
                            style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close, style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;
  final VoidCallback? onRemove;
  const _PriceLine({required this.label, required this.value, this.isGold = false, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: isGold ? AppTheme.accentGold : Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onRemove,
                    child: Icon(Icons.close, size: 14, color: isGold ? AppTheme.accentGold.withOpacity(0.7) : Colors.white54),
                  ),
                ],
              ],
            ),
          ),
          Text(value, style: GoogleFonts.robotoMono(fontSize: 14, color: isGold ? AppTheme.accentGold : Colors.white70)),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final String label;
  final bool isOutline;
  final bool isGhost;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, this.isOutline = false, this.isGhost = false, required this.onTap});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isGhost ? Colors.white10 : (widget.isOutline ? Colors.transparent : AppTheme.accentGold);
    final textColor = widget.isGhost ? Colors.white70 : (widget.isOutline ? AppTheme.accentGold : Colors.black);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: widget.isGhost ? 44 : 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered && widget.isOutline 
              ? AppTheme.accentGold.withOpacity(0.05) 
              : (_isHovered && !widget.isOutline && !widget.isGhost 
                ? AppTheme.accentGold.withOpacity(0.9) 
                : (_isHovered && widget.isGhost ? Colors.white.withOpacity(0.15) : color)),
            border: widget.isOutline ? Border.all(color: AppTheme.accentGold, width: 1) : null,
            borderRadius: BorderRadius.circular(2),
            boxShadow: _isHovered && !widget.isGhost
                ? [
                    BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: widget.isGhost ? 11 : 15,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalQtyBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MinimalQtyBtn({required this.icon, required this.onTap});

  @override
  State<_MinimalQtyBtn> createState() => _MinimalQtyBtnState();
}

class _MinimalQtyBtnState extends State<_MinimalQtyBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.02),
            border: Border.all(color: _isHovered ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.05)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(widget.icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
