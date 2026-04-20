import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_routes.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'don-hang',
      'icon': Icons.shopping_bag_outlined,
      'title': 'Đơn hàng'
    },
    {
      'id': 'thanh-toan',
      'icon': Icons.payment_outlined,
      'title': 'Thanh toán'
    },
    {
      'id': 'van-chuyen',
      'icon': Icons.local_shipping_outlined,
      'title': 'Vận chuyển'
    },
    {
      'id': 'ai-tu-van',
      'icon': Icons.auto_awesome_outlined,
      'title': 'AI Tư vấn'
    },
    {'id': 'tai-khoan', 'icon': Icons.person_outline_rounded, 'title': 'Tài khoản'},
  ];

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'Làm thế nào để đổi trả sản phẩm?',
      'answer':
          'Bạn có thể gửi yêu cầu đổi trả trong vòng 7 ngày kể từ khi nhận hàng. Vui lòng vào mục "Đơn hàng của tôi", chọn đơn hàng cần đổi trả và nhấn "Yêu cầu hoàn trả".'
    },
    {
      'question': 'Thuật toán AI gợi ý mùi hương hoạt động ra sao?',
      'answer':
          'Perfume GPT sử dụng hệ thống thần kinh nhân tạo kết hợp với dữ liệu về 147 điểm cảm quan và lối sống của bạn để phối hợp các phân tử mùi hương phù hợp nhất với bản sắc riêng của bạn.'
    },
    {
      'question': 'Perfume GPT có giao hàng quốc tế không?',
      'answer':
          'Hiện tại chúng tôi hỗ trợ giao hàng tại Việt Nam và các quốc gia khu vực Đông Nam Á. Chúng tôi đang mở rộng mạng lưới giao hàng toàn cầu trong thời gian tới.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.deepCharcoal, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'TRUNG TÂM TRỢ GIÚP',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Search Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHÚNG TÔI CÓ THỂ GIÚP GÌ CHO BẠN?',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.mutedSilver,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm vấn đề của bạn...',
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: const Icon(Icons.search_rounded,
                            color: AppTheme.mutedSilver, size: 20),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FAQ Categories
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];
                  return _buildCategoryCard(
                    context,
                    cat['icon'] as IconData,
                    cat['title'] as String,
                    cat['id'] as String,
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),

          // Common Questions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
              child: Text(
                'CÂU HỎI THƯỜNG GẶP',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppTheme.mutedSilver,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final faq = _faqs[index];
                return _buildExpandableFaqItem(faq['question']!, faq['answer']!);
              },
              childCount: _faqs.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, IconData icon, String title, String id) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.helpArticleWithId(id)),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.ivoryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.deepCharcoal, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
          ),
          trailing: const Icon(Icons.expand_more_rounded,
              color: AppTheme.mutedSilver, size: 20),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              answer,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                height: 1.6,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
