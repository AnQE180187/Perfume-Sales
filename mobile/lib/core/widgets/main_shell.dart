import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/product/presentation/explore_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/consultation/presentation/consultation_screen.dart';
import '../../features/membership/presentation/profile_screen.dart';
import '../theme/app_theme.dart';
import 'luxury_drawer.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_routes.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _aiController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _aiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slightly faster for punchier feel
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 4, end: -12).animate(
      CurvedAnimation(parent: _aiController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _aiController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _aiController, curve: Curves.linear),
    );

    _glowAnimation = Tween<double>(begin: 10.0, end: 40.0).animate(
      CurvedAnimation(parent: _aiController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _aiController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SizedBox.shrink(), // Placeholder for FAB (AI)
    AlertsScreen(),
    ProfileScreen(),
  ];

  void _openConsultation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConsultationScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: const LuxuryDrawer(),

      // ================= BODY =================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: IndexedStack(
          key: ValueKey(_selectedIndex),
          index: _selectedIndex,
          children: _screens,
        ),
      ),

      // ================= FLOATING AI BUTTON =================
      floatingActionButton: AnimatedBuilder(
        animation: _aiController,
        builder: (context, child) {
          final shimmerValue = _shimmerAnimation.value;
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.25),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value / 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: _glowAnimation.value * 1.5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _openConsultation,
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  child: Center(
                    child: SizedBox(
                      width: 95,
                      height: 95,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [
                            (shimmerValue - 0.2).clamp(0.0, 1.0),
                            shimmerValue.clamp(0.0, 1.0),
                            (shimmerValue + 0.2).clamp(0.0, 1.0),
                          ],
                          colors: const [
                            AppTheme.accentGold,
                            Colors.white, // The "Dazzle" Light
                            AppTheme.accentGold,
                          ],
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            1, 1, 1, 0, -110,
                            1, 1, 1, 0, -110,
                            1, 1, 1, 0, -110,
                            2, 2, 2, 0, -180,
                          ]),
                          child: Image.asset(
                            'assets/icons/ai_consultation_dark.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomAppBar(
        height: 75,
        color: AppTheme.creamWhite.withValues(alpha: 0.95),
        padding: EdgeInsets.zero,
        notchMargin: 10,
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        elevation: 20,
        child: _LuxuryBottomNavBar(
          currentIndex: _selectedIndex,
          onChanged: (index) {
            if (index == 2) return;
            if (index == 1) {
              // Navigate to Quiz screen (scent quiz)
              context.push(AppRoutes.quiz);
              return;
            }
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BOTTOM NAV BAR (Custom Row for Notched Bar)
// ---------------------------------------------------------------------------

class _LuxuryBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _LuxuryBottomNavBar({
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Left side
        _buildItem(0, Icons.home_outlined, Icons.home_rounded, l10n.navHome),
        _buildItem(1, Icons.quiz_outlined, Icons.quiz_rounded, l10n.scentQuiz),

        // Middle gap for FAB
        const SizedBox(width: 80),

        // Right side
        _buildItem(
          3,
          Icons.notifications_outlined,
          Icons.notifications_rounded,
          l10n.navAlerts,
        ),
        _buildItem(
          4,
          Icons.person_outline_rounded,
          Icons.person_rounded,
          l10n.navProfile,
        ),
      ],
    );
  }

  Widget _buildItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return Expanded(
      child: _NavBarItem(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        isSelected: currentIndex == index,
        onTap: () => onChanged(index),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NAV BAR ITEM
// ---------------------------------------------------------------------------

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = const Color(
      0xFF666666,
    ); // Higher contrast medium grey

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 20,
            color: isSelected ? AppTheme.accentGold : inactiveColor,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: isSelected
                ? GoogleFonts.playfairDisplay(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.accentGold,
                  )
                : GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: inactiveColor,
                  ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppTheme.accentGold,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
