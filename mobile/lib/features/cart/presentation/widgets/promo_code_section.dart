import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/cart_provider.dart';
import '../../providers/promotions_provider.dart';
import 'package:intl/intl.dart';

class PromoCodeSection extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final bool hasPromoCode;
  final String? promoCode;
  final double promoDiscount;
  final bool isLoading;

  const PromoCodeSection({
    super.key,
    required this.controller,
    required this.hasPromoCode,
    this.promoCode,
    required this.promoDiscount,
    required this.isLoading,
  });

  @override
  ConsumerState<PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends ConsumerState<PromoCodeSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _animController.forward() : _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasPromoCode && widget.promoCode != null) {
      return _buildApplied();
    }
    return _buildExpandable();
  }

  Widget _buildApplied() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: AppTheme.accentGold,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.promoCode!.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold,
                  ),
                ),
                Text(
                  l10n.discountAppliedWithPercent((widget.promoDiscount * 100).toInt()),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppTheme.mutedSilver,
            ),
            onPressed: () => ref.read(cartProvider.notifier).removePromoCode(),
            tooltip: l10n.removeCode,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandable() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                   const Icon(
                    Icons.local_offer_outlined,
                    color: AppTheme.accentGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.havePromoCode,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: _isExpanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.accentGold,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: l10n.enterPromoCode,
                            hintStyle: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: AppTheme.mutedSilver,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: AppTheme.ivoryBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppTheme.accentGold.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppTheme.deepCharcoal,
                          ),
                          onSubmitted: (code) {
                            if (code.isNotEmpty) {
                              ref
                                  .read(cartProvider.notifier)
                                  .applyPromoCode(code);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: widget.isLoading
                              ? null
                              : () {
                                  if (widget.controller.text.isNotEmpty) {
                                    ref
                                        .read(cartProvider.notifier)
                                        .applyPromoCode(widget.controller.text);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          child: widget.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.apply,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPublicPromos(l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicPromos(AppLocalizations l10n) {
    final promosAsync = ref.watch(activePromotionsProvider);
    return promosAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (promos) {
        if (promos.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.availablePromoCodes,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.mutedSilver,
              ),
            ),
            const SizedBox(height: 12),
            ...promos.map(
              (promo) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildPromoItem(promo, l10n),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPromoItem(Promotion promo, AppLocalizations l10n) {
    final String code = promo.code;
    final String desc = promo.displayDescription;
    final bool isSelected = widget.promoCode == code;
    final String expiryDate = DateFormat('dd/MM/yyyy').format(promo.endDate);

    return GestureDetector(
      onTap: () {
        widget.controller.text = code;
        ref.read(cartProvider.notifier).applyPromoCode(code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: ClipPath(
          clipper: _VoucherTicketClipper(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected
                    ? AppTheme.accentGold
                    : AppTheme.softTaupe.withValues(alpha: 0.2),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.ivoryBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.verified_rounded : Icons.local_offer_outlined,
                    color: AppTheme.accentGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 10, color: AppTheme.mutedSilver),
                          const SizedBox(width: 4),
                          Text(
                            l10n.validUntil(expiryDate),
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedSilver,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentGold,
                    size: 22,
                  )
                else
                  Text(
                    l10n.useCode,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentGold,
                      letterSpacing: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoucherTicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 8.0;
    final path = Path();
    path.lineTo(0.0, size.height / 2 - radius);
    path.arcToPoint(
      Offset(0.0, size.height / 2 + radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height / 2 + radius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 - radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
