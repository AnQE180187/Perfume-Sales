import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_models.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';

class StaffInventoryHistoryScreen extends ConsumerWidget {
  final String storeId;
  const StaffInventoryHistoryScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logsAsync = ref.watch(inventoryLogsProvider(storeId));
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.auditTrail.toUpperCase(),
              style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.w800, letterSpacing: 4),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.stockAdjustmentLogs,
              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Text(
                "Nhật ký điều chỉnh".toUpperCase(),
                style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white10),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                error: (e, _) => AppErrorWidget(
                  message: l10n.unableLoadData,
                  onRetry: () => ref.refresh(inventoryLogsProvider(storeId)),
                ),
                data: (logs) {
                  if (logs.isEmpty) {
                    return Center(
                      child: Text(l10n.noRecentActivity, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white10, letterSpacing: 4)),
                    );
                  }
                  return ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    itemBuilder: (ctx, i) => _LogItem(log: logs[i], dateFmt: dateFmt),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final InventoryLog log;
  final DateFormat dateFmt;
  const _LogItem({required this.log, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    final isIncrease = log.type == 'IMPORT' || (log.type == 'ADJUSTMENT' && log.change > 0);
    final imageUrl = log.variant?.imageUrl ?? log.variant?.product?.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isIncrease ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!.startsWith('http') ? imageUrl : 'https://api.perfume.vn$imageUrl'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Icon(
                    isIncrease ? Icons.add_chart_rounded : Icons.move_down_rounded,
                    color: isIncrease ? Colors.greenAccent : Colors.orangeAccent,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.variant?.product?.name?.toUpperCase() ?? "SẢN PHẨM KHÔNG XÁC ĐỊNH",
                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.variant?.name ?? '',
                        style: GoogleFonts.robotoMono(fontSize: 9, color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.reason?.toUpperCase() ?? 'KHÔNG CÓ LÝ DO',
                        style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, letterSpacing: 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isIncrease ? '+' : ''}${log.change}",
                style: GoogleFonts.robotoMono(fontSize: 18, fontWeight: FontWeight.w900, color: isIncrease ? Colors.greenAccent : Colors.orangeAccent),
              ),
              const SizedBox(height: 2),
              Text(dateFmt.format(log.createdAt), style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white24)),
            ],
          ),
        ],
      ),
    );
  }
}
