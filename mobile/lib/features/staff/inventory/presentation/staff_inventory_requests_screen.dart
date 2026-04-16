import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';

class StaffInventoryRequestsScreen extends ConsumerWidget {
  final String? storeId;
  const StaffInventoryRequestsScreen({super.key, this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myInventoryRequestsProvider(storeId));
    final dateFmt = DateFormat('dd/MM HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "YÊU CẦU CỦA TÔI",
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: AppTheme.accentGold,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DỰ THẢO & PHÊ DUYỆT",
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "DANH SÁCH CÁC PHIẾU NHẬP KHO VÀ ĐIỀU CHỈNH ĐANG CHỜ XỬ LÝ",
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: Colors.white24,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: requestsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                error: (e, _) => AppErrorWidget(
                  message: "Không thể tải danh sách yêu cầu.",
                  onRetry: () => ref.refresh(myInventoryRequestsProvider(storeId)),
                ),
                data: (requests) {
                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, color: Colors.white.withOpacity(0.05), size: 64),
                          const SizedBox(height: 24),
                          Text(
                            "CHƯA CÓ YÊU CẦU NÀO ĐƯỢC GỬI",
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.white12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    itemBuilder: (ctx, i) => _RequestItem(request: requests[i], dateFmt: dateFmt),
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

class _RequestItem extends StatelessWidget {
  final InventoryRequestModel request;
  final DateFormat dateFmt;
  const _RequestItem({required this.request, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          _buildVariantImage(),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (request.type == 'IMPORT' ? AppTheme.accentGold : Colors.blueAccent).withOpacity(0.1),
                        border: Border.all(color: (request.type == 'IMPORT' ? AppTheme.accentGold : Colors.blueAccent).withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        request.type == 'IMPORT' ? "NHẬP KHO" : "ĐIỀU CHỈNH",
                        style: GoogleFonts.montserrat(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: request.type == 'IMPORT' ? AppTheme.accentGold : Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateFmt.format(request.createdAt),
                      style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  request.product?.toUpperCase() ?? "SẢN PHẨM KHÔNG XÁC ĐỊNH",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "${request.variantName ?? ''} • ${request.reason ?? 'Không có lý do'}",
                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38),
                ),
                if (request.status != InventoryRequestStatus.pending && request.reviewNote != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "GHI CHÚ DUYỆT: ${request.reviewNote}",
                      style: GoogleFonts.montserrat(fontSize: 9, color: statusColor.withOpacity(0.5), fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${request.quantity > 0 ? '+' : ''}${request.quantity}",
                style: GoogleFonts.robotoMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: request.quantity > 0 ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: request.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(request.imageUrl!, fit: BoxFit.cover),
            )
          : const Icon(Icons.inventory_2_rounded, color: Colors.white10, size: 24),
    );
  }

  Color _getStatusColor(InventoryRequestStatus status) {
    switch (status) {
      case InventoryRequestStatus.approved:
        return Colors.greenAccent;
      case InventoryRequestStatus.rejected:
        return Colors.redAccent;
      case InventoryRequestStatus.pending:
        return AppTheme.accentGold;
    }
  }

  String _getStatusText(InventoryRequestStatus status) {
    switch (status) {
      case InventoryRequestStatus.approved:
        return "ĐÃ DUYỆT";
      case InventoryRequestStatus.rejected:
        return "TỪ CHỐI";
      case InventoryRequestStatus.pending:
        return "CHỜ DUYỆT";
    }
  }
}
