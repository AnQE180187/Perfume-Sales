import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/address.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback? onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.selected,
    required this.onSelect,
    this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDefault = address.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isDefault)
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(
          color: isDefault
              ? AppTheme.accentGold.withValues(alpha: 0.5)
              : (selected
                    ? AppTheme.deepCharcoal
                    : AppTheme.softTaupe.withValues(alpha: 0.3)),
          width: isDefault || selected ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSelect,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabelIcon(context, address.label),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  address.recipientName,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.deepCharcoal,
                                  ),
                                ),
                                const Spacer(),
                                if (isDefault)
                                  _PremiumBadge(label: l10n.defaultUpper),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address.phone,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.mutedSilver,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      height: 1,
                      color: AppTheme.softTaupe,
                      thickness: 0.5,
                    ),
                  ),
                  Text(
                    address.fullAddress,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                  if (address.note != null && address.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.note_alt_outlined,
                          size: 14,
                          color: AppTheme.mutedSilver,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address.note!,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.mutedSilver,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (!isDefault && onSetDefault != null)
                        TextButton(
                          onPressed: onSetDefault,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.setDefault,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentGold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      const Spacer(),
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        onPressed: onEdit,
                        color: AppTheme.deepCharcoal,
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        onPressed: onDelete,
                        color: Colors.red.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelIcon(BuildContext context, AddressLabel label) {
    IconData icon;
    switch (label) {
      case AddressLabel.home:
        icon = Icons.home_outlined;
        break;
      case AddressLabel.office:
        icon = Icons.work_outline_rounded;
        break;
      case AddressLabel.gift:
        icon = Icons.card_giftcard_rounded;
        break;
      case AddressLabel.hotel:
        icon = Icons.hotel_outlined;
        break;
      case AddressLabel.school:
        icon = Icons.school_outlined;
        break;
      case AddressLabel.cafe:
        icon = Icons.store_outlined;
        break;
      case AddressLabel.other:
        icon = Icons.more_horiz_rounded;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.ivoryBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.5)),
      ),
      child: Icon(icon, size: 20, color: AppTheme.deepCharcoal),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final String label;
  const _PremiumBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentGold, Color(0xFFD4AF37)],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
