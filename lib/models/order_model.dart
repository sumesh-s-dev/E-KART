class OrderModel {
  final String id;
  final String userId;
  final List<String> productIds;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['user_id'],
      productIds: List<String>.from(map['product_ids'] ?? []),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
