import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../product/providers/product_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/product_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalizedProducts = ref.watch(personalizedProductsProvider);
    final recommendedProducts = ref.watch(recommendedProductsProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with Search
            const SliverToBoxAdapter(
              child: HomeHeader(),
            ),

            // Personalized Selection
            SliverToBoxAdapter(
              child: ProductSection(
                title: 'PERSONALIZED SELECTION',
                productsAsync: personalizedProducts,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Tailored Recommendations
            SliverToBoxAdapter(
              child: ProductSection(
                title: 'TAILORED RECOMMENDATIONS',
                actionText: 'VIEW COLLECTION',
                productsAsync: recommendedProducts,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
