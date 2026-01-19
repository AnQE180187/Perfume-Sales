import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getLuxuryGradient(brightness),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Theme.of(context).primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EVELYN\'S PASS',
                        style: TextStyle(letterSpacing: 8, color: Theme.of(context).primaryColor, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Diamond Member',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GlassContainer(
                  padding: const EdgeInsets.all(30),
                  opacity: 0.1,
                  borderRadius: 8,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Points: 8,500', 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          ),
                          Text(
                            'Next Tier: 10,000', 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), 
                              fontSize: 12,
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: 0.85,
                        backgroundColor: Theme.of(context).colorScheme.outline,
                        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'EXCLUSIVE PRIVILEGES',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            
            SliverList(
              delegate: SliverChildListDelegate([
                const PrivilegeTile(title: "Early Access: Grasse Batch #042", icon: Icons.lock_open),
                const PrivilegeTile(title: "Personal Concierge Service", icon: Icons.person_search),
                const PrivilegeTile(title: "Complimentary Molecule Stability Test", icon: Icons.biotech),
                const PrivilegeTile(title: "Invitations to Private Atelier Events", icon: Icons.celebration),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivilegeTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const PrivilegeTile({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        opacity: 0.05,
        borderRadius: 8,
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 20),
            Text(
              title, 
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              )
            ),
          ],
        ),
      ),
    );
  }
}
