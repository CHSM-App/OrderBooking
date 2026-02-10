// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitPayload _$VisitPayloadFromJson(Map<String, dynamic> json) => VisitPayload(
  localId: json['localId'] as String?,
  shopId: (json['shopId'] as num?)?.toInt(),
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
  punchIn: json['punchIn'] as String,
  punchOut: json['punchOut'] as String?,
  employeeId: (json['employeeId'] as num?)?.toInt(),
  regionName: json['regionName'] as String?,
  shopName: json['shopName'] as String?,
  ownerName: json['ownerName'] as String?,
  address: json['address'] as String?,
  mobileNo: json['mobileNo'] as String?,
  email: json['email'] as String?,
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  capturedAt: json['capturedAt'] == null
      ? null
      : DateTime.parse(json['capturedAt'] as String),
);

Map<String, dynamic> _$VisitPayloadToJson(VisitPayload instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'shopId': instance.shopId,
      'lat': instance.lat,
      'lng': instance.lng,
      'punchIn': instance.punchIn,
      'punchOut': instance.punchOut,
      'employeeId': instance.employeeId,
      'regionName': instance.regionName,
      'shopName': instance.shopName,
      'ownerName': instance.ownerName,
      'address': instance.address,
      'mobileNo': instance.mobileNo,
      'email': instance.email,
      'accuracy': instance.accuracy,
      'capturedAt': instance.capturedAt?.toIso8601String(),
    };
