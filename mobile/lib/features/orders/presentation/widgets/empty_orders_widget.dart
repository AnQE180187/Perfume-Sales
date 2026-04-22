import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/luxury_button.dart';
import '../../../../l10n/app_localizations.dart';

class EmptyOrdersWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyOrdersWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: title,
      subtitle: subtitle,
      action: LuxuryButton(
        text: l10n.exploreCollection,
        onPressed: () => context.go(AppRoutes.explore),
      ),
    );
  }
}
