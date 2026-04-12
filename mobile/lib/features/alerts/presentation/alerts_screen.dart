import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../models/alert.dart';
import '../providers/alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(alertsPrefsProvider);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(alertsProvider.notifier).refresh(),
          color: AppTheme.accentGold,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              //  Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.notifications,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showSettings(context, prefs),
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: AppTheme.deepCharcoal,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.notificationSubtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _AlertsSummaryCard(alertsAsync: alertsAsync),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _FilterChipsRow(
                        activeFilter: prefs.activeFilter,
                        unreadCount: alertsAsync.value?.where((a) => a.isUnread).length ?? 0,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              //  Alerts body via AppAsyncWidget
              SliverToBoxAdapter(
                child: AppAsyncWidget<List<Alert>>(
                  value: alertsAsync,
                  onRetry: () => ref.invalidate(alertsProvider),
                  loadingBuilder: () => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      children: List.generate(
                        4,
                        (_) => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: ShimmerCard(height: 130),
                        ),
                      ),
                    ),
                  ),
                  dataBuilder: (alerts) {
                    final filtered = _applyFilter(alerts, prefs.activeFilter);
                    if (filtered.isEmpty) {
                      return const _EmptyAlertsView();
                    }
                    return _AlertsListView(
                      alerts: filtered,
                      onTap: (alert) {
                        ref.read(alertsProvider.notifier).markAsRead(alert.id);
                        _showDetail(context, alert);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Alert> _applyFilter(List<Alert> alerts, AlertFilter filter) {
    switch (filter) {
      case AlertFilter.all:
        return alerts;
      case AlertFilter.unread:
        return alerts.where((a) => a.isUnread).toList();
      case AlertFilter.orders:
        return alerts.where((a) => a.category == AlertCategory.order).toList();
      case AlertFilter.offers:
        return alerts.where((a) => a.category == AlertCategory.offer).toList();
      case AlertFilter.account:
        return alerts
            .where((a) => a.category == AlertCategory.account)
            .toList();
    }
  }

  void _showSettings(BuildContext context, AlertsPrefs prefs) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationSettingsSheet(prefs: prefs),
    );
  }

  void _showDetail(BuildContext context, Alert alert) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertDetailSheet(alert: alert),
    );
  }
}

// ---------------------------------------------------------------------------
// Body widgets
// ---------------------------------------------------------------------------

class _EmptyAlertsView extends StatelessWidget {
  const _EmptyAlertsView();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppTheme.mutedSilver.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noNotifications,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsListView extends StatelessWidget {
  final List<Alert> alerts;
  final void Function(Alert) onTap;
  const _AlertsListView({required this.alerts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final todayAlerts = alerts.where((a) => a.isToday).toList();
    final olderAlerts = alerts.where((a) => !a.isToday).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todayAlerts.isNotEmpty) ...[
            _SectionLabel(title: AppLocalizations.of(context)!.latest),
            const SizedBox(height: 14),
            for (final alert in todayAlerts) ...[
              _AlertCard(alert: alert, onTap: () => onTap(alert)),
              const SizedBox(height: 16),
            ],
          ],
          if (olderAlerts.isNotEmpty) ...[
            if (todayAlerts.isNotEmpty) const SizedBox(height: 12),
            _SectionLabel(title: AppLocalizations.of(context)!.older),
            const SizedBox(height: 14),
            for (final alert in olderAlerts) ...[
              _AlertCard(alert: alert, onTap: () => onTap(alert)),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _MarkAllReadButton extends ConsumerWidget {
  final AsyncValue<List<Alert>> alertsAsync;
  const _MarkAllReadButton({required this.alertsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = alertsAsync.value?.where((a) => a.isUnread).length ?? 0;
    return TextButton(
      onPressed: unread == 0
          ? null
          : () => ref.read(alertsProvider.notifier).markAllAsRead(),
      child: Text(
        AppLocalizations.of(context)!.markAllRead,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: unread == 0 ? AppTheme.mutedSilver : AppTheme.accentGold,
        ),
      ),
    );
  }
}

class _AlertsSummaryCard extends StatelessWidget {
  final AsyncValue<List<Alert>> alertsAsync;
  const _AlertsSummaryCard({required this.alertsAsync});

  @override
  Widget build(BuildContext context) {
    final unread = alertsAsync.value?.where((a) => a.isUnread).length ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5E8D5),
            const Color(0xFFE0C79E).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.deepCharcoal,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unread == 0
                      ? AppLocalizations.of(context)!.allNotificationsRead
                      : AppLocalizations.of(context)!.unreadNotifications(unread),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.85),
                  ),
                ),
                if (unread > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      AppLocalizations.of(context)!.updateNotifications,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.deepCharcoal.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (unread > 0)
            Consumer(
              builder: (context, ref, _) => _MarkAllReadSummaryButton(unread: unread),
            ),
        ],
      ),
    );
  }
}

class _MarkAllReadSummaryButton extends ConsumerWidget {
  final int unread;
  const _MarkAllReadSummaryButton({required this.unread});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(alertsProvider.notifier).markAllAsRead(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.deepCharcoal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          AppLocalizations.of(context)!.readAll,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.deepCharcoal,
          ),
        ),
      ),
    );
  }
}

class _NotificationSettingsSheet extends ConsumerWidget {
  final AlertsPrefs prefs;
  const _NotificationSettingsSheet({required this.prefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(alertsPrefsProvider.notifier);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: AppTheme.ivoryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.softTaupe.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.notificationSettings,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 24),
          _PreferenceRow(
            title: AppLocalizations.of(context)!.orderUpdates,
            subtitle: AppLocalizations.of(context)!.orderUpdatesSub,
            value: prefs.orderUpdatesEnabled,
            onChanged: notifier.toggleOrderUpdates,
          ),
          _PreferenceRow(
            title: AppLocalizations.of(context)!.offersAndGifts,
            subtitle: AppLocalizations.of(context)!.offersAndGiftsSub,
            value: prefs.offerUpdatesEnabled,
            onChanged: notifier.toggleOfferUpdates,
          ),
          _PreferenceRow(
            title: AppLocalizations.of(context)!.accountActivity,
            subtitle: AppLocalizations.of(context)!.accountActivitySub,
            value: prefs.accountAlertsEnabled,
            onChanged: notifier.toggleAccountAlerts,
          ),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PreferenceRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.4),
              activeColor: AppTheme.accentGold,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends ConsumerWidget {
  final AlertFilter activeFilter;
  final int unreadCount;
  const _FilterChipsRow({
    required this.activeFilter,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(alertsPrefsProvider.notifier);
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _Chip(
            label: AppLocalizations.of(context)!.filterAll,
            isSelected: activeFilter == AlertFilter.all,
            onTap: () => notifier.setFilter(AlertFilter.all),
          ),
          _Chip(
            label: AppLocalizations.of(context)!.filterUnread,
            count: unreadCount,
            isSelected: activeFilter == AlertFilter.unread,
            onTap: () => notifier.setFilter(AlertFilter.unread),
          ),
          _Chip(
            label: AppLocalizations.of(context)!.filterOrders,
            isSelected: activeFilter == AlertFilter.orders,
            onTap: () => notifier.setFilter(AlertFilter.orders),
          ),
          _Chip(
            label: AppLocalizations.of(context)!.filterOffers,
            isSelected: activeFilter == AlertFilter.offers,
            onTap: () => notifier.setFilter(AlertFilter.offers),
          ),
          _Chip(
            label: AppLocalizations.of(context)!.filterAccount,
            isSelected: activeFilter == AlertFilter.account,
            onTap: () => notifier.setFilter(AlertFilter.account),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.deepCharcoal : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppTheme.deepCharcoal
                  : AppTheme.softTaupe.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.deepCharcoal,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentGold : AppTheme.deepCharcoal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.montserrat(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppTheme.deepCharcoal : AppTheme.deepCharcoal.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: AppTheme.mutedSilver.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;
  const _AlertCard({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryIcon = _getCategoryIcon(alert.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert.isUnread
              ? const Color(0xFFFAF7F2) // Subtle cream
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                categoryIcon,
                size: 18,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: alert.isUnread ? FontWeight.w700 : FontWeight.w600,
                            color: AppTheme.deepCharcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (alert.isUnread)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        alert.timeLabel,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.mutedSilver,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· ${alert.categoryLabel}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(AlertCategory category) {
    switch (category) {
      case AlertCategory.order:
        return Icons.local_shipping_outlined;
      case AlertCategory.offer:
        return Icons.star_border_rounded;
      case AlertCategory.account:
        return Icons.notifications_none_rounded;
    }
  }
}

class _AlertDetailSheet extends StatelessWidget {
  final Alert alert;
  const _AlertDetailSheet({required this.alert});

  void _handleAction(BuildContext context) {
    Navigator.pop(context);
    if (alert.category == AlertCategory.order && alert.orderId != null) {
      context.push(AppRoutes.trackOrderWithId(alert.orderId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.softTaupe,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: alert.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(alert.icon, size: 22, color: alert.accentColor),
            ),
            const SizedBox(height: 14),
            Text(
              alert.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              alert.timeLabel,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedSilver,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              alert.message,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w400,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
              ),
            ),
            if (alert.actionLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleAction(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alert.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    alert.actionLabel!,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
