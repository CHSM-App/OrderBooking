// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInStatusRequest _$CheckInStatusRequestFromJson(
  Map<String, dynamic> json,
) => CheckInStatusRequest(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  message: json['message'] as String?,
  success: (json['success'] as num?)?.toInt(),
  empId: (json['emp_id'] as num?)?.toInt(),
  inDate: json['checkIn'] as String?,
  outDate: json['checkOut'] as String?,
  checkinStatus: (json['checkin_status'] as num?)?.toInt(),
  totalDistance: (json['total_distance_km'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CheckInStatusRequestToJson(
  CheckInStatusRequest instance,
) => <String, dynamic>{
  'emp_id': instance.empId,
  'checkIn': instance.inDate,
  'checkOut': instance.outDate,
  'checkin_status': instance.checkinStatus,
  'message': instance.message,
  'success': instance.success,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'total_distance_km': instance.totalDistance,
};
