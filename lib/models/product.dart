class Product {
  final int? id;
  final DateTime? createdAt;
  final String name;
  final String? description;
  final int price;
  final int stock;
  final String userId;
  final String? imageUrl; // ← TAMBAHKAN INI

  Product({
    this.id,
    this.createdAt,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.userId,
    this.imageUrl, // ← TAMBAHKAN INI
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price'] as int,
      stock: json['stock'] as int,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String?, // ← TAMBAHKAN INI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'user_id': userId,
      'image_url': imageUrl, // ← TAMBAHKAN INI
    };
  }

  Product copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? price,
    int? stock,
    String? userId,
    String? imageUrl, // ← TAMBAHKAN INI
  }) {
    return Product(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl, // ← TAMBAHKAN INI
    );
  }
}
