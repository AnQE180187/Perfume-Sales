import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/providers/profile_provider.dart';
import '../pos/providers/pos_provider.dart';
import '../dashboard/presentation/staff_dashboard_screen.dart';
import '../inventory/presentation/staff_inventory_screen.dart';
import '../orders/presentation/staff_orders_screen.dart';
import '../pos/presentation/staff_pos_screen.dart';
import '../profile/presentation/staff_profile_screen.dart';
import '../returns/presentation/staff_returns_screen.dart';
import '../tablet/presentation/tablet_pos_cart.dart';
import '../staff_shell.dart';

class MobileStaffShell extends ConsumerWidget {
  const MobileStaffShell({super.key});

  /// Mobile only has 5 bottom tabs (0-4). Profile is accessed via avatar button.
  /// Tablet sidebar has 6 tabs (0-5). We clamp the shared index for mobile.
  static const int _mobileTabCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rawIndex = ref.watch(staffTabIndexProvider);
    // Clamp to valid mobile range — if tablet sets index=5 (Profile), stay at 0
    final selectedIndex = rawIndex.clamp(0, _mobileTabCount - 1);

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: const [
              StaffDashboardScreen(),
              StaffPosScreen(),
              StaffInventoryScreen(),
              StaffReturnsScreen(),
              StaffOrdersScreen(),
            ],
          ),
          // Persistent profile avatar button (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _ProfileAvatarButton(
              onTap: () => _showProfileSheet(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF080808),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) =>
                ref.read(staffTabIndexProvider.notifier).state = index,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.accentGold,
            unselectedItemColor: Colors.white24,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.montserrat(
                fontSize: 9, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 9),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.insights_rounded),
                label: l10n.salesReport,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_awesome_mosaic_rounded),
                label: l10n.pos,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_outlined),
                label: l10n.inventory,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.keyboard_return_rounded),
                label: l10n.returnsHistory,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_rounded),
                label: l10n.ordersHistoryLabel,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedIndex == 1
          ? Consumer(
              builder: (context, ref, child) {
                final posState = ref.watch(posProvider);
                final cartItemCount = posState.localCart.fold<int>(
                    0, (sum, item) => sum + item.quantity);

                return FloatingActionButton(
                  onPressed: () => _showCartSheet(context),
                  backgroundColor: AppTheme.accentGold,
                  child: Badge(
                    label: Text(cartItemCount.toString()),
                    isLabelVisible: cartItemCount > 0,
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                    child: const Icon(Icons.shopping_cart_rounded,
                        color: Colors.black),
                  ),
                );
              },
            )
          : null,
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Expanded(child: TabletPosCart()),
          ],
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF050505),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border:
                Border(top: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              const Expanded(child: StaffProfileScreen()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating profile avatar button that reads user profile data.
class _ProfileAvatarButton extends ConsumerWidget {
  final VoidCallback onTap;
  const _ProfileAvatarButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF151515),
          border: Border.all(
            color: AppTheme.accentGold.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: profileAsync.when(
            loading: () => const Icon(Icons.person_rounded,
                color: AppTheme.accentGold, size: 20),
            error: (_, __) => const Icon(Icons.person_rounded,
                color: AppTheme.accentGold, size: 20),
            data: (profile) {
              if (profile == null) {
                return const Icon(Icons.person_rounded,
                    color: AppTheme.accentGold, size: 20);
              }
              if (profile.avatarUrl != null &&
                  profile.avatarUrl!.isNotEmpty) {
                return Image.network(
                  profile.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildInitial(profile.name),
                );
              }
              return _buildInitial(profile.name);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInitial(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      color: AppTheme.accentGold.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.accentGold,
        ),
      ),
    );
  }
}
