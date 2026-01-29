// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitPayload _$VisitPayloadFromJson(Map<String, dynamic> json) => VisitPayload(
  shopId: json['shopId'] as String,
  employeeId: (json['employeeId'] as num?)?.toInt(),
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  capturedAt: DateTime.parse(json['capturedAt'] as String),
  visitedAt: DateTime.parse(json['visitedAt'] as String),
);

Map<String, dynamic> _$VisitPayloadToJson(VisitPayload instance) =>
    <String, dynamic>{
      'shopId': instance.shopId,
      'lat': instance.lat,
      'lng': instance.lng,
      'accuracy': instance.accuracy,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'visitedAt': instance.visitedAt.toIso8601String(),
      'employeeId': instance.employeeId,
    };
