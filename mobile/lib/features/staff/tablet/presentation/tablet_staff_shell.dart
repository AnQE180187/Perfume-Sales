import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../dashboard/presentation/staff_dashboard_screen.dart';
import '../../returns/presentation/staff_returns_screen.dart';
import '../../pos/presentation/staff_pos_screen.dart';
import '../../inventory/presentation/staff_inventory_screen.dart';
import '../../orders/presentation/staff_orders_screen.dart';
import '../../profile/presentation/staff_profile_screen.dart';
import '../../staff_shell.dart';
import '../../../auth/providers/auth_provider.dart';
import 'tablet_pos_cart.dart';

class TabletStaffShell extends ConsumerWidget {
  const TabletStaffShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ = AppLocalizations.of(context)!;
    final selectedIndex = ref.watch(staffTabIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF030303), // Deeper Obsidian
      body: Stack(
        children: [
          // Molecular Dust Background
          Positioned.fill(child: const _MolecularDustBackground()),
          
          Row(
            children: [
              // 1. Refined Navigation Sidebar
              _BoutiqueSidebar(
                selectedIndex: selectedIndex,
                onChanged: (index) =>
                    ref.read(staffTabIndexProvider.notifier).state = index,
              ),

              // 2. Main Content Area
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white10, width: 0.5),
                          ),
                        ),
                        child: IndexedStack(
                          index: selectedIndex,
                          children: const [
                            StaffDashboardScreen(),
                            StaffPosScreen(),
                            StaffInventoryScreen(),
                            StaffReturnsScreen(),
                            StaffOrdersScreen(),
                            StaffProfileScreen(),
                          ],
                        ),
                      ),
                    ),

                    if (selectedIndex == 1)
                      const Expanded(
                        flex: 3,
                        child: _GlassBillPane(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoutiqueSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _BoutiqueSidebar({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 84, // Slightly wider for ergonomics
      decoration: const BoxDecoration(
        color: Color(0xFF080808),
        border: Border(right: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildLogo(),
          const SizedBox(height: 60),
          _SidebarItem(
            icon: Icons.insights_rounded,
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
            tooltip: l10n.salesReport,
          ),
          _SidebarItem(
            icon: Icons.auto_awesome_mosaic_rounded,
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
            tooltip: l10n.pos,
          ),
          _SidebarItem(
            icon: Icons.inventory_2_outlined,
            isSelected: selectedIndex == 2,
            onTap: () => onChanged(2),
            tooltip: l10n.inventory,
          ),
          _SidebarItem(
            icon: Icons.keyboard_return_rounded,
            isSelected: selectedIndex == 3,
            onTap: () => onChanged(3),
            tooltip: l10n.returnsHistory,
          ),
          _SidebarItem(
            icon: Icons.history_rounded,
            isSelected: selectedIndex == 4,
            onTap: () => onChanged(4),
            tooltip: l10n.ordersHistoryLabel,
          ),
          _SidebarItem(
            icon: Icons.settings_rounded,
            isSelected: selectedIndex == 5,
            onTap: () => onChanged(5),
            tooltip: l10n.profileLabel,
          ),
          const Spacer(),
          Consumer(builder: (ctx, ref, _) => _LogoutGhostBtn(onTap: () => _confirmLogout(ctx, ref, l10n))),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.5), width: 0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'L',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.accentGold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const _SidebarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 64,
            width: double.infinity,
            color: _isHovered && !widget.isSelected
                ? Colors.white.withOpacity(0.03)
                : Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vertical gold light bar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: 0,
                  top: widget.isSelected ? 16 : 28,
                  bottom: widget.isSelected ? 16 : 28,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: widget.isSelected ? 3 : 0,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                  color: AppTheme.accentGold.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1),
                            ]
                          : [],
                    ),
                  ),
                ),

                // Icon with animated color
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: const TextStyle(),
                  child: Icon(
                    widget.icon,
                    color: widget.isSelected
                        ? AppTheme.accentGold
                        : _isHovered
                            ? Colors.white60
                            : Colors.white24,
                    size: 24,
                  ),
                ),

                // Glow effect
                if (widget.isSelected || _isHovered)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentGold
                              .withOpacity(widget.isSelected ? 0.1 : 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutGhostBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoutGhostBtn({required this.onTap});

  @override
  State<_LogoutGhostBtn> createState() => _LogoutGhostBtnState();
}

class _LogoutGhostBtnState extends State<_LogoutGhostBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? Colors.redAccent.withOpacity(0.08)
                : Colors.transparent,
          ),
          child: Icon(
            Icons.power_settings_new_rounded,
            color: _isHovered
                ? Colors.redAccent.withOpacity(0.8)
                : Colors.redAccent.withOpacity(0.4),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _MolecularDustBackground extends StatefulWidget {
  const _MolecularDustBackground();
  @override
  State<_MolecularDustBackground> createState() => _MolecularDustBackgroundState();
}

class _MolecularDustBackgroundState extends State<_MolecularDustBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: _DustPainter(_controller.value));
      },
    );
  }
}

class _DustPainter extends CustomPainter {
  final double progress;
  _DustPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05);
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double s = random.nextDouble() * 2 + 0.5;
      
      // Subtle movement
      y = (y + progress * size.height * (random.nextDouble() * 0.1)) % size.height;
      
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(_DustPainter oldDelegate) => true;
}

class _GlassBillPane extends StatelessWidget {
  const _GlassBillPane();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.01),
            border: const Border(left: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: const TabletPosCart(),
        ),
      ),
    );
  }
}


void _confirmLogout(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5)),
        title: Text(l10n.terminateSession.toUpperCase(),
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFD4AF37),
                letterSpacing: 2)),
        content: Text(l10n.terminateSessionConfirm,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel.toUpperCase(),
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white24,
                    letterSpacing: 1)),
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                side: const BorderSide(color: Colors.redAccent, width: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authControllerProvider.notifier).logout();
              },
              child: Text(l10n.logout.toUpperCase(),
                  style: GoogleFonts.montserrat(
                      fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    ),
  );
}
