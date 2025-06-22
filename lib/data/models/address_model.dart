import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String id,
    required String userId,
    required String title,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    @Default('India') String country,
    double? latitude,
    double? longitude,
    @Default(false) bool isDefault,
    @Default('hostel') String addressType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
      
  // Computed properties
  const AddressModel._();
  
  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }
  
  String get shortAddress {
    return '$addressLine1, $city';
  }
}

enum AddressType {
  home('home', 'Home'),
  hostel('hostel', 'Hostel'),
  office('office', 'Office'),
  other('other', 'Other');
  
  const AddressType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}