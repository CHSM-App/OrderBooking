// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopDetails _$ShopDetailsFromJson(Map<String, dynamic> json) => ShopDetails(
  shopId: (json['shop_id'] as num?)?.toInt(),
  shopName: json['shop_name'] as String?,
  ownerName: json['owner_name'] as String?,
  address: json['address'] as String?,
  mobileNo: json['mobile_no'] as String?,
  email: json['email'] as String?,
  regionId: (json['region_id'] as num?)?.toInt(),
  createdBy: (json['created_by'] as num?)?.toInt(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ShopDetailsToJson(ShopDetails instance) =>
    <String, dynamic>{
      'shop_id': instance.shopId,
      'shop_name': instance.shopName,
      'owner_name': instance.ownerName,
      'address': instance.address,
      'mobile_no': instance.mobileNo,
      'email': instance.email,
      'region_id': instance.regionId,
      'created_by': instance.createdBy,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
