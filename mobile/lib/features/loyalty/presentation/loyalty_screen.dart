import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../services/loyalty_service.dart';
import '../../cart/providers/promotions_provider.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(loyaltyStatusProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.ivoryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppTheme.deepCharcoal,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.loyaltyProgramTitle,
          style: AppTextStyle.displaySm(color: AppTheme.deepCharcoal),
        ),
        centerTitle: true,
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              Text(l10n.unableLoadData, style: AppTextStyle.bodyMd()),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.refresh(loyaltyStatusProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (status) => _LoyaltyBody(
          status: status,
          onRefresh: () => ref.refresh(loyaltyStatusProvider),
        ),
      ),
    );
  }
}

class _LoyaltyBody extends StatelessWidget {
  final LoyaltyStatus status;
  final VoidCallback onRefresh;

  const _LoyaltyBody({required this.status, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.ivoryBackground,
            AppTheme.creamWhite,
            AppTheme.ivoryBackground,
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _PointsHeroCard(status: status),
            const SizedBox(height: 32),
            _SectionHeader(title: AppLocalizations.of(context)!.redeemRewardsTitle),
            const SizedBox(height: 16),
            _RedeemRewardsSection(userPoints: status.points),
            const SizedBox(height: 32),
            _SectionHeader(title: AppLocalizations.of(context)!.membershipTiersTitle),
            const SizedBox(height: 16),
            _TiersCard(status: status),
            const SizedBox(height: 32),
            _SectionHeader(title: AppLocalizations.of(context)!.howToEarnTitle),
            const SizedBox(height: 16),
            _HowItWorksCard(),
            const SizedBox(height: 32),
            _SectionHeader(title: AppLocalizations.of(context)!.transactionHistoryTitle),
            const SizedBox(height: 16),
            _TransactionHistory(history: status.history),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.deepCharcoal,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Hero points card
// ──────────────────────────────────────────────

class _PointsHeroCard extends StatelessWidget {
  final LoyaltyStatus status;

  const _PointsHeroCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            AppTheme.deepCharcoal.withValues(alpha: 0.95),
            const Color(0xFF0D0D0D),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.1),
            blurRadius: 50,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Abstract Luxury Lines
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentGold.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            _GoldFoilTexture(),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.memberLabel.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentGold,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (l10n.localeName == 'vi' ? status.tierNameVi : status.tierName).toUpperCase(),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const _MembershipLevelBadge(),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${status.points}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loyaltyPoints.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGold.withValues(alpha: 0.6),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (status.points < 5000) ...[
                    _buildProgressBar(status),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${status.points} / ${status.nextTierPoints} pts',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        Text(
                          l10n.pointsToNextTier(status.nextTierPoints - status.points),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(LoyaltyStatus status) {
    return Stack(
      children: [
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: status.tierProgress.clamp(0.0, 1.0),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB8860B),
                  AppTheme.accentGold,
                  Color(0xFFFFD700),
                ],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        // Glowing tip
        Positioned(
          left: (status.tierProgress * 230).clamp(0, 230), // Rough estimate for a standard card width
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MembershipLevelBadge extends StatelessWidget {
  const _MembershipLevelBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 20,
          color: AppTheme.accentGold,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Tier milestones
// ──────────────────────────────────────────────

class _TiersCard extends StatelessWidget {
  final LoyaltyStatus status;

  const _TiersCard({required this.status});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tiers = [
      _TierInfo(l10n.localeName == 'vi' ? 'Đồng' : 'Bronze', 0, Icons.shield_rounded, const Color(0xFFCD7F32)),
      _TierInfo(l10n.localeName == 'vi' ? 'Bạc' : 'Silver', 500, Icons.shield_rounded, const Color(0xFFA8A9AD)),
      _TierInfo(l10n.localeName == 'vi' ? 'Vàng' : 'Gold', 2000, Icons.workspace_premium_rounded, AppTheme.accentGold),
      _TierInfo(l10n.localeName == 'vi' ? 'Bạch Kim' : 'Platinum', 5000, Icons.diamond_rounded, const Color(0xFFAEC6CF)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connection Line
          Positioned(
            top: 26,
            left: 40,
            right: 40,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.softTaupe.withValues(alpha: 0.2),
                    AppTheme.accentGold.withValues(alpha: 0.2),
                    AppTheme.softTaupe.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: tiers.map((tier) {
              final currentTierName = l10n.localeName == 'vi' ? status.tierNameVi : status.tierName;
              final isActive = currentTierName == tier.name;
              final isUnlocked = status.points >= tier.minPoints;
              
              return Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isActive)
                          _PulsingHalo(color: tier.color),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isUnlocked ? [
                                tier.color.withValues(alpha: 0.8),
                                tier.color,
                                tier.color.withValues(alpha: 0.6),
                              ] : [
                                AppTheme.softTaupe.withValues(alpha: 0.2),
                                AppTheme.softTaupe.withValues(alpha: 0.1),
                              ],
                            ),
                            boxShadow: isUnlocked ? [
                              BoxShadow(
                                color: tier.color.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 2,
                                offset: const Offset(-2, -2),
                              ),
                            ] : [],
                          ),
                          child: Icon(
                            tier.icon,
                            size: 24,
                            color: isUnlocked ? AppTheme.creamWhite : AppTheme.mutedSilver.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tier.name.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                        color: isActive ? AppTheme.deepCharcoal : AppTheme.mutedSilver,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.minPoints == 0 ? l10n.defaultTier : '${tier.minPoints} pts',
                      style: GoogleFonts.montserrat(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PulsingHalo extends StatelessWidget {
  final Color color;
  const _PulsingHalo({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }
}

class _TierInfo {
  final String name;
  final int minPoints;
  final IconData icon;
  final Color color;

  const _TierInfo(this.name, this.minPoints, this.icon, this.color);
}

// ──────────────────────────────────────────────
// How it works card
// ──────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            Icons.shopping_bag_outlined,
            l10n.shoppingEarnTitle,
            l10n.shoppingEarnDesc,
          ),
          const SizedBox(height: 20),
          _infoRow(
            Icons.auto_awesome_rounded,
            l10n.upgradeEarnTitle,
            l10n.upgradeEarnDesc,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppTheme.accentGold),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppTheme.mutedSilver,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Transaction history
// ──────────────────────────────────────────────

class _TransactionHistory extends StatelessWidget {
  final List<LoyaltyTransaction> history;

  const _TransactionHistory({required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 40,
                      color: AppTheme.mutedSilver.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noTransactionsYet,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppTheme.softTaupe.withValues(alpha: 0.2),
                indent: 68,
              ),
              itemBuilder: (_, i) => _TransactionTile(tx: history[i]),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final LoyaltyTransaction tx;

  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEarn = tx.points > 0;
    
    final readableReason = tx.reason
        .replaceAll('_', ' ')
        .replaceAll('EARNED FROM ORDER', l10n.orderEarnedPoints)
        .replaceAll('REDEEMED FOR DISCOUNT', l10n.redeemedDiscount)
        .replaceAll('Tru points do hoan tra', l10n.returnedRefundPoints);

    final dateStr = '${tx.createdAt.day.toString().padLeft(2, '0')}/${tx.createdAt.month.toString().padLeft(2, '0')}/${tx.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _CoinIcon(isEarn: isEarn),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  readableReason,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: AppTheme.mutedSilver,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarn ? '+' : ''}${tx.points}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isEarn ? const Color(0xFFB8860B) : AppTheme.mutedSilver,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinIcon extends StatelessWidget {
  final bool isEarn;
  const _CoinIcon({required this.isEarn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isEarn 
          ? AppTheme.accentGold.withValues(alpha: 0.1)
          : AppTheme.softTaupe.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          isEarn ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
          size: 18,
          color: isEarn ? AppTheme.accentGold : AppTheme.mutedSilver,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Rewards Redemption Section
// ──────────────────────────────────────────────

class _RedeemRewardsSection extends ConsumerWidget {
  final int userPoints;
  const _RedeemRewardsSection({required this.userPoints});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final redeemableAsync = ref.watch(redeemablePromotionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        redeemableAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (rewards) {
            if (rewards.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.softTaupe.withValues(alpha: 0.3)),
                ),
                child: Text(
                  l10n.noRewardsAvailable,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppTheme.mutedSilver,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: rewards.length,
                itemBuilder: (context, index) => _RedeemPromoCard(
                  promo: rewards[index],
                  canAfford: rewards[index]['isPublic'] == true ||
                      userPoints >= (rewards[index]['pointsCost'] ?? 0),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RedeemPromoCard extends ConsumerWidget {
  final dynamic promo;
  final bool canAfford;

  const _RedeemPromoCard({required this.promo, required this.canAfford});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final int pointsCost = promo['pointsCost'] ?? 0;
    final String discountType = promo['discountType'] ?? '';
    final int discountValue = promo['discountValue'] ?? 0;
    final String endDateStr = promo['endDate'] ?? '';
    
    String formattedDate = '';
    if (endDateStr.isNotEmpty) {
      try {
        final date = DateTime.parse(endDateStr);
        formattedDate = DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        formattedDate = '';
      }
    }

    String valueText = discountType == 'PERCENTAGE'
        ? '$discountValue%'
        : formatVND(discountValue.toDouble()).replaceAll('đ', '');

    final bool isPublic = promo['isPublic'] ?? false;
    
    return GestureDetector(
      onTap: (isPublic || canAfford) ? () => _handleRedeem(context, ref) : null,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 20),
        child: Stack(
          children: [
            // Elevation Shadow for Ticket
            Positioned(
              bottom: 4,
              left: 8,
              right: 8,
              top: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isPublic ? AppTheme.accentGold : Colors.black)
                          .withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
            ),
            
            ClipPath(
              clipper: _TicketClipper(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: isPublic
                      ? Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1.5)
                      : null,
                ),
                child: Column(
                  children: [
                    // Top Section
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: isPublic ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.accentGold.withValues(alpha: 0.05),
                              Colors.white,
                            ],
                          ) : null,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isPublic)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l10n.free.toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              Text(
                                l10n.voucherDiscount.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.accentGold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    valueText,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.deepCharcoal,
                                      height: 1,
                                    ),
                                  ),
                                  if (discountType != 'PERCENTAGE') ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      'VND',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.mutedSilver,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (formattedDate.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 10,
                                      color: AppTheme.mutedSilver.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.validUntil(formattedDate),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.mutedSilver.withValues(alpha: 0.9),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Dash Line
                    Row(
                      children: List.generate(
                        20,
                        (index) => Expanded(
                          child: Container(
                            height: 1,
                            color: index % 2 == 0 
                              ? AppTheme.softTaupe.withValues(alpha: 0.2) 
                              : Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Section
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isPublic)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 10,
                                      color: canAfford ? AppTheme.accentGold : AppTheme.mutedSilver,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$pointsCost PTS',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: canAfford ? AppTheme.accentGold : AppTheme.mutedSilver,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              Container(
                                width: 146, // Fixed but scaled by FittedBox
                                height: 32,
                                decoration: BoxDecoration(
                                  color: (isPublic || canAfford) 
                                    ? AppTheme.deepCharcoal 
                                    : AppTheme.softTaupe.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    (isPublic ? l10n.claimNow : l10n.redeemNow).toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: (isPublic || canAfford) ? Colors.white : AppTheme.mutedSilver,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRedeem(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final bool isPublic = promo['isPublic'] ?? false;
    
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.softTaupe.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.confirm.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPublic 
                ? l10n.claimVoucherConfirm(promo['code'] ?? '')
                : l10n.redeemVoucherConfirm(promo['pointsCost'] ?? 0),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: AppTheme.deepCharcoal,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.softTaupe),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(l10n.cancel.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: AppTheme.mutedSilver)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepCharcoal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(l10n.confirm.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        if (isPublic) {
          await ref.read(loyaltyServiceProvider).claimPromotion(promo['id']);
        } else {
          await ref.read(loyaltyServiceProvider).redeemPromotion(promo['id']);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPublic 
                  ? l10n.claimSuccess(promo['code'] ?? '')
                  : l10n.redeemSuccess(promo['code'] ?? '')
              ),
              backgroundColor: AppTheme.deepCharcoal,
            ),
          );
          ref.refresh(loyaltyStatusProvider);
          ref.refresh(redeemablePromotionsProvider);
          ref.refresh(activePromotionsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
        }
      }
    }
  }
}

class _GoldFoilTexture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.07,
        child: Image.network(
          'https://www.transparenttextures.com/patterns/carbon-fibre.png',
          repeat: ImageRepeat.repeat,
          color: AppTheme.accentGold,
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 12.0;
    const double notchPos = 0.6; // Position of the dash line
    final path = Path();
    
    // Top-left
    path.moveTo(0, 0);
    path.lineTo(0, size.height * notchPos - radius);
    
    // Left notch
    path.arcToPoint(
      Offset(0, size.height * notchPos + radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    
    // Bottom-left
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    
    // Bottom-right
    path.lineTo(size.width, size.height * notchPos + radius);
    
    // Right notch
    path.arcToPoint(
      Offset(size.width, size.height * notchPos - radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    
    // Top-right
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
