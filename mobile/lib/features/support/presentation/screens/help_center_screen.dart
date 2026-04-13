import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
              delegate: SliverChildListDelegate([
                _buildCategoryCard(Icons.shopping_bag_outlined, 'Đơn hàng'),
                _buildCategoryCard(Icons.payment_outlined, 'Thanh toán'),
                _buildCategoryCard(Icons.local_shipping_outlined, 'Vận chuyển'),
                _buildCategoryCard(Icons.auto_awesome_outlined, 'AI Tư vấn'),
                _buildCategoryCard(Icons.person_outline_rounded, 'Tài khoản'),
                _buildCategoryCard(Icons.card_membership_outlined, 'Ưu đãi'),
              ]),
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
            delegate: SliverChildListDelegate([
              _buildFaqItem('Làm thế nào để đổi trả sản phẩm?'),
              _buildFaqItem('Thuật toán AI gợi ý mùi hương hoạt động ra sao?'),
              _buildFaqItem('Lumina có giao hàng quốc tế không?'),
              _buildFaqItem('Làm sao để tích điểm thành viên?'),
              const SizedBox(height: 48),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title) {
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
          onTap: () {},
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

  Widget _buildFaqItem(String question) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          question,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.deepCharcoal,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppTheme.mutedSilver, size: 20),
        onTap: () {},
      ),
    );
  }
}
