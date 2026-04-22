import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../../../../core/config/env.dart';
import '../../../../core/utils/responsive.dart';

class StaffInventoryRequestsScreen extends ConsumerWidget {
  final String? storeId;
  const StaffInventoryRequestsScreen({super.key, this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myInventoryRequestsProvider(storeId));
    final dateFmt = DateFormat('dd/MM HH:mm');

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
              "QUẢN LÝ KHO",
              style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.w800, letterSpacing: 4),
            ),
            const SizedBox(height: 2),
            Text(
              "Dự thảo & Phê duyệt",
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
                "Danh sách yêu cầu chờ duyệt".toUpperCase(),
                style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white10),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.refresh(myInventoryRequestsProvider(storeId)),
                color: AppTheme.accentGold,
                backgroundColor: const Color(0xFF1A1A1A),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (request.type == 'IMPORT' ? AppTheme.accentGold : Colors.blueAccent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.type == 'IMPORT' ? "NHẬP KHO" : "ĐIỀU CHỈNH",
                  style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w900, color: request.type == 'IMPORT' ? AppTheme.accentGold : Colors.blueAccent),
                ),
              ),
              const Spacer(),
              Text(
                dateFmt.format(request.createdAt),
                style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildVariantImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.product?.toUpperCase() ?? "SẢN PHẨM KHÔNG XÁC ĐỊNH",
                      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${request.variantName ?? ''} • ${request.reason ?? 'Không có lý do'}",
                      style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${request.quantity > 0 ? '+' : ''}${request.quantity}",
                    style: GoogleFonts.robotoMono(fontSize: 20, fontWeight: FontWeight.w900, color: request.quantity > 0 ? Colors.greenAccent : Colors.orangeAccent),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (request.status != InventoryRequestStatus.pending && request.reviewNote != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "GHI CHÚ DUYỆT: ${request.reviewNote}",
                style: GoogleFonts.montserrat(fontSize: 10, color: statusColor.withOpacity(0.8), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariantImage() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: request.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                request.imageUrl!.startsWith('http') ? request.imageUrl! : '${EnvConfig.apiBaseUrl}${request.imageUrl}', 
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded, color: Colors.white60, size: 20),
              ),
            )
          : const Icon(Icons.inventory_2_rounded, color: Colors.white12, size: 20),
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
