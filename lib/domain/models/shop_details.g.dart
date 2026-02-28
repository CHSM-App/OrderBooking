// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopDetails _$ShopDetailsFromJson(Map<String, dynamic> json) => ShopDetails(
  isDeleted: json['is_deleted'] as bool?,
  syncAction: json['sync_Action'] as String?,
  localId: json['localId'] as String?,
  shopId: (json['shop_id'] as num?)?.toInt(),
  shopName: json['shop_name'] as String?,
  ownerName: json['owner_name'] as String?,
  address: json['address'] as String?,
  mobileNo: json['mobile_no'] as String?,
  email: json['email'] as String?,
  regionId: (json['region_id'] as num?)?.toInt(),
  regionName: json['region_name'] as String?,
  createdBy: (json['created_by'] as num?)?.toInt(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  shopSelfie: json['shop_selfie'] as String?,
  isSynced: json['isSynced'] as bool? ?? false,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  companyId: json['company_id'] as String,
);

Map<String, dynamic> _$ShopDetailsToJson(ShopDetails instance) =>
    <String, dynamic>{
      'localId': instance.localId,
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
      'shop_selfie': instance.shopSelfie,
      'isSynced': instance.isSynced,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'company_id': instance.companyId,
      'region_name': instance.regionName,
      'sync_Action': instance.syncAction,
      'is_deleted': instance.isDeleted,
    };
