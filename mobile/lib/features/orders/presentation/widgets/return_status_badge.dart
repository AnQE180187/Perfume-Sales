import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../../../l10n/app_localizations.dart';

class ReturnStatusBadge extends StatelessWidget {
  final ReturnStatus status;

  const ReturnStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(status);
    final l10n = AppLocalizations.of(context)!;

    String label = '';
    switch (status) {
      case ReturnStatus.requested:
        label = l10n.returnStatusRequested;
        break;
      case ReturnStatus.reviewing:
      case ReturnStatus.awaitingCustomer:
        label = l10n.returnStatusReviewing;
        break;
      case ReturnStatus.approved:
        label = l10n.returnStatusApproved;
        break;
      case ReturnStatus.returning:
        label = l10n.returnStatusReturning;
        break;
      case ReturnStatus.received:
        label = l10n.returnStatusReceived;
        break;
      case ReturnStatus.refunding:
      case ReturnStatus.refundFailed:
        label = l10n.returnStatusRefunding;
        break;
      case ReturnStatus.completed:
        label = l10n.returnStatusCompleted;
        break;
      case ReturnStatus.rejected:
        label = l10n.returnStatusRejected;
        break;
      case ReturnStatus.rejectedAfterReturn:
        label = l10n.returnStatusRejectedAfterReturn;
        break;
      case ReturnStatus.cancelled:
        label = l10n.returnStatusCancelled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: style.text,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _BadgeStyle {
  final Color background;
  final Color border;
  final Color text;

  const _BadgeStyle({
    required this.background,
    required this.border,
    required this.text,
  });
}

_BadgeStyle _resolveStyle(ReturnStatus status) {
  switch (status) {
    case ReturnStatus.rejected:
    case ReturnStatus.rejectedAfterReturn:
    case ReturnStatus.cancelled:
    case ReturnStatus.refundFailed:
      return const _BadgeStyle(
        background: Color(0x1AF43F5E),
        border: Color(0x59F43F5E),
        text: Color(0xFFB42318),
      );
    case ReturnStatus.completed:
    case ReturnStatus.received:
      return const _BadgeStyle(
        background: Color(0x1432D583),
        border: Color(0x4D32D583),
        text: Color(0xFF067647),
      );
    case ReturnStatus.approved:
    case ReturnStatus.returning:
    case ReturnStatus.refunding:
      return const _BadgeStyle(
        background: Color(0x1A2E90FA),
        border: Color(0x592E90FA),
        text: Color(0xFF175CD3),
      );
    case ReturnStatus.requested:
    case ReturnStatus.reviewing:
    case ReturnStatus.awaitingCustomer:
      return _BadgeStyle(
        background: AppTheme.accentGold.withValues(alpha: 0.14),
        border: AppTheme.accentGold.withValues(alpha: 0.42),
        text: AppTheme.deepCharcoal,
      );
  }
}
