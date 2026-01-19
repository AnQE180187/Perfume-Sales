import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/product/presentation/collection_screen.dart';
import '../../features/consultation/presentation/consultation_screen.dart';
import '../../features/membership/presentation/rewards_screen.dart';
import '../../features/membership/presentation/profile_screen.dart';
import '../theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CollectionScreen(),
    const ConsultationScreen(),
    const RewardsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0), // Sharp luxury edges
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.charcoal.withValues(alpha: 0.8),
                  border: Border.all(
                    color: AppTheme.glassBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                      isSelected: _selectedIndex == 0,
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                    _NavBarItem(
                      icon: Icons.auto_awesome_outlined,
                      activeIcon: Icons.auto_awesome_rounded,
                      isSelected: _selectedIndex == 1,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    _NavBarItem(
                      icon: Icons.military_tech_outlined,
                      activeIcon: Icons.military_tech_rounded,
                      isSelected: _selectedIndex == 2,
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                    _NavBarItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      isSelected: _selectedIndex == 3,
                      onTap: () => setState(() => _selectedIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isSelected ? AppTheme.champagneGold : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.champagneGold : AppTheme.mutedSilver,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

