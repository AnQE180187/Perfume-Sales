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

class StaffInventoryHistoryScreen extends ConsumerWidget {
  final String storeId;
  const StaffInventoryHistoryScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logsAsync = ref.watch(inventoryLogsProvider(storeId));
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.auditTrail,
          style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.w800, letterSpacing: 4),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.stockAdjustmentLogs,
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 32),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isIncrease ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              isIncrease ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
              color: isIncrease ? Colors.greenAccent : Colors.orangeAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.variant?.product?.name?.toUpperCase() ?? "SẢN PHẨM KHÔNG XÁC ĐỊNH", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                Text("${log.variant?.name ?? ''} | ${log.reason?.toUpperCase() ?? ''}", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white38, letterSpacing: 1)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isIncrease ? '+' : ''}${log.change}",
                style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: isIncrease ? Colors.greenAccent : Colors.orangeAccent),
              ),
              Text(dateFmt.format(log.createdAt), style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white24)),
            ],
          ),
        ],
      ),
    );
  }
}
