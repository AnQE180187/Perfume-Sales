import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/luxury_button.dart';

class ProductStoryScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: CustomScrollView(
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
                'The Story Behind the Scent',
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
                _HeroImage(imageUrl: imageUrl),
                const SizedBox(height: 50),
                _StorySection(
                  label: 'THE INSPIRATION',
                  children: [
                    _DropCapParagraph(
                      text:
                          'It began in a rainy garden in Kyoto. The scent of wet earth mixed with blooming jasmine created a moment of pure stillness that we knew had to be captured. We sought to bottle not just the fragrance, but the profound silence of that afternoon, where time seemed to suspend itself among the moss-covered stones.',
                    ),
                    const SizedBox(height: 20),
                    _BodyText(
                      text:
                          'The journey took us across continents, searching for a jasmine absolute that could replicate that specific, dewy freshness without becoming overpowering. It is a delicate balance of nature and memory.',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _Divider(),
                const SizedBox(height: 50),
                _StorySection(
                  label: 'CRAFTSMANSHIP',
                  children: [
                    _BodyText(
                      text:
                          'Our master perfumers employ the ancient technique of enfleurage, a painstaking process rarely used in modern perfumery due to its labor-intensive nature. Petal by petal, the essence is coaxed gently, preserving the soul of the flower in its purest form.',
                    ),
                    const SizedBox(height: 20),
                    _BodyText(
                      text:
                          'This dedication to slow craft ensures that every bottle contains the depth, warmth and complexity that synthetic compounds simply cannot replicate. It is a testament to patience and the pursuit of perfection.',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _EditorialImage(
                  imageUrl: 'https://images.unsplash.com/photo-1615634260167-c8cdede054de',
                  caption: 'Hand-picked jasmine at dawn',
                ),
                const SizedBox(height: 50),
                _QuoteBlock(
                  quote: 'A perfume is a story in odors, sometimes a poetry of memory.',
                  author: 'Jean-Claude Ellena',
                ),
                const SizedBox(height: 60),
                _FooterActions(productId: productId),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String imageUrl;

  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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

  const _StorySection({
    required this.label,
    required this.children,
  });

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

  const _DropCapParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
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
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 1.7,
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

  const _BodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: AppTheme.deepCharcoal,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialImage extends StatelessWidget {
  final String imageUrl;
  final String caption;

  const _EditorialImage({
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
            style: GoogleFonts.cormorantGaramond(
              fontSize: 13,
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

  const _QuoteBlock({
    required this.quote,
    required this.author,
  });

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

  const _FooterActions({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          LuxuryButton(
            text: 'Back to Product',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Navigate to scent notes
            },
            child: Text(
              'EXPLORE THE SCENT NOTES',
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
