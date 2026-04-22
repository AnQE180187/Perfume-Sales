import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.deepCharcoal,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.privacyPolicy.toUpperCase(),
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
              '1. Thu thập thông tin',
              'Perfume GPT thu thập thông tin cá nhân của bạn khi bạn đăng ký tài khoản, thực hiện giao dịch hoặc tham gia trắc nghiệm mùi hương AI. Thông tin này bao gồm tên, email, số điện thoại, địa chỉ và sở thích cá nhân.',
            ),
            _buildSection(
              '2. Sử dụng thông tin',
              'Chúng tôi sử dụng thông tin của bạn để cá nhân hóa trải nghiệm khứu giác, xử lý đơn hàng, gửi thông báo cập nhật và cải thiện các thuật toán AI tư vấn mùi hương.',
            ),
            _buildSection(
              '3. Bảo mật dữ liệu',
              'Chúng tôi áp dụng các biện pháp bảo mật cấp cao để bảo vệ dữ liệu cá nhân của bạn khỏi việc truy cập trái phép, tiết lộ hoặc thay đổi trái phép.',
            ),
            _buildSection(
              '4. Chia sẻ bên thứ ba',
              'Chúng tôi không bán hoặc trao đổi thông tin cá nhân của bạn cho bên thứ ba. Chúng tôi chỉ chia sẻ thông tin cần thiết với các đối tác vận chuyển và thanh toán để thực hiện dịch vụ.',
            ),
            _buildSection(
              '5. Quyền của người dùng',
              'Bạn có quyền truy cập, chỉnh sửa hoặc yêu cầu xóa dữ liệu cá nhân của mình bất kỳ lúc nào thông qua cài đặt tài khoản hoặc liên hệ trực tiếp với chúng tôi.',
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
              color: AppTheme.deepCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
