import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;
  final VoidCallback onVoiceSearch;
  final bool showClearButton;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
    required this.onClear,
    required this.onBack,
    required this.onVoiceSearch,
    required this.showClearButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 10),
      color: AppTheme.ivoryBackground,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.deepCharcoal, size: 20),
            onPressed: onBack,
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.5), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.search_rounded,
                    color: AppTheme.mutedSilver,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      cursorColor: AppTheme.accentGold,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchHint,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.mutedSilver.withValues(alpha: 0.7),
                        ),
                      ),
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppTheme.deepCharcoal,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (showClearButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: onClear,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.ivoryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.mutedSilver,
                            size: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.mic_rounded, color: AppTheme.accentGold, size: 20),
                      onPressed: onVoiceSearch,
                      padding: const EdgeInsets.only(right: 8),
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
