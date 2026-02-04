// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitPayload _$VisitPayloadFromJson(Map<String, dynamic> json) => VisitPayload(
  localId: json['localId'] as String,
  shopId: (json['shopId'] as num).toInt(),
  employeeId: (json['employeeId'] as num?)?.toInt(),
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  capturedAt: DateTime.parse(json['capturedAt'] as String),
  punchIn: json['punchIn'] as String,
  punchOut: json['punchOut'] as String?,
);

Map<String, dynamic> _$VisitPayloadToJson(VisitPayload instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'shopId': instance.shopId,
      'lat': instance.lat,
      'lng': instance.lng,
      'accuracy': instance.accuracy,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'punchIn': instance.punchIn,
      'employeeId': instance.employeeId,
      'punchOut': instance.punchOut,
    };
