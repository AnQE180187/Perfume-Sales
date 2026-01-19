import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../checkout/presentation/checkout_screen.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image with Parallax-like effect
              SliverAppBar(
                expandedHeight: 520,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product_image',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=1000&auto=format&fit=crop',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.4),
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.luminaAtelier.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 10,
                          letterSpacing: 4,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'NOIR ÉLIXIR',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
                            ),
                          ),
                          Text(
                            '\$280',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 28,
                              color: AppTheme.champagneGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Intensity Scale
                      Text(l10n.intensity.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) => Container(
                          width: 40,
                          height: 2,
                          margin: const EdgeInsets.only(right: 8),
                          color: index < 4 ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.outline,
                        )),
                      ),
                      const SizedBox(height: 48),

                      // AI INSIGHT
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.neuralInsight.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'This formulation aligns with your preference for high molecular stability. The base notes of Oud and Tobacco trigger a 14% higher alpha-wave response based on your sensory profile.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      Text(l10n.scentProfile.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                      const SizedBox(height: 24),
                      _NoteRow(label: l10n.topNotes.toUpperCase(), items: 'Petitgrain, Calabrian Bergamot'),
                      _NoteRow(label: l10n.heartNotes.toUpperCase(), items: 'Damask Rose, Pink Pepper'),
                      _NoteRow(label: l10n.baseNotes.toUpperCase(), items: 'Oud, Tobacco, Molecular Musk'),
                      
                      const SizedBox(height: 48),
                      Text(l10n.theStory.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                      const SizedBox(height: 16),
                      Text(
                        'A nocturnal masterpiece. Noir Élixir captures the ephemeral moment when the moon illuminates a secret garden. It is a scent designed for those who navigate the world with quiet confidence.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Fixed Bottom CTA
          Positioned(
            bottom: 30,
            left: 32,
            right: 32,
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen())),
                child: Text(l10n.acquireScent.toUpperCase()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String label;
  final String items;
  const _NoteRow({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
            ),
          ),
          Expanded(
            child: Text(
              items,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
