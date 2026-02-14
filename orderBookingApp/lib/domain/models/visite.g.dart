// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitPayload _$VisitPayloadFromJson(Map<String, dynamic> json) => VisitPayload(
  localId: json['localId'] as String?,
  shopId: (json['shop_id'] as num?)?.toInt(),
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
  punchIn: json['punch_in'] as String,
  punchOut: json['punch_out'] as String?,
  employeeId: (json['employee_id'] as num?)?.toInt(),
  regionName: json['region_name'] as String?,
  shopName: json['shop_name'] as String?,
  ownerName: json['owner_name'] as String?,
  address: json['address'] as String?,
  mobileNo: json['mobile_no'] as String?,
  email: json['email'] as String?,
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  capturedAt: json['captured_at'] == null
      ? null
      : DateTime.parse(json['captured_at'] as String),
);

Map<String, dynamic> _$VisitPayloadToJson(VisitPayload instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'shop_id': instance.shopId,
      'lat': instance.lat,
      'lng': instance.lng,
      'punch_in': instance.punchIn,
      'punch_out': instance.punchOut,
      'employee_id': instance.employeeId,
      'region_name': instance.regionName,
      'shop_name': instance.shopName,
      'owner_name': instance.ownerName,
      'address': instance.address,
      'mobile_no': instance.mobileNo,
      'email': instance.email,
      'accuracy': instance.accuracy,
      'captured_at': instance.capturedAt?.toIso8601String(),
    };
