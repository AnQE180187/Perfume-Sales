import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_error_widget.dart';

final dailyClosingHistoryProvider = FutureProvider((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/daily-closing');
  return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
});

class DailyClosingHistoryScreen extends ConsumerWidget {
  const DailyClosingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(dailyClosingHistoryProvider);
    final currencyFmt = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "LỊCH SỬ CHỐT DOANH THU",
          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.accentGold, letterSpacing: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (e, s) => AppErrorWidget(message: e.toString(), onRetry: () => ref.refresh(dailyClosingHistoryProvider)),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: Colors.white10),
                  const SizedBox(height: 16),
                  Text("Chưa có lịch sử chốt doanh thu", style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final date = DateTime.parse(item['closingDate']);
              final diff = (item['difference'] as num).toInt();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal()),
                              style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['store']['name'],
                              style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: diff == 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            diff == 0 ? "KHỚP TIỀN" : "${currencyFmt.format(diff)}đ",
                            style: GoogleFonts.montserrat(
                              color: diff == 0 ? Colors.green : Colors.red,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat("Hệ thống", "${currencyFmt.format(item['systemTotal'])}đ"),
                        _buildStat("Thực tế", "${currencyFmt.format(item['actualCash'])}đ"),
                        _buildStat("Đơn hàng", "${item['orderCount']}"),
                      ],
                    ),
                    if (item['note'] != null && (item['note'] as String).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Ghi chú: ${item['note']}",
                          style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
