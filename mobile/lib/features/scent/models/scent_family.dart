class ScentFamily {
  final int id;
  final String name;
  final String? description;

  const ScentFamily({
    required this.id,
    required this.name,
    this.description,
  });

  factory ScentFamily.fromJson(Map<String, dynamic> json) {
    return ScentFamily(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
