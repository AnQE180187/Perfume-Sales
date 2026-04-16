import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/core/theme/app_theme.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ScentClubScreen extends StatefulWidget {
  const ScentClubScreen({super.key});

  @override
  State<ScentClubScreen> createState() => _ScentClubScreenState();
}

class _ScentClubScreenState extends State<ScentClubScreen> {
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
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final isVi = lang == 'vi';

    final groups = _groups(isVi: isVi);
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? groups
        : groups.where((g) {
            return g.title.toLowerCase().contains(q) ||
                g.subtitle.toLowerCase().contains(q) ||
                g.keywords.any((k) => k.toLowerCase().contains(q));
          }).toList(growable: false);

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
        child: CustomScrollView(
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
        onTap: () => context.push('/search?scent=${group.id}'),
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
      title: isVi ? 'Hương Hoa' : 'Floral',
      subtitle: isVi ? 'Mềm mại, nữ tính, thanh lịch.' : 'Soft, elegant, romantic.',
      tint: const Color(0xFF8A7BD6), // muted lavender
      icon: Icons.local_florist_outlined,
      chips: isVi ? const ['Rose', 'Jasmine', 'Iris'] : const ['Rose', 'Jasmine', 'Iris'],
      keywords: const ['floral', 'rose', 'jasmine', 'iris', 'hoa', 'hương hoa'],
    ),
    _ScentGroup(
      id: 'woody',
      title: isVi ? 'Hương Gỗ' : 'Woody',
      subtitle: isVi ? 'Ấm áp, sang, vững chãi.' : 'Warm, refined, grounded.',
      tint: const Color(0xFFB07A5A), // softened terracotta-wood
      icon: Icons.park_outlined,
      chips: isVi ? const ['Cedar', 'Sandalwood', 'Oud'] : const ['Cedar', 'Sandalwood', 'Oud'],
      keywords: const ['woody', 'cedar', 'sandalwood', 'oud', 'gỗ', 'huong go'],
    ),
    _ScentGroup(
      id: 'fresh',
      title: isVi ? 'Hương Tươi Mát' : 'Fresh',
      subtitle: isVi ? 'Sạch, mát, dễ dùng hằng ngày.' : 'Clean, airy, everyday.',
      tint: const Color(0xFF6FA6A0), // muted sage-teal
      icon: Icons.water_drop_outlined,
      chips: isVi ? const ['Citrus', 'Green', 'Aqua'] : const ['Citrus', 'Green', 'Aqua'],
      keywords: const ['fresh', 'citrus', 'green', 'aqua', 'tươi mát', 'tuoi mat'],
    ),
    _ScentGroup(
      id: 'gourmand',
      title: isVi ? 'Hương Ngọt' : 'Gourmand',
      subtitle: isVi ? 'Ngọt ấm, “kẹo” và quyến rũ.' : 'Sweet, cozy, addictive.',
      tint: const Color(0xFFC98B7E), // muted terracotta
      icon: Icons.icecream_outlined,
      chips: isVi ? const ['Vanilla', 'Caramel', 'Honey'] : const ['Vanilla', 'Caramel', 'Honey'],
      keywords: const ['sweet', 'gourmand', 'vanilla', 'caramel', 'honey', 'ngọt', 'huong ngot'],
    ),
    _ScentGroup(
      id: 'spicy',
      title: isVi ? 'Hương Cay Nồng' : 'Spicy',
      subtitle: isVi ? 'Cá tính, nổi bật, ấn tượng.' : 'Bold, vibrant, statement.',
      tint: const Color(0xFFB96D63), // muted warm spice
      icon: Icons.local_fire_department_outlined,
      chips: isVi ? const ['Pepper', 'Cardamom', 'Cinnamon'] : const ['Pepper', 'Cardamom', 'Cinnamon'],
      keywords: const ['spicy', 'pepper', 'cardamom', 'cinnamon', 'cay', 'nồng'],
    ),
    _ScentGroup(
      id: 'citrus',
      title: isVi ? 'Hương Cam Chanh' : 'Citrus',
      subtitle: isVi ? 'Sảng khoái, sáng bừng, năng động.' : 'Sparkling, bright, uplifting.',
      tint: const Color(0xFFC7A86A), // muted gold-citrus
      icon: Icons.wb_sunny_outlined,
      chips: isVi ? const ['Bergamot', 'Lemon', 'Orange'] : const ['Bergamot', 'Lemon', 'Orange'],
      keywords: const ['citrus', 'bergamot', 'lemon', 'orange', 'cam', 'chanh'],
    ),
    _ScentGroup(
      id: 'musk',
      title: isVi ? 'Xạ Hương' : 'Musk',
      subtitle: isVi ? 'Mịn, sạch, “skin scent” tinh tế.' : 'Soft, clean, skin-like.',
      tint: const Color(0xFF6C7A89),
      icon: Icons.blur_on_outlined,
      chips: isVi ? const ['White musk', 'Clean', 'Powder'] : const ['White musk', 'Clean', 'Powder'],
      keywords: const ['musk', 'xạ', 'xa huong', 'powder', 'clean'],
    ),
    _ScentGroup(
      id: 'amber',
      title: isVi ? 'Hổ Phách' : 'Amber',
      subtitle: isVi ? 'Ngọt ấm, sâu, giàu cảm xúc.' : 'Warm, deep, sensual.',
      tint: const Color(0xFF8E5E2A),
      icon: Icons.auto_awesome_outlined,
      chips: isVi ? const ['Amber', 'Resin', 'Balsamic'] : const ['Amber', 'Resin', 'Balsamic'],
      keywords: const ['amber', 'resin', 'balsamic', 'hổ phách', 'ho phach'],
    ),
  ];
}

