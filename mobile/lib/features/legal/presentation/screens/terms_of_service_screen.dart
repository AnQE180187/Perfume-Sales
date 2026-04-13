import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'ĐIỀU KHOẢN DỊCH VỤ',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Chấp thuận điều khoản',
              'Bằng việc truy cập và sử dụng ứng dụng Lumina Atelier, bạn đồng ý tuân thủ các điều khoản và điều kiện được nêu tại đây.',
            ),
            _buildSection(
              '2. Tài khoản người dùng',
              'Bạn có trách nhiệm bảo mật thông tin tài khoản và mật khẩu của mình. Mọi hoạt động diễn ra dưới tài khoản của bạn sẽ thuộc trách nhiệm của bạn.',
            ),
            _buildSection(
              '3. Quyền sở hữu trí tuệ',
              'Tất cả nội dung, hình ảnh, thiết kế và thuật toán AI trên ứng dụng đều thuộc sở hữu của Lumina Atelier và được bảo vệ bởi luật sở hữu trí tuệ.',
            ),
            _buildSection(
              '4. Chính sách mua hàng',
              'Giá sản phẩm được niêm yết có thể thay đổi tùy thời điểm. Chúng tôi cam kết cung cấp thông tin sản phẩm chính xác nhất có thể.',
            ),
            _buildSection(
              '5. Giới hạn trách nhiệm',
              'Lumina Atelier không chịu trách nhiệm cho bất kỳ thiệt hại gián tiếp nào phát sinh từ việc sử dụng dịch vụ của chúng tôi.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Cập nhật lần cuối: Tháng 4, 2026',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppTheme.mutedSilver,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
