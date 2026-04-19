import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class HelpArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const HelpArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    final article = _getArticleData(articleId);

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
          article['category']?.toUpperCase() ?? 'TRỢ GIÚP',
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
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
            Text(
              article['title'] ?? '',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 24),
            ... (article['content'] as List<Widget>),
            const SizedBox(height: 48),
            _buildRelatedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÔNG TIN NÀY CÓ HỮU ÍCH KHÔNG?',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildVoteButton(Icons.thumb_up_outlined, 'Có'),
              const SizedBox(width: 12),
              _buildVoteButton(Icons.thumb_down_outlined, 'Không'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.deepCharcoal,
          side: BorderSide(color: AppTheme.mutedSilver.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Map<String, dynamic> _getArticleData(String id) {
    switch (id) {
      case 'don-hang':
        return {
          'category': 'Đơn hàng',
          'title': 'Quy trình đặt hàng & Theo dõi',
          'content': [
            _paragraph('Sau khi chọn được mùi hương ưng ý, bạn có thể thực hiện đặt hàng theo các bước sau:'),
            _bullet('Thêm sản phẩm vào giỏ hàng.'),
            _bullet('Kiểm tra lại số lượng và dung tích.'),
            _bullet('Tiến hành thanh toán và điền thông tin địa chỉ.'),
            _paragraph('Mọi đơn hàng sẽ được xử lý trong vòng 24h.'),
          ]
        };
      case 'thanh-toan':
        return {
          'category': 'Thanh toán',
          'title': 'Phương thức thanh toán & Bảo mật',
          'content': [
            _paragraph('Perfume GPT hiện hỗ trợ 2 phương thức thanh toán chính để đảm bảo tính an toàn và tiện lợi:'),
            _bullet('Chuyển khoản qua PayOS (Hỗ trợ tất cả ngân hàng nội địa qua QR Code).'),
            _bullet('Thanh toán khi nhận hàng (COD).'),
            _paragraph('Mọi thông tin giao dịch của bạn đều được mã hóa và bảo mật tuyệt đối qua cổng thanh toán PayOS.'),
          ]
        };
      case 'van-chuyen':
        return {
          'category': 'Vận chuyển',
          'title': 'Chính sách vận chuyển & Phí',
          'content': [
            _paragraph('Chúng tôi hợp tác cùng đơn vị vận chuyển Giao Hàng Nhanh (GHN) để mang sản phẩm đến tay bạn nhanh nhất có thể:'),
            _bullet('Nội thành: 1-2 ngày làm việc.'),
            _bullet('Ngoại thành: 3-5 ngày làm việc.'),
            _paragraph('Phí vận chuyển sẽ được tự động tính toán dựa trên khối lượng sản phẩm và địa chỉ nhận hàng của bạn qua hệ thống GHN.'),
          ]
        };
      case 'ai-tu-van':
        return {
          'category': 'AI Tư vấn',
          'title': 'Về hệ thống tư vấn AI của Perfume GPT',
          'content': [
            _paragraph('Hệ thống AI của chúng tôi không chỉ là một bộ lọc đơn giản. Nó là kết quả của sự hợp tác giữa các chuyên gia mùi hương và kỹ sư công nghệ:'),
            _bullet('Phân tích 5 chiều: Cần thiết, Phong cách, Môi trường, Cảm xúc và Ký ức.'),
            _bullet('Cập nhật liên tục từ dữ liệu khách hàng thực tế.'),
            _paragraph('Độ chính xác lên đến 98% cho lần đầu tiên sử dụng.'),
          ]
        };
      case 'tai-khoan':
        return {
          'category': 'Tài khoản',
          'title': 'Quản lý tài khoản & Bảo mật',
          'content': [
            _paragraph('Để đảm bảo quyền lợi và tích lũy điểm thưởng, bạn nên duy trì tài khoản của mình:'),
            _bullet('Cập nhật thông tin cá nhân trong mục Hồ sơ.'),
            _bullet('Bật xác thực 2 lớp để tăng cường bảo mật.'),
            _paragraph('Nếu quên mật khẩu, vui lòng chọn "Quên mật khẩu" tại màn hình đăng nhập để nhận mã khôi phục.'),
          ]
        };
      default:
        return {
          'category': 'Trợ giúp',
          'title': 'Thông tin chung',
          'content': [_paragraph('Vui lòng liên hệ hỗ trợ để biết thêm chi tiết.')]
        };
    }
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          height: 1.6,
          color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
