import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = ref.watch(staffTabIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: IndexedStack(
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF080808),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => ref.read(staffTabIndexProvider.notifier).state = index,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.accentGold,
            unselectedItemColor: Colors.white24,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 8),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.insights_rounded),
                label: "Báo cáo",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_mosaic_rounded),
                label: "POS",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                label: "Kho",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.keyboard_return_rounded),
                label: "Trả hàng",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: "Đơn hàng",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: "Cá nhân",
              ),
            ],
          ),
        ),
      ),
      // We'll put Profile in a Drawer or as a 6th item if possible, 
      // but BottomNavigationBar with 6 items is too many.
      // Let's add a "More" item or use a Drawer for the rest.
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showCartSheet(context),
              backgroundColor: AppTheme.accentGold,
              child: const Icon(Icons.shopping_cart_rounded, color: Colors.black),
            )
          : null,
      drawer: _MobileStaffDrawer(l10n: l10n, ref: ref),
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
}

class _MobileStaffDrawer extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _MobileStaffDrawer({required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF080808),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Center(
              child: Text(
                'LUXURY STAFF',
                style: GoogleFonts.playfairDisplay(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded, color: Colors.white70),
            title: Text(l10n.profileLabel, style: GoogleFonts.montserrat(color: Colors.white)),
            onTap: () {
              ref.read(staffTabIndexProvider.notifier).state = 5;
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(l10n.logout, style: GoogleFonts.montserrat(color: Colors.redAccent)),
            onTap: () {
              // Handle logout
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
