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
import 'boutique_success_overlay.dart';
import 'dart:ui';

class TabletPosCart extends ConsumerWidget {
  const TabletPosCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posState = ref.watch(posProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencyFmt = NumberFormat('#,###', 'vi_VN');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                "ĐƠN HIỆN TẠI",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentGold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              const Icon(Icons.receipt_outlined, color: Colors.white60, size: 18),
            ],
          ),
          const SizedBox(height: 32),
          
          // Member Search
          _buildMinimalMemberSearch(ref, l10n, posState),
          const SizedBox(height: 32),

          // Items Bar
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text("MÔ TẢ", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const Spacer(),
                Text("TÀM TÍNH", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ],
            ),
          ),
          const Divider(color: Colors.white10),

          // Cart Items
          Expanded(
            child: _buildMinimalCartList(ref, posState, currencyFmt, l10n),
          ),

          // Footer
          _buildLuxuryCheckoutFooter(context, ref, posState, currencyFmt, l10n),
        ],
      ),
    );
  }

  Widget _buildMinimalMemberSearch(WidgetRef ref, AppLocalizations l10n, PosState state) {
    return Column(
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: "GẮN SĐT KHÁCH HÀNG...",
              hintStyle: GoogleFonts.montserrat(color: Colors.white38, fontSize: 10, letterSpacing: 1),
              prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white60, size: 16),
              border: InputBorder.none,
              filled: false,
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
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: state.customerSuggestions.map((s) => InkWell(
                onTap: () => ref.read(posProvider.notifier).selectCustomerSuggestion(s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_rounded, color: AppTheme.accentGold, size: 14),
                      const SizedBox(width: 8),
                      Text(s.phone ?? "", style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(s.fullName ?? "", style: GoogleFonts.playfairDisplay(color: Colors.white70, fontSize: 11)),
                      const Spacer(),
                      Text("${s.loyaltyPoints} pts", style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        if (state.customerPhone != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.2), width: 0.5),
                    ),
                    child: const Icon(Icons.person_pin_rounded, color: AppTheme.accentGold, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${l10n.client} / ", style: GoogleFonts.montserrat(fontSize: 8, color: AppTheme.accentGold, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(color: AppTheme.accentGold.withOpacity(0.1), borderRadius: BorderRadius.circular(2)),
                              child: Text(state.customerInfo?.tier?.toUpperCase() ?? l10n.member, style: GoogleFonts.montserrat(fontSize: 7, color: AppTheme.accentGold, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(state.customerInfo?.fullName ?? state.customerPhone!, style: GoogleFonts.playfairDisplay(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                        if (state.customerInfo != null)
                          Text("${state.customerInfo!.loyaltyPoints} ${l10n.loyaltyPoints}", style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white24),
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
                        Text("${item.variantName}ml @ ${fmt.format(item.price)}đ", style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white60)),
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
        const SizedBox(height: 16),
        _PriceLine(label: l10n.subtotal.toUpperCase(), value: "${fmt.format(subtotal)}đ"),
        if (discount > 0) _PriceLine(label: l10n.memberDiscount.toUpperCase(), value: "-${fmt.format(discount)}đ", isGold: true),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(l10n.totalAmount.toUpperCase(), 
              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  "${fmt.format(total)}đ",
                  style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.accentGold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
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
    
    if (method == "CASH") {
      final res = await notifier.checkoutCash(storeId);
      if (res != null) {
        _showSuccessDialog(context, "THANH TOÁN TIỀN MẶT THÀNH CÔNG");
      }
    } else {
      final res = await notifier.checkoutQr(storeId);
      if (res != null) {
        final url = res['checkoutUrl'] as String?;
        if (url != null) {
          _showQrDialog(context, url, l10n);
        }
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String title) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, _, __) => BoutiqueSuccessOverlay(
        title: title,
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showQrDialog(BuildContext context, String url, AppLocalizations l10n) {
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
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
              child: Center(child: Text(l10n.terminateRequest, style: GoogleFonts.montserrat(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;
  const _PriceLine({required this.label, required this.value, this.isGold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: isGold ? AppTheme.accentGold : Colors.white60, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          Text(value, style: GoogleFonts.robotoMono(fontSize: 14, color: isGold ? AppTheme.accentGold : Colors.white54)),
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
