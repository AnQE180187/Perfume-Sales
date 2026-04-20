class Journal {
  final String id;
  final String title;
  final String? excerpt;
  final String mainImage;
  final String category;
  final int priority;
  final DateTime createdAt;
  final List<JournalSection> sections;

  const Journal({
    required this.id,
    required this.title,
    this.excerpt,
    required this.mainImage,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.sections = const [],
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String?,
      mainImage: json['mainImage'] as String,
      category: json['category'] as String? ?? 'all',
      priority: json['priority'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => JournalSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class JournalSection {
  final String id;
  final String? subtitle;
  final String content;
  final String? imageUrl;
  final String? productId;
  final int order;

  const JournalSection({
    required this.id,
    this.subtitle,
    required this.content,
    this.imageUrl,
    this.productId,
    required this.order,
  });

  factory JournalSection.fromJson(Map<String, dynamic> json) {
    return JournalSection(
      id: json['id'] as String,
      subtitle: json['subtitle'] as String?,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      productId: json['productId'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }
}
