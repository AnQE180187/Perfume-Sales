import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/journal_provider.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(journalsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.journal.toUpperCase(),
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.deepCharcoal,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            fontSize: 16,
          ),
        ),
      ),
      body: journalsAsync.when(
        data: (journals) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: journals.length,
          itemBuilder: (context, index) {
            final article = journals[index];
            return _JournalCard(article: article);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final dynamic article;
  const _JournalCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.push('/journal/${article.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                article.mainImage,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    (article.category.toLowerCase() == 'all'
                            ? l10n.all
                            : article.category)
                        .toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.readTime(5),
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
                height: 1.3,
              ),
            ),
            if (article.excerpt != null) ...[
              const SizedBox(height: 10),
              Text(
                article.excerpt!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppTheme.mutedSilver,
                  height: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.readMoreUpper,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.deepCharcoal,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
