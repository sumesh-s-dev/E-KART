class Seller {
  final String sellerId;
  final String username;
  final String brandName;
  final String email;
  final String? phone;
  final String status; // 'online' or 'offline'
  final DateTime createdAt;
  final DateTime updatedAt;

  Seller({
    required this.sellerId,
    required this.username,
    required this.brandName,
    required this.email,
    this.phone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      sellerId: json['seller_id'] ?? '',
      username: json['username'] ?? '',
      brandName: json['brand_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      status: json['status'] ?? 'offline',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'username': username,
      'brand_name': brandName,
      'email': email,
      'phone': phone,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Seller copyWith({
    String? sellerId,
    String? username,
    String? brandName,
    String? email,
    String? phone,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Seller(
      sellerId: sellerId ?? this.sellerId,
      username: username ?? this.username,
      brandName: brandName ?? this.brandName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Seller(sellerId: $sellerId, username: $username, brandName: $brandName, email: $email, phone: $phone, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Seller && other.sellerId == sellerId;
  }

  @override
  int get hashCode => sellerId.hashCode;
}
