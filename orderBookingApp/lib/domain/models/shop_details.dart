import 'package:json_annotation/json_annotation.dart';

part 'shop_details.g.dart';

@JsonSerializable()
class ShopDetails {
  final String? localId;

  @JsonKey(name: 'shop_id')
  final int? shopId;

  @JsonKey(name: 'shop_name')
  final String? shopName;

  @JsonKey(name: 'owner_name')
  final String? ownerName;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'mobile_no')
  final String? mobileNo;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'region_id')
  final int? regionId;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  @JsonKey(name: 'latitude')
  final double? latitude;

  @JsonKey(name: 'longitude')
  final double? longitude;

  @JsonKey(name: 'isSynced')
  final bool isSynced;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  ShopDetails({
    this.localId,
    this.shopId,
    this.shopName,
    this.ownerName,
    this.address,
    this.mobileNo,
    this.email,
    this.regionId,
    this.createdBy,
    this.latitude,
    this.longitude,
    this.isSynced = false,
    this.updatedAt,
  });

  /// FROM API JSON
  factory ShopDetails.fromJson(Map<String, dynamic> json) =>
      _$ShopDetailsFromJson(json);

  /// TO API JSON
  Map<String, dynamic> toJson() => _$ShopDetailsToJson(this);

  // 🔁 copyWith left exactly as requested
  ShopDetails copyWith({
    String? localId,
    int? shopId,
    String? shopName,
    String? ownerName,
    String? address,
    String? mobileNo,
    String? email,
    int? regionId,
    int? createdBy,
    double? latitude,
    double? longitude,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return ShopDetails(
      localId: localId ?? this.localId,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      address: address ?? this.address,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      regionId: regionId ?? this.regionId,
      createdBy: createdBy ?? this.createdBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
