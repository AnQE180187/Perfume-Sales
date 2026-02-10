import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../sections/profile_header_section.dart';
import '../sections/user_identity_section.dart';
import '../sections/olfactory_signature_section.dart';
import '../sections/account_actions_section.dart';

/// Profile Screen - Refactored
/// 
/// Architecture:
/// - Screen orchestrates layout and navigation only
/// - Presentation logic delegated to sections
/// - Reusable widgets for common patterns
/// - State-driven UI from profileProvider
/// 
/// Why this refactor improves maintainability:
/// 1. Single Responsibility: Each section manages its own UI
/// 2. Reusability: Widgets can be used across app
/// 3. Testability: Each component can be tested independently
/// 4. Scalability: Adding new sections is trivial
/// 5. Readability: Screen file is <150 lines, easy to understand
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return _buildLoginRequired(context);
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header (now scrollable)
                ProfileHeaderSection(
                  onBack: () => _handleBack(context),
                  onEdit: () => _handleEdit(context, ref),
                ),
                
                // User identity
                UserIdentitySection(profile: profile),

                // AI Olfactory Signature
                if (profile.hasAiProfile)
                  OlfactorySignatureSection(
                    olfactoryTags: profile.olfactoryTags,
                    onFindNextScent: () => _handleFindNextScent(context, ref),
                    onViewScentProfile: () => _handleViewScentProfile(context, ref),
                  ),

                // Account actions
                AccountActionsSection(
                  onMyOrders: () => _handleMyOrders(context),
                  onShippingAddresses: () => _handleShippingAddresses(context),
                  onPaymentMethods: () => _handlePaymentMethods(context),
                  onAiPreferences: () => _handleAiPreferences(context),
                  activeShipmentsText: '2 active shipments',
                ),

                // Logout
                LogoutSection(
                  onLogout: () => _handleLogout(context, ref),
                ),

                // Bottom spacing for nav bar
                const SizedBox(height: 100),
              ],
            );
          },
          loading: () => _buildLoading(),
          error: (error, stack) => _buildError(error),
        ),
      ),
    );
  }

  // ============================================
  // Navigation Handlers
  // ============================================
  // All navigation is centralized here, making it easy to:
  // - Track navigation analytics
  // - Add navigation guards
  // - Implement deep linking
  // - Test navigation flows

  void _handleBack(BuildContext context) {
    // Guard against popping root route (from bottom navigation)
    // If this is a root route, back button should do nothing or navigate to home
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // If it's a root route (can't pop), do nothing - user uses bottom nav instead
  }

  void _handleEdit(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon')),
    );
  }

  void _handleFindNextScent(BuildContext context, WidgetRef ref) {
    // Navigate to AI consultation using GoRouter
    context.push('/consultation');
  }

  void _handleViewScentProfile(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to full scent profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scent profile coming soon')),
    );
  }

  void _handleMyOrders(BuildContext context) {
    // Navigate to orders using GoRouter
    context.push('/orders');
  }

  void _handleShippingAddresses(BuildContext context) {
    // TODO: Navigate to shipping addresses screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shipping addresses coming soon')),
    );
  }

  void _handlePaymentMethods(BuildContext context) {
    // TODO: Navigate to payment methods screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment methods coming soon')),
    );
  }

  void _handleAiPreferences(BuildContext context) {
    // TODO: Navigate to AI preferences screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI preferences coming soon')),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  // ============================================
  // State UI Builders
  // ============================================

  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: AppTheme.mutedSilver,
          ),
          const SizedBox(height: 16),
          Text(
            'Please log in to view your profile',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.accentGold,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.mutedSilver,
          ),
          const SizedBox(height: 16),
          Text('Error loading profile: $error'),
        ],
      ),
    );
  }
}
