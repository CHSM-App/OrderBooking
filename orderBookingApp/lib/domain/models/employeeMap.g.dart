// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employeeMap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeMap _$EmployeeMapFromJson(Map<String, dynamic> json) => EmployeeMap(
  polyline: json['polyline'] as String,
  empId: (json['empId'] as num).toInt(),
  checkIn: json['checkIn'] as String,
  checkout: json['checkout'] as String,
  checkInDate: DateTime.parse(json['checkInDate'] as String),
  checkOutDate: DateTime.parse(json['checkOutDate'] as String),
  shops: (json['shops'] as List<dynamic>)
      .map((e) => Shop.fromJson(e as Map<String, dynamic>))
      .toList(),
  total_distance_km: (json['total_distance_km'] as num).toDouble(),
);

Map<String, dynamic> _$EmployeeMapToJson(EmployeeMap instance) =>
    <String, dynamic>{
      'polyline': instance.polyline,
      'empId': instance.empId,
      'checkIn': instance.checkIn,
      'checkout': instance.checkout,
      'total_distance_km': instance.total_distance_km,
      'checkInDate': instance.checkInDate.toIso8601String(),
      'checkOutDate': instance.checkOutDate.toIso8601String(),
      'shops': instance.shops,
    };
