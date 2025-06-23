import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

class Order extends Equatable {
  final String orderId;
  final String productId;
  final String customerId;
  final String sellerId;
  final int quantity;
  final double totalPrice;
  final String deliveryLocation;
  final String status; // 'Pending' or 'Delivered'
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.orderId,
    required this.productId,
    required this.customerId,
    required this.sellerId,
    required this.quantity,
    required this.totalPrice,
    required this.deliveryLocation,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] ?? '',
      productId: json['product_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      deliveryLocation: json['delivery_location'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'customer_id': customerId,
      'seller_id': sellerId,
      'quantity': quantity,
      'total_price': totalPrice,
      'delivery_location': deliveryLocation,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Order copyWith({
    String? orderId,
    String? productId,
    String? customerId,
    String? sellerId,
    int? quantity,
    double? totalPrice,
    String? deliveryLocation,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      customerId: customerId ?? this.customerId,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isDelivered => status == 'Delivered';

  @override
  List<Object?> get props => [
        orderId,
        productId,
        customerId,
        sellerId,
        quantity,
        totalPrice,
        deliveryLocation,
        status,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Order(orderId: $orderId, productId: $productId, customerId: $customerId, sellerId: $sellerId, quantity: $quantity, totalPrice: $totalPrice, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.orderId == orderId;
  }

  @override
  int get hashCode => orderId.hashCode;
}
