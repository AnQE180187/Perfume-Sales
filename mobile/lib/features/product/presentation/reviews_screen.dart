import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class ReviewsScreen extends StatelessWidget {
  final String productId;
  final String productName;

  const ReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepCharcoal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đánh giá',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // PerfumeGPT Insight Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.accentGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GÓC NHÌN PERFUMEGPT',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '92% người mua đề xuất mùi hương này cho buổi tối, đặc biệt yêu thích tổ hợp oud nhiều lớp cùng lớp hương vanilla ấm áp lưu lại sau cùng. Độ lưu hương là điểm được nhắc đến nhiều nhất.',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: AppTheme.deepCharcoal.withValues(alpha: 0.85),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rating Summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    '4.8',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepCharcoal,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: AppTheme.accentGold,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '128 đánh giá đã xác thực',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.mutedSilver,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _RatingBar(
                      label: 'Độ lưu hương',
                      value: 0.85,
                      subtitle: 'TRUNG BÌNH - LÂU',
                    ),
                    const SizedBox(height: 10),
                    _RatingBar(
                      label: 'Độ tỏa hương',
                      value: 0.9,
                      subtitle: 'MẠNH',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Tất cả đánh giá', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'Có hình ảnh', isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: 'Người mua xác thực', isSelected: false),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reviews List
          _ReviewCard(
            name: 'Isabella V.',
            timeAgo: '2 ngày trước',
            isVerified: true,
            rating: 5,
            tags: ['LƯU HƯƠNG TỐT', 'PHÙ HỢP BUỔI TỐI'],
            review:
                'Thật sự ấn tượng. Mở đầu là citrus sắc nét nhưng lớp hương sau khô xuống thành vanilla ấm áp bao bọc. Lưu trên da tôi khoảng 6 giờ, rất hợp cho một buổi hẹn tối.',
            helpful: 12,
          ),

          const SizedBox(height: 16),

          _ReviewCard(
            name: 'Marc D.',
            timeAgo: '1 tuần trước',
            isVerified: true,
            rating: 4,
            tags: ['TỎA HƯƠNG RÕ'],
            review:
                'Mùi hương rất ổn, nam tính rõ rệt nhưng hơi mạnh nếu dùng trong văn phòng. Độ tỏa hương lớn, ai cũng biết bạn vừa bước vào phòng. Nên dùng tiết chế.',
            helpful: 5,
            imageUrl:
                'https://images.unsplash.com/photo-1541643600914-78b084683601?w=200',
          ),

          const SizedBox(height: 16),

          _ReviewCard(
            name: 'Elena S.',
            timeAgo: '3 tuần trước',
            isVerified: true,
            rating: 5,
            tags: [],
            review:
                'Hoàn hảo cho những buổi hẹn hò. Chai màu vàng cầm rất chắc tay và tạo cảm giác cực kỳ sang trọng. Rất đáng thử. Đúng kiểu mùi hương của sự đắt giá.',
            helpful: 24,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final double value;
  final String subtitle;

  const _RatingBar({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.deepCharcoal,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppTheme.accentGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppTheme.softTaupe.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.accentGold,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryDb : AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primaryDb : AppTheme.softTaupe,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppTheme.creamWhite : AppTheme.deepCharcoal,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String timeAgo;
  final bool isVerified;
  final int rating;
  final List<String> tags;
  final String review;
  final int helpful;
  final String? imageUrl;

  const _ReviewCard({
    required this.name,
    required this.timeAgo,
    required this.isVerified,
    required this.rating,
    required this.tags,
    required this.review,
    required this.helpful,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.softTaupe.withValues(alpha: 0.4),
                child: Text(
                  name[0],
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          timeAgo,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.mutedSilver,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.mutedSilver,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Người mua xác thực',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppTheme.accentGold,
                    size: 14,
                  );
                }),
              ),
            ],
          ),

          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tags.first,
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppTheme.accentGold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          Text(
            review,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: AppTheme.deepCharcoal,
            ),
          ),

          if (imageUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 14,
                color: AppTheme.mutedSilver,
              ),
              const SizedBox(width: 4),
              Text(
                '$helpful người thấy hữu ích',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mutedSilver,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
