import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/product/presentation/explore_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/consultation/presentation/consultation_screen.dart';
import '../../features/membership/presentation/profile_screen.dart';
import '../theme/app_theme.dart';
import 'luxury_drawer.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SizedBox.shrink(), // Placeholder for FAB (AI)
    AlertsScreen(),
    ProfileScreen(),
  ];

  void _openConsultation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ConsultationScreen(),
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
      floatingActionButton: Container(
        height: 68,
        width: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openConsultation,
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          child: Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.champagneGold,
                  AppTheme.accentGold,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
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
    return Row(
      children: [
        // Left side
        _buildItem(0, Icons.home_outlined, Icons.home_rounded, 'MAISON'),
        _buildItem(1, Icons.explore_outlined, Icons.explore_rounded, 'EXPLORE'),

        // Middle gap for FAB
        const SizedBox(width: 80),

        // Right side
        _buildItem(3, Icons.notifications_outlined, Icons.notifications_rounded, 'ALERTS'),
        _buildItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'PROFILE'),
      ],
    );
  }

  Widget _buildItem(int index, IconData icon, IconData activeIcon, String label) {
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
    final inactiveColor = const Color(0xFF666666); // Higher contrast medium grey

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
