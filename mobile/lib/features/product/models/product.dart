class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final String? description;
  final String? story;
  final double? rating;
  final int? reviews;
  final List<String> notes;
  final String? size;
  final String? variant;
  final bool? inStock;
  final List<String>? images;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    this.description,
    this.story,
    this.rating,
    this.reviews,
    this.notes = const [],
    this.size,
    this.variant,
    this.inStock = true,
    this.images,
  });

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    String? imageUrl,
    String? description,
    String? story,
    double? rating,
    int? reviews,
    List<String>? notes,
    String? size,
    String? variant,
    bool? inStock,
    List<String>? images,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      story: story ?? this.story,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      notes: notes ?? this.notes,
      size: size ?? this.size,
      variant: variant ?? this.variant,
      inStock: inStock ?? this.inStock,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'rating': rating,
      'reviews': reviews,
      'notes': notes,
      'size': size,
      'variant': variant,
      'in_stock': inStock,
      'images': images,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final dynamic brandRaw = json['brand'];
    final brandName = brandRaw is String
        ? brandRaw
        : (brandRaw is Map<String, dynamic>
              ? (brandRaw['name']?.toString() ?? '')
              : '');

    final dynamic variantsRaw = json['variants'];
    final variants = variantsRaw is List
        ? variantsRaw.whereType<Map<String, dynamic>>().toList()
        : const <Map<String, dynamic>>[];
    final firstVariant = variants.isNotEmpty ? variants.first : null;

    final dynamic imagesRaw = json['images'];
    final imageList = imagesRaw is List
        ? imagesRaw
              .map((e) {
                if (e is String) return e;
                if (e is Map<String, dynamic>) return e['url']?.toString();
                return null;
              })
              .whereType<String>()
              .toList()
        : <String>[];

    final dynamic notesRaw = json['notes'];
    final parsedNotes = notesRaw is List
        ? notesRaw
              .map((e) {
                if (e is String) return e;
                if (e is Map<String, dynamic>) {
                  final note = e['note'];
                  if (note is Map<String, dynamic>) {
                    return note['name']?.toString();
                  }
                }
                return null;
              })
              .whereType<String>()
              .toList()
        : <String>[];

    final dynamic reviewsRaw = json['reviews'];
    final int? reviewCount = json['reviews'] is int
        ? json['reviews'] as int
        : (reviewsRaw is List ? reviewsRaw.length : null);

    double? rating;
    if (json['rating'] is num) {
      rating = (json['rating'] as num).toDouble();
    } else if (reviewsRaw is List && reviewsRaw.isNotEmpty) {
      double sum = 0;
      int count = 0;
      for (final item in reviewsRaw) {
        if (item is Map<String, dynamic> && item['rating'] is num) {
          sum += (item['rating'] as num).toDouble();
          count++;
        }
      }
      if (count > 0) rating = sum / count;
    }

    final dynamic priceRaw = json['price'] ?? firstVariant?['price'];
    final double price = priceRaw is num ? priceRaw.toDouble() : 0;

    final dynamic stockRaw = json['in_stock'];
    final bool inStock = stockRaw is bool
        ? stockRaw
        : variants.any((v) => (v['stock'] is num) && ((v['stock'] as num) > 0));

    final String imageUrl = (json['image_url']?.toString().isNotEmpty ?? false)
        ? json['image_url'] as String
        : (imageList.isNotEmpty ? imageList.first : '');

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: brandName,
      price: price,
      imageUrl: imageUrl,
      description: json['description'] as String?,
      story: json['story'] as String?,
      rating: rating,
      reviews: reviewCount,
      notes: parsedNotes,
      size: (json['size'] as String?) ?? firstVariant?['name']?.toString(),
      variant:
          (json['variant'] as String?) ?? firstVariant?['name']?.toString(),
      inStock: inStock,
      images: imageList,
    );
  }
}
