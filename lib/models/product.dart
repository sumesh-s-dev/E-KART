import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productId;
  final String sellerId;
  final String name;
  final double price;
  final int stock;
  final String? imageUrl;
  final String category; // 'Food' or 'Other'
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.category,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
      category: json['category'] ?? 'Other',
      description: json['description'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'seller_id': sellerId,
      'name': name,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'category': category,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? productId,
    String? sellerId,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isInStock => stock > 0;

  @override
  List<Object?> get props => [
        productId,
        sellerId,
        name,
        price,
        stock,
        imageUrl,
        category,
        description,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Product(productId: $productId, sellerId: $sellerId, name: $name, price: $price, stock: $stock, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}
