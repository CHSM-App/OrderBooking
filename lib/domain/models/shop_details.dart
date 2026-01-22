import 'package:json_annotation/json_annotation.dart';

part 'shop_details.g.dart';

@JsonSerializable()
class ShopDetails {

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

  ShopDetails({
    this.shopId,
    this.shopName,
    this.ownerName,
    this.address,
    this.mobileNo,
    this.email,
    this.regionId,
    this.createdBy,
  });

  
  factory ShopDetails.fromJson(Map<String, dynamic> json) =>
      _$ShopDetailsFromJson(json);

  /// 🔁 To API JSON
  Map<String, dynamic> toJson() => _$ShopDetailsToJson(this);
}
