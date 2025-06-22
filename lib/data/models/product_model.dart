import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String sellerId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    double? comparePrice,
    String? sku,
    @Default(0) int stockQuantity,
    @Default([]) List<String> images,
    @Default([]) List<String> tags,
    @Default('new') String condition,
    @Default(false) bool isFeatured,
    @Default(true) bool isActive,
    @Default(0) int viewCount,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // Relationships
    CategoryModel? category,
    UserModel? seller,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
      
  // Computed properties
  const Product._();
  
  bool get hasDiscount => comparePrice != null && comparePrice! > price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((comparePrice! - price) / comparePrice!) * 100;
  }
  
  bool get isInStock => stockQuantity > 0;
  
  String get primaryImage => images.isNotEmpty ? images.first : '';
  
  String get conditionDisplay {
    switch (condition) {
      case 'new':
        return 'Brand New';
      case 'like_new':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      case 'poor':
        return 'Poor';
      default:
        return 'Unknown';
    }
  }
}

enum ProductCondition {
  brandNew('new', 'Brand New'),
  likeNew('like_new', 'Like New'),
  good('good', 'Good'),
  fair('fair', 'Fair'),
  poor('poor', 'Poor');
  
  const ProductCondition(this.value, this.displayName);
  
  final String value;
  final String displayName;
}