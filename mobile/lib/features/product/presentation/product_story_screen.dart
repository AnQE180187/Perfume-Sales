import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/product_provider.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

class ProductStoryScreen extends ConsumerWidget {
  final String productId;
  final String productName;
  final String imageUrl;

  const ProductStoryScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: productAsync.when(
        loading: () => _buildLoadingState(context),
        error: (err, _) => _buildErrorState(context, err.toString()),
        data: (product) {
          final storyText = product.story ?? '';
          final paragraphs = storyText
              .split('\n\n')
              .where((s) => s.trim().isNotEmpty)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.ivoryBackground,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.deepCharcoal),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    l10n.storyHeader,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _HeroImage(
                      imageUrl: product.imageUrl.isNotEmpty
                          ? product.imageUrl
                          : imageUrl,
                    ),
                    const SizedBox(height: 50),
                    if (paragraphs.isNotEmpty) ...[
                      _StorySection(
                        label: l10n.storyInspiration,
                        children: [
                          _DropCapParagraph(text: paragraphs[0]),
                          if (paragraphs.length > 1) ...[
                            const SizedBox(height: 20),
                            _BodyText(text: paragraphs[1]),
                          ],
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                    if (paragraphs.length > 2) ...[
                      _Divider(),
                      const SizedBox(height: 50),
                      _StorySection(
                        label: l10n.storyCraftsmanship,
                        children: [
                          _BodyText(text: paragraphs[2]),
                          if (paragraphs.length > 3) ...[
                            const SizedBox(height: 20),
                            _BodyText(text: paragraphs[3]),
                          ],
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                    if (paragraphs.length > 4) ...[
                      _QuoteBlock(
                        quote: paragraphs[4],
                        author: product.brand,
                      ),
                      const SizedBox(height: 60),
                    ] else if (paragraphs.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 80),
                        child: Text(
                          l10n.informationPending,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: AppTheme.mutedSilver,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    _FooterActions(productId: productId),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShimmerBox(
                  height: 400,
                  borderRadius: AppRadius.lg,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 100, height: 12),
                    SizedBox(height: 20),
                    ShimmerBox(height: 20),
                    SizedBox(height: 10),
                    ShimmerBox(height: 20),
                    SizedBox(height: 10),
                    ShimmerBox(width: 200, height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.mutedSilver,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: GoogleFonts.montserrat(color: AppTheme.deepCharcoal),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String imageUrl;

  const _HeroImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1A1A1A),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 60,
                color: AppTheme.mutedSilver,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _StorySection({super.key, required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _DropCapParagraph extends StatelessWidget {
  final String text;

  const _DropCapParagraph({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    
    final firstLetter = text.substring(0, 1);
    final restOfText = text.substring(1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstLetter,
          style: GoogleFonts.playfairDisplay(
            fontSize: 72,
            fontWeight: FontWeight.w600,
            height: 0.9,
            color: AppTheme.accentGold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                restOfText,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.75,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.75,
        color: AppTheme.deepCharcoal,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Dot(),
          const SizedBox(width: 12),
          _Dot(),
          const SizedBox(width: 12),
          _Dot(),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _EditorialImage extends StatelessWidget {
  final String imageUrl;
  final String caption;

  const _EditorialImage({
    super.key,
    required this.imageUrl,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 280,
                color: const Color(0xFFF5F1ED),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            caption,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppTheme.mutedSilver,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  final String quote;
  final String author;

  const _QuoteBlock({super.key, required this.quote, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            '"$quote"',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '— $author',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              color: AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterActions extends StatelessWidget {
  final String productId;

  const _FooterActions({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          LuxuryButton(
            text: l10n.backToProductStory,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Navigate to scent notes
            },
            child: Text(
              l10n.discoverNotesStory,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppTheme.mutedSilver,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
