import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class HelpArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const HelpArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final article = _getArticleData(articleId, l10n);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.deepCharcoal, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          (article['category'] as String).toUpperCase(),
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? '',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 24),
            ..._buildContent(article['content'] as String),
            const SizedBox(height: 48),
            _buildRelatedSection(l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(String content) {
    final lines = content.split('\n');
    return lines.map((line) {
      if (line.trim().startsWith('•')) {
        return _bullet(line.trim().substring(1).trim());
      }
      return _paragraph(line.trim());
    }).toList();
  }

  Widget _buildRelatedSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isHelpful,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildVoteButton(Icons.thumb_up_outlined, l10n.yes),
              const SizedBox(width: 12),
              _buildVoteButton(Icons.thumb_down_outlined, l10n.no),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.deepCharcoal,
          side: BorderSide(color: AppTheme.mutedSilver.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Map<String, dynamic> _getArticleData(String id, AppLocalizations l10n) {
    switch (id) {
      case 'don-hang':
        return {
          'category': l10n.catOrders,
          'title': l10n.artOrdersTitle,
          'content': l10n.artOrdersContent,
        };
      case 'thanh-toan':
        return {
          'category': l10n.catPayments,
          'title': l10n.artPaymentsTitle,
          'content': l10n.artPaymentsContent,
        };
      case 'van-chuyen':
        return {
          'category': l10n.catShipping,
          'title': l10n.artShippingTitle,
          'content': l10n.artShippingContent,
        };
      case 'ai-tu-van':
        return {
          'category': l10n.catAiConsult,
          'title': l10n.artAiTitle,
          'content': l10n.artAiContent,
        };
      case 'tai-khoan':
        return {
          'category': l10n.catAccount,
          'title': l10n.artAccountTitle,
          'content': l10n.artAccountContent,
        };
      default:
        return {
          'category': l10n.help,
          'title': l10n.help,
          'content': l10n.responseTime5m,
        };
    }
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          height: 1.6,
          color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
