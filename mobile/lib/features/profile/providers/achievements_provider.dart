import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import './profile_provider.dart';

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final profileAsync = ref.watch(profileProvider);
  
  return profileAsync.maybeWhen(
    data: (profile) {
      if (profile == null) return _allAchievements;
      
      return [
        _allAchievements[0].copyWith(isUnlocked: true, dateUnlocked: '2024-01-15'), // Welcome
        _allAchievements[1].copyWith(isUnlocked: profile.hasAiProfile), // Scent Explorer
        _allAchievements[2].copyWith(isUnlocked: profile.olfactoryTags.length >= 5), // Note Master
        _allAchievements[3], // First Purchase (Mocked for now)
        _allAchievements[4], // Review Master (Mocked for now)
      ];
    },
    orElse: () => _allAchievements,
  );
});

final _allAchievements = [
  const Achievement(
    id: 'welcome',
    title: 'Bước Chân Đầu',
    description: 'Tham gia cộng đồng yêu nước hoa PerfumeGPT',
    icon: Icons.celebration_rounded,
  ),
  const Achievement(
    id: 'explorer',
    title: 'Nhà Thám Hiểm',
    description: 'Hoàn thành hồ sơ mùi hương AI (Quiz)',
    icon: Icons.explore_rounded,
  ),
  const Achievement(
    id: 'notemaster',
    title: 'Bậc Thầy Nốt Hương',
    description: 'Khám phá hơn 5 nốt hương đặc trưng',
    icon: Icons.auto_awesome_rounded,
  ),
  const Achievement(
    id: 'shopper',
    title: 'Người Mua Tinh Hoa',
    description: 'Thực hiện đơn hàng đầu tiên của bạn',
    icon: Icons.shopping_bag_rounded,
  ),
  const Achievement(
    id: 'reviewer',
    title: 'Vua Đánh Giá',
    description: 'Để lại ít nhất 3 đánh giá chi tiết',
    icon: Icons.rate_review_rounded,
  ),
];

extension AchievementExtension on Achievement {
  Achievement copyWith({bool? isUnlocked, String? dateUnlocked}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      dateUnlocked: dateUnlocked ?? this.dateUnlocked,
    );
  }
}
