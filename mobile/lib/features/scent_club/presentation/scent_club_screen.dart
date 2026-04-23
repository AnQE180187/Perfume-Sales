import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/core/theme/app_theme.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfume_gpt_app/features/scent/models/scent_family.dart';
import 'package:perfume_gpt_app/features/scent/data/scent_repository.dart';
import 'package:perfume_gpt_app/features/scent/data/scent_api_service.dart';
import 'package:perfume_gpt_app/core/widgets/empty_state_widget.dart';

class ScentClubScreen extends ConsumerStatefulWidget {
  const ScentClubScreen({super.key});

  @override
  ConsumerState<ScentClubScreen> createState() => _ScentClubScreenState();
}

class _ScentClubScreenState extends ConsumerState<ScentClubScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Map<String, List<String>> _groupNotes(List<String> notes) {
    // Sort notes alphabetically
    final sorted = List<String>.from(notes)..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    
    final groups = <String, List<String>>{};
    for (var note in sorted) {
      if (note.isEmpty) continue;
      final firstLetter = note[0].toUpperCase();
      if (!groups.containsKey(firstLetter)) {
        groups[firstLetter] = [];
      }
      groups[firstLetter]!.add(note);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notesAsync = ref.watch(scentNotesProvider);
    final repo = ref.watch(scentRepositoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.ivoryBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppTheme.deepCharcoal,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.scentClub,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepCharcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
          error: (err, stack) => Center(child: Text(err.toString())),
          data: (allNotes) {
            final q = _query.trim().toLowerCase();
            final filteredNotes = q.isEmpty
                ? allNotes
                : allNotes.where((n) => n.toLowerCase().contains(q)).toList();

            if (filteredNotes.isEmpty && q.isNotEmpty) {
              return Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: _SearchField(
                      controller: _search,
                      hintText: l10n.searchHint,
                      onChanged: (v) => setState(() => _query = v),
                      onClear: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ),
                  Expanded(
                    child: EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      title: l10n.noProductsFound,
                      subtitle: l10n.searchHint,
                    ),
                  ),
                ],
              );
            }

            final grouped = _groupNotes(filteredNotes);
            final letters = grouped.keys.toList()..sort();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: _SearchField(
                      controller: _search,
                      hintText: l10n.searchHint,
                      onChanged: (v) => setState(() => _query = v),
                      onClear: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ),
                ),
                
                // ALPHABETICAL SECTIONS
                for (var char in letters) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              char,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.softTaupe.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 14,
                        children: grouped[char]!.map((note) {
                          final tint = repo.getVisuals(note)['color'] as Color;
                          return _NoteChip(
                            note: note, 
                            isSelected: false,
                            tint: tint,
                            onTap: () => context.push('/search?note=$note'),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
                
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  final String note;
  final bool isSelected;
  final Color tint;
  final VoidCallback onTap;
  const _NoteChip({
    required this.note,
    this.isSelected = false,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppTheme.accentGold : tint.withValues(alpha: 0.08);
    final borderColor = isSelected ? AppTheme.accentGold : tint.withValues(alpha: 0.3);
    final textColor = isSelected ? Colors.white : AppTheme.deepCharcoal.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 40,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? AppTheme.accentGold.withValues(alpha: 0.3)
                    : tint.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  note,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: hasText ? AppTheme.accentGold.withValues(alpha: 0.4) : AppTheme.softTaupe.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: hasText ? AppTheme.accentGold : AppTheme.mutedSilver.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppTheme.accentGold,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                ),
              ),
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.deepCharcoal,
              ),
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.softTaupe.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

