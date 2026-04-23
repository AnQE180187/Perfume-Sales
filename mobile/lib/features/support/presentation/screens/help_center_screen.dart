import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../l10n/app_localizations.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static List<Map<String, dynamic>> _getCategories(AppLocalizations l10n) => [
    {
      'id': 'don-hang',
      'icon': Icons.shopping_bag_outlined,
      'title': l10n.catOrders
    },
    {
      'id': 'thanh-toan',
      'icon': Icons.payment_outlined,
      'title': l10n.catPayments
    },
    {
      'id': 'van-chuyen',
      'icon': Icons.local_shipping_outlined,
      'title': l10n.catShipping
    },
    {
      'id': 'ai-tu-van',
      'icon': Icons.auto_awesome_outlined,
      'title': l10n.catAiConsult
    },
    {'id': 'tai-khoan', 'icon': Icons.person_outline_rounded, 'title': l10n.catAccount},
  ];

  static List<Map<String, String>> _getFaqs(AppLocalizations l10n) => [
    {
      'question': l10n.faq1Question,
      'answer': l10n.faq1Answer
    },
    {
      'question': l10n.faq2Question,
      'answer': l10n.faq2Answer
    },
    {
      'question': l10n.faq3Question,
      'answer': l10n.faq3Answer
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);
    final faqs = _getFaqs(l10n);

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
          l10n.helpCenterTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Search Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.howCanWeHelp,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.mutedSilver,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.searchIssueHint,
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: const Icon(Icons.search_rounded,
                            color: AppTheme.mutedSilver, size: 20),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FAQ Categories
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = categories[index];
                  return _buildCategoryCard(
                    context,
                    cat['icon'] as IconData,
                    cat['title'] as String,
                    cat['id'] as String,
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),

          // Common Questions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
              child: Text(
                l10n.faqTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppTheme.mutedSilver,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final faq = faqs[index];
                return _buildExpandableFaqItem(faq['question']!, faq['answer']!);
              },
              childCount: faqs.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, IconData icon, String title, String id) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.helpArticleWithId(id)),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.ivoryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.deepCharcoal, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
          ),
          trailing: const Icon(Icons.expand_more_rounded,
              color: AppTheme.mutedSilver, size: 20),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              answer,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                height: 1.6,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
