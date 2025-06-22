import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String fullName,
    String? studentId,
    String? phone,
    String? hostelRoom,
    @Default('customer') String userType,
    @Default(false) bool isVerified,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

enum UserType {
  customer,
  seller,
  admin;
  
  String get displayName {
    switch (this) {
      case UserType.customer:
        return 'Customer';
      case UserType.seller:
        return 'Seller';
      case UserType.admin:
        return 'Admin';
    }
  }
}