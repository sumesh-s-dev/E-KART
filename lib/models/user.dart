import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String userId;
  final String username;
  final String userType; // 'Student' or 'Staff'
  final String email;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.userId,
    required this.username,
    required this.userType,
    required this.email,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      userType: json['user_type'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'user_type': userType,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? userId,
    String? username,
    String? userType,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        userType,
        email,
        phone,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(userId: $userId, username: $username, userType: $userType, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
