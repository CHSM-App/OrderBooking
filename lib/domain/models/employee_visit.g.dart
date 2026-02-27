// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeVisit _$EmployeeVisitFromJson(Map<String, dynamic> json) =>
    EmployeeVisit(
      locationId: (json['locationId'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      empId: (json['empId'] as num).toInt(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      shopId: (json['shopId'] as num).toInt(),
      punchIn: json['punchIn'] == null
          ? null
          : DateTime.parse(json['punchIn'] as String),
      punchOut: json['punchOut'] == null
          ? null
          : DateTime.parse(json['punchOut'] as String),
      shopName: json['shopName'] as String?,
      ownerName: json['ownerName'] as String?,
      mobileNo: json['mobileNo'] as String?,
      address: json['address'] as String?,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EmployeeVisitToJson(EmployeeVisit instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'empId': instance.empId,
      'accuracy': instance.accuracy,
      'shopId': instance.shopId,
      'punchIn': instance.punchIn?.toIso8601String(),
      'punchOut': instance.punchOut?.toIso8601String(),
      'shopName': instance.shopName,
      'ownerName': instance.ownerName,
      'mobileNo': instance.mobileNo,
      'address': instance.address,
      'orders': instance.orders,
    };
