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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scentFamiliesAsync = ref.watch(scentFamiliesProvider);
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
        child: scentFamiliesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
          error: (err, _) => Center(child: Text('Lỗi: $err')),
          data: (families) {
            final groups = families.map((f) {
              final visuals = repo.getVisuals(f.name);
              // Try to find a hardcoded match for chips/keywords, otherwise generic
              final match = _groups(isVi: true).firstWhere(
                (g) => g.title.toLowerCase() == f.name.toLowerCase() || f.name.toLowerCase().contains(g.id),
                orElse: () => _ScentGroup(
                  id: f.id.toString(),
                  title: f.name,
                  subtitle: f.description ?? '',
                  tint: visuals['color'],
                  icon: visuals['icon'],
                  chips: [],
                  keywords: [f.name.toLowerCase()],
                ),
              );
              
              return _ScentGroup(
                id: f.id.toString(),
                title: f.name,
                subtitle: f.description ?? match.subtitle,
                tint: visuals['color'],
                icon: visuals['icon'],
                chips: match.chips,
                keywords: [f.name.toLowerCase(), ...match.keywords],
              );
            }).toList();

            final q = _query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? groups
                : groups.where((g) {
                    return g.title.toLowerCase().contains(q) ||
                        g.subtitle.toLowerCase().contains(q) ||
                        g.keywords.any((k) => k.toLowerCase().contains(q));
                  }).toList(growable: false);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.scentFamily,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '(${filtered.length})',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedSilver,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color:
                                  AppTheme.mutedSilver.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.noProductsFound,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: AppTheme.mutedSilver,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 230,
                        childAspectRatio: 0.92,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final g = filtered[index];
                          return _ScentGroupCard(group: g);
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppTheme.softTaupe.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 18,
            color: AppTheme.mutedSilver.withValues(alpha: 0.65),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                ),
              ),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.deepCharcoal,
              ),
            ),
          ),
          if (hasText)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppTheme.mutedSilver.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScentGroupCard extends StatelessWidget {
  final _ScentGroup group;

  const _ScentGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final border = AppTheme.accentGold.withValues(alpha: 0.16);
    final glass = const Color(0xFFF7F1E6).withValues(alpha: 0.72);
    final highlight = const Color(0xFFFFFFFF).withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/search?scent=${group.title}&scentId=${group.id}'),
        borderRadius: BorderRadius.circular(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: glass,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border, width: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.03),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Editorial highlight (very subtle)
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: highlight,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IconMark(group: group),
                        const SizedBox(height: 12),
                        Text(
                          group.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16.5,
                            height: 1.12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepCharcoal,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            group.subtitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.2,
                              height: 1.65,
                              fontWeight: FontWeight.w400,
                              color:
                                  AppTheme.deepCharcoal.withValues(alpha: 0.66),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ChipsRow(group: group),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconMark extends StatelessWidget {
  final _ScentGroup group;
  const _IconMark({required this.group});

  @override
  Widget build(BuildContext context) {
    final ring = group.tint.withValues(alpha: 0.22);
    final fill = const Color(0xFFFFFFFF).withValues(alpha: 0.28);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: ring, width: 0.9),
      ),
      child: Icon(
        group.icon,
        color: group.tint.withValues(alpha: 0.9),
        size: 20,
      ),
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final _ScentGroup group;
  const _ChipsRow({required this.group});

  @override
  Widget build(BuildContext context) {
    final pillBg = AppTheme.creamWhite.withValues(alpha: 0.22);
    final pillBorder = group.tint.withValues(alpha: 0.20);
    final pillText = AppTheme.deepCharcoal.withValues(alpha: 0.72);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: group.chips.take(3).map((c) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: pillBorder, width: 0.7),
          ),
          child: Text(
            c,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: pillText,
              letterSpacing: 0.2,
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _ScentGroup {
  final String id;
  final String title;
  final String subtitle;
  final Color tint;
  final IconData icon;
  final List<String> chips;
  final List<String> keywords;

  const _ScentGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.icon,
    required this.chips,
    required this.keywords,
  });
}

List<_ScentGroup> _groups({required bool isVi}) {
  // NOTE: UI-first: these are curated “nhóm mùi” presets.
  // Later we can wire this to backend taxonomy without changing the UI.
  return [
    _ScentGroup(
      id: 'floral',
      title: 'Floral',
      subtitle: isVi ? 'Mềm mại, nữ tính, thanh lịch.' : 'Soft, elegant, romantic.',
      tint: const Color(0xFF8A7BD6),
      icon: Icons.local_florist_outlined,
      chips: const ['Rose', 'Jasmine', 'Iris'],
      keywords: const ['floral', 'rose', 'jasmine', 'iris', 'hoa'],
    ),
    _ScentGroup(
      id: 'oriental',
      title: 'Oriental',
      subtitle: isVi ? 'Hương đông phương quyến rũ, huyền bí.' : 'Exotic, sensual, mysterious.',
      tint: const Color(0xFFC98B7E),
      icon: Icons.auto_awesome_outlined,
      chips: const ['Amber', 'Vanilla', 'Spices'],
      keywords: const ['oriental', 'amber', 'vanilla', 'spices'],
    ),
    _ScentGroup(
      id: 'woody',
      title: 'Woody',
      subtitle: isVi ? 'Ấm áp, sang trọng, vững chãi.' : 'Warm, refined, grounded.',
      tint: const Color(0xFFB07A5A),
      icon: Icons.park_outlined,
      chips: const ['Cedar', 'Sandalwood', 'Oud'],
      keywords: const ['woody', 'cedar', 'sandalwood', 'oud', 'gỗ'],
    ),
    _ScentGroup(
      id: 'citrus',
      title: 'Citrus',
      subtitle: isVi ? 'Sảng khoái, năng động, tươi mới.' : 'Sparkling, bright, uplifting.',
      tint: const Color(0xFFC7A86A),
      icon: Icons.wb_sunny_outlined,
      chips: const ['Bergamot', 'Lemon', 'Orange'],
      keywords: const ['citrus', 'bergamot', 'lemon', 'orange', 'cam', 'chanh'],
    ),
    _ScentGroup(
      id: 'leather',
      title: 'Leather',
      subtitle: isVi ? 'Mạnh mẽ, cá tính, đẳng cấp.' : 'Bold, smoky, sophisticated.',
      tint: const Color(0xFF6C4F3D),
      icon: Icons.work_outline_rounded,
      chips: const ['Leather', 'Suede', 'Birch'],
      keywords: const ['leather', 'suede', 'birch', 'da thuộc'],
    ),
    _ScentGroup(
      id: 'fougere',
      title: 'Fougere',
      subtitle: isVi ? 'Thảo mộc, nam tính, cổ điển.' : 'Aromatic, masculine, classic.',
      tint: const Color(0xFF4A6741),
      icon: Icons.grass_rounded,
      chips: const ['Lavender', 'Oakmoss', 'Coumarin'],
      keywords: const ['fougere', 'lavender', 'oakmoss', 'dương xỉ'],
    ),
    _ScentGroup(
      id: 'aquatic',
      title: 'Aquatic',
      subtitle: isVi ? 'Tươi mát như hơi thở đại dương.' : 'Fresh, watery, oceanic.',
      tint: const Color(0xFF6FA6A0),
      icon: Icons.water_drop_outlined,
      chips: const ['Sea water', 'Salt', 'Algae'],
      keywords: const ['aquatic', 'sea', 'ocean', 'nước'],
    ),
  ];
}

