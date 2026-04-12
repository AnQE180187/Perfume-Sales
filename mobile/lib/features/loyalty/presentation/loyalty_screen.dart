import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../services/loyalty_service.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(loyaltyStatusProvider);

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
          'Khách hàng thân thiết',
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
              Text('Không thể tải dữ liệu', style: AppTextStyle.bodyMd()),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.refresh(loyaltyStatusProvider),
                child: const Text('Thử lại'),
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
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _PointsHeroCard(status: status),
          const SizedBox(height: 24),
          _RedeemRewardsSection(userPoints: status.points),
          const SizedBox(height: 24),
          _TiersCard(status: status),
          const SizedBox(height: 24),
          _HowItWorksCard(),
          const SizedBox(height: 24),
          _TransactionHistory(history: status.history),
        ],
      ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.deepCharcoal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Marble-like subtle texture pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/dark-matter.png', // Subtle dark texture
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
            // Diagonal shine
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
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
                            'THÀNH VIÊN',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentGold,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status.tierName.toUpperCase(),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const _MembershipLevelBadge(),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    '${status.points}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ĐIỂM TỬU TÍCH',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold.withValues(alpha: 0.8),
                      letterSpacing: 4,
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
                          '${status.nextTierPoints - status.points} điểm để lên hạng',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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
    final tiers = [
      _TierInfo('Bronze', 0, Icons.shield_rounded, const Color(0xFFCD7F32)),
      _TierInfo('Silver', 500, Icons.shield_rounded, const Color(0xFFA8A9AD)),
      _TierInfo('Gold', 2000, Icons.workspace_premium_rounded, AppTheme.accentGold),
      _TierInfo('Platinum', 5000, Icons.diamond_rounded, const Color(0xFFAEC6CF)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 20),
            child: Text(
              'CẤP HẠNG THÀNH VIÊN',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
                letterSpacing: 2,
              ),
            ),
          ),
          Row(
            children: tiers.map((tier) {
              final isActive = status.tierName == tier.name;
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
                            color: isUnlocked ? Colors.white : AppTheme.mutedSilver.withValues(alpha: 0.3),
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
                      tier.minPoints == 0 ? 'Mặc định' : '${tier.minPoints} pts',
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
          Text(
            'LÀM SAO ĐỂ TÍCH ĐIỂM?',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          _infoRow(
            Icons.shopping_bag_outlined,
            'MUA SẮM LÀM ĐẸP',
            'Cứ 10.000đ chi tiêu = 1 điểm tích lũy tinh chất',
          ),
          const SizedBox(height: 20),
          _infoRow(
            Icons.account_balance_wallet_outlined,
            'VIVU ƯU ĐÃI',
            'Sử dụng điểm (1 điểm = 500đ) để khấu trừ trực tiếp',
          ),
          const SizedBox(height: 20),
          _infoRow(
            Icons.auto_awesome_rounded,
            'NÂNG TẦM ĐẲNG CẤP',
            'Tích lũy đủ điểm để mở khóa các đặc quyền thượng lưu',
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'LỊCH SỬ GIAO DỊCH',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
                letterSpacing: 2,
              ),
            ),
          ),
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
                      'Hành trình của bạn chưa bắt đầu',
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
    final isEarn = tx.points > 0;
    
    final readableReason = tx.reason
        .replaceAll('_', ' ')
        .replaceAll('EARNED FROM ORDER', 'Tích điểm từ đơn hàng')
        .replaceAll('REDEEMED FOR DISCOUNT', 'Khấu trừ khi thanh toán')
        .replaceAll('Tru points do hoan tra', 'Hoàn trả điểm (Từ chối đơn)');

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
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isEarn
              ? AppTheme.accentGold.withValues(alpha: 0.3)
              : AppTheme.mutedSilver.withValues(alpha: 0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEarn
              ? [
                  AppTheme.accentGold.withValues(alpha: 0.2),
                  AppTheme.accentGold.withValues(alpha: 0.05),
                ]
              : [
                  AppTheme.mutedSilver.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lens_blur_rounded,
          size: 14,
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
    final redeemableAsync = ref.watch(redeemablePromotionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ĐỔI ƯU ĐÃI',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                  letterSpacing: 2,
                ),
              ),
              const Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 16),
            ],
          ),
        ),
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
                  'Hiện chưa có ưu đãi đổi điểm nào dành cho bạn.',
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
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: rewards.length,
                itemBuilder: (context, index) => _RedeemPromoCard(
                  promo: rewards[index],
                  canAfford: userPoints >= (rewards[index]['pointsCost'] ?? 0),
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
    final int pointsCost = promo['pointsCost'] ?? 0;
    final String discountType = promo['discountType'] ?? '';
    final int discountValue = promo['discountValue'] ?? 0;

    String valueText = discountType == 'PERCENTAGE'
        ? '$discountValue%'
        : formatVND(discountValue.toDouble()).replaceAll('đ', '');

    return GestureDetector(
      onTap: canAfford ? () => _handleRedeem(context, ref) : null,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 20),
        child: Stack(
          children: [
            // Main Ticket Body
            ClipPath(
              clipper: _TicketClipper(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Section (Discount Info)
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'VOUCHER GIẢM',
                              style: GoogleFonts.montserrat(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentGold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    valueText,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.deepCharcoal,
                                      height: 1,
                                    ),
                                  ),
                                  if (discountType != 'PERCENTAGE')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4, left: 2),
                                      child: Text(
                                        'đ',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.deepCharcoal,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Divider Line
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: List.generate(
                          15,
                          (index) => Expanded(
                            child: Container(
                              height: 1,
                              color: index % 2 == 0 
                                ? AppTheme.softTaupe.withValues(alpha: 0.2) 
                                : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Section (Points & CTA)
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: canAfford 
                                  ? AppTheme.accentGold.withValues(alpha: 0.1)
                                  : AppTheme.softTaupe.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: canAfford ? AppTheme.accentGold : AppTheme.mutedSilver,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ĐỔI NGAY',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: canAfford ? AppTheme.deepCharcoal : AppTheme.mutedSilver.withValues(alpha: 0.5),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Status Overlay (if not enough points)
            if (!canAfford)
              Positioned.fill(
                child: ClipPath(
                  clipper: _TicketClipper(),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleRedeem(BuildContext context, WidgetRef ref) async {
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
              'XÁC NHẬN ĐỔI QUÀ',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sử dụng ${promo['pointsCost']} điểm để đổi voucher này?',
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
                    child: Text('HỦY', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: AppTheme.mutedSilver)),
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
                    child: Text('XÁC NHẬN', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
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
        await ref.read(loyaltyServiceProvider).redeemPromotion(promo['id']);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đổi thành công! Mã ${promo['code']} đã có trong ví của bạn.'),
              backgroundColor: AppTheme.deepCharcoal,
            ),
          );
          ref.refresh(loyaltyStatusProvider);
          ref.refresh(redeemablePromotionsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 10.0;
    final path = Path();
    
    path.lineTo(0.0, size.height / 2 + radius);
    path.arcToPoint(
      Offset(0.0, size.height / 2 - radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(0.0, 0.0);
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height / 2 - radius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
