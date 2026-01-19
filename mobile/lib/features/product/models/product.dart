class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final String? description;
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
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      description: json['description'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviews: json['reviews'] as int?,
      notes: json['notes'] != null 
          ? List<String>.from(json['notes'] as List)
          : [],
      size: json['size'] as String?,
      variant: json['variant'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      images: json['images'] != null 
          ? List<String>.from(json['images'] as List)
          : null,
    );
  }
}
