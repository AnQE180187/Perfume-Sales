import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/journal_provider.dart';

class JournalDetailScreen extends ConsumerWidget {
  final String journalId;
  const JournalDetailScreen({super.key, required this.journalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalDetailProvider(journalId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: journalAsync.when(
        data: (journal) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Image.network(
                    journal.mainImage,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const BackButton(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 60,
              title: Text(
                journal.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (journal.category.toLowerCase() == 'all'
                              ? l10n.all
                              : journal.category)
                          .toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      journal.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepCharcoal,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.softTaupe, thickness: 0.5),
                    const SizedBox(height: 32),
                    ...journal.sections.map((section) => _buildSection(section)),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSection(dynamic section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.subtitle != null) ...[
            Text(
              section.subtitle!,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            section.content,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
              height: 1.8,
            ),
          ),
          if (section.imageUrl != null) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                section.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
