import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../../features/product/presentation/product_story_screen.dart';

class ProductStorySection extends StatelessWidget {
  final String? description;
  final String productId;
  final String productName;
  final String imageUrl;

  const ProductStorySection({
    super.key,
    this.description,
    required this.productId,
    required this.productName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Story',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description ??
                  'Before it was a perfume, it was the name of a rebel. A woman who changed the rules. This floral, and voluptuous fragrance is composed around four flowers: exotic Jasmine, fruity Ylang-Ylang, fresh Orange Blossom, and creamy Tuberose.',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                height: 1.6,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.75),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductStoryScreen(
                      productId: productId,
                      productName: productName,
                      imageUrl: imageUrl,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read full story',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: AppTheme.accentGold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
