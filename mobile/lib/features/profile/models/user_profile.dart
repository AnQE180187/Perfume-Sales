/// User Profile Model
/// 
/// Represents the user's profile data including personal info,
/// membership status, and AI-generated olfactory preferences.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime memberSince;
  final List<String> olfactoryTags;
  final bool hasAiProfile;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.memberSince,
    this.olfactoryTags = const [],
    this.hasAiProfile = false,
  });

  String get memberSinceText {
    return 'Member since ${memberSince.year}';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      memberSince: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      olfactoryTags: (json['olfactory_tags'] as List?)?.cast<String>() ?? [],
      hasAiProfile: json['has_ai_profile'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': memberSince.toIso8601String(),
      'olfactory_tags': olfactoryTags,
      'has_ai_profile': hasAiProfile,
    };
  }
}
