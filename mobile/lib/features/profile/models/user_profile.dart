/// User Profile Model
///
/// Represents the user's profile data including personal info,
/// membership status, and AI-generated olfactory preferences.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final DateTime memberSince;
  final List<String> olfactoryTags;
  final bool hasAiProfile;
  final bool isEmailVerified;
  final double? minBudget;
  final double? maxBudget;
  final String? address;
  final String? city;
  final String? country;
  final int addressCount;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
    required this.memberSince,
    this.olfactoryTags = const [],
    this.hasAiProfile = false,
    this.isEmailVerified = false,
    this.minBudget,
    this.maxBudget,
    this.address,
    this.city,
    this.country,
    this.addressCount = 0,
  });

  String get memberSinceText {
    return 'Thành viên từ ${memberSince.year}';
  }

  List<Map<String, dynamic>> get completionCriteria {
    return [
      {'label': 'Thông tin cơ bản', 'isDone': true, 'value': 10},
      {'label': 'Xác thực Email', 'isDone': isEmailVerified, 'value': 10},
      {'label': 'Số điện thoại', 'isDone': phone != null && phone!.isNotEmpty, 'value': 10},
      {'label': 'Giới tính', 'isDone': gender != null && gender!.isNotEmpty, 'value': 10},
      {'label': 'Ngày sinh', 'isDone': dateOfBirth != null, 'value': 10},
      {'label': 'Ảnh đại diện', 'isDone': avatarUrl != null && avatarUrl!.isNotEmpty, 'value': 10},
      {'label': 'Địa chỉ nhận hàng', 'isDone': addressCount > 0, 'value': 10},
      {'label': 'Sở thích ngân sách', 'isDone': minBudget != null && maxBudget != null, 'value': 10},
      {'label': 'Hồ sơ Scent AI (+20%)', 'isDone': hasAiProfile, 'value': 20},
    ];
  }

  double get completionPercentage {
    double progress = 0.1; // Base: Name & Email (10%)
    if (isEmailVerified) progress += 0.1;
    if (phone != null && phone!.isNotEmpty) progress += 0.1;
    if (gender != null && gender!.isNotEmpty) progress += 0.1;
    if (dateOfBirth != null) progress += 0.1;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) progress += 0.1;
    
    // Shipping Address (10%)
    if (addressCount > 0) progress += 0.1;

    // Budget Preferences (10%)
    if (minBudget != null && maxBudget != null) progress += 0.1;

    // AI Scent Profile (20%)
    if (hasAiProfile) progress += 0.2;
    
    return progress > 1.0 ? 1.0 : (progress < 0 ? 0 : progress);
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['_id'] ?? '') as String;
    final name =
        (json['full_name'] ?? json['fullName'] ?? json['name'] ?? 'Người dùng')
            as String;
    final email = (json['email'] ?? '') as String;
    final phone = (json['phone'] ?? json['phone_number']) as String?;
    final gender = (json['gender'] ?? json['user_gender']) as String?;
    final dobStr = (json['date_of_birth'] ?? json['dateOfBirth'] ?? json['dob']) as String?;
    final dateOfBirth = dobStr != null ? DateTime.tryParse(dobStr) : null;
    final avatarUrl = (json['avatar_url'] ?? json['avatarUrl']) as String?;
    final createdAtStr = (json['created_at'] ?? json['createdAt']) as String?;
    final memberSince = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();
    final olfactoryTags =
        (json['olfactory_tags'] as List?)?.cast<String>() ??
        (json['olfactoryTags'] as List?)?.cast<String>() ??
        [];
    final hasAiProfile =
        (json['has_ai_profile'] as bool?) ??
        (json['hasAiProfile'] as bool?) ??
        false;

    final isEmailVerified =
        (json['emailVerified'] as bool?) ??
        (json['email_verified'] as bool?) ??
        (json['is_email_verified'] as bool?) ??
        (json['isEmailVerified'] as bool?) ??
        false;
    final minBudget = (json['budgetMin'] ?? json['budget_min'] ?? json['minBudget'])?.toDouble();
    final maxBudget = (json['budgetMax'] ?? json['budget_max'] ?? json['maxBudget'])?.toDouble();
    final address = (json['address'] ?? '') as String?;
    final city = (json['city'] ?? '') as String?;
    final country = (json['country'] ?? '') as String?;
    final addressCount = (json['_count']?['addresses'] ?? 0) as int;

    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      avatarUrl: avatarUrl,
      memberSince: memberSince,
      olfactoryTags: olfactoryTags,
      hasAiProfile: hasAiProfile,
      isEmailVerified: isEmailVerified,
      minBudget: minBudget,
      maxBudget: maxBudget,
      address: address,
      city: city,
      country: country,
      addressCount: addressCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'avatar_url': avatarUrl,
      'created_at': memberSince.toIso8601String(),
      'olfactory_tags': olfactoryTags,
      'has_ai_profile': hasAiProfile,
      'is_email_verified': isEmailVerified,
      'budgetMin': minBudget,
      'budgetMax': maxBudget,
      'address': address,
      'city': city,
      'country': country,
    };
  }
}
