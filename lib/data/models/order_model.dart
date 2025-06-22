import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';
import 'user_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String userId,
    required String sellerId,
    required String orderNumber,
    required String status,
    required double subtotal,
    @Default(0.0) double taxAmount,
    @Default(0.0) double shippingAmount,
    @Default(0.0) double discountAmount,
    required double totalAmount,
    @Default('cod') String paymentMethod,
    @Default('pending') String paymentStatus,
    required String deliveryType,
    required Map<String, dynamic> deliveryAddress,
    String? deliveryInstructions,
    DateTime? estimatedDelivery,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // Relationships
    @Default([]) List<OrderItem> items,
    UserModel? buyer,
    UserModel? seller,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
      
  // Computed properties
  const OrderModel._();
  
  bool get canBeCancelled => 
      status == 'pending' || status == 'confirmed';
      
  bool get isDelivered => status == 'delivered';
  
  bool get isCancelled => status == 'cancelled';
  
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }
  
  String get deliveryTypeDisplay {
    switch (deliveryType) {
      case 'hostel':
        return 'Hostel Delivery';
      case 'campus':
        return 'Campus Pickup';
      case 'pickup':
        return 'Pickup Point';
      default:
        return 'Unknown';
    }
  }
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    required String orderId,
    required String productId,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    required Map<String, dynamic> productSnapshot,
    DateTime? createdAt,
    
    // Relationships
    Product? product,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

enum OrderStatus {
  pending('pending', 'Pending'),
  confirmed('confirmed', 'Confirmed'),
  preparing('preparing', 'Preparing'),
  outForDelivery('out_for_delivery', 'Out for Delivery'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled'),
  refunded('refunded', 'Refunded');
  
  const OrderStatus(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

enum DeliveryType {
  hostel('hostel', 'Hostel Delivery'),
  campus('campus', 'Campus Pickup'),
  pickup('pickup', 'Pickup Point');
  
  const DeliveryType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}