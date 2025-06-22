import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String userId,
    required String productId,
    required int quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // Relationships
    Product? product,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
      
  // Computed properties
  const CartItem._();
  
  double get totalPrice => product != null ? product!.price * quantity : 0.0;
  
  double get totalComparePrice => 
      product?.comparePrice != null ? product!.comparePrice! * quantity : 0.0;
      
  double get savings => totalComparePrice - totalPrice;
}

@freezed
class Cart with _$Cart {
  const factory Cart({
    required String userId,
    @Default([]) List<CartItem> items,
    DateTime? updatedAt,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) =>
      _$CartFromJson(json);
      
  // Computed properties
  const Cart._();
  
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get totalSavings => items.fold(0.0, (sum, item) => sum + item.savings);
  
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get isEmpty => items.isEmpty;
  
  bool get isNotEmpty => items.isNotEmpty;
}