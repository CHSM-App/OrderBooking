// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInStatusRequest _$CheckInStatusRequestFromJson(
  Map<String, dynamic> json,
) => CheckInStatusRequest(
  message: json['message'] as String?,
  success: (json['success'] as num?)?.toInt(),
  empId: (json['emp_id'] as num?)?.toInt(),
  inDate: json['in_date'] as String?,
  inTime: json['in_time'] as String?,
  outDate: json['out_date'] as String?,
  outTime: json['out_time'] as String?,
  checkinStatus: (json['checkin_status'] as num?)?.toInt(),
);

Map<String, dynamic> _$CheckInStatusRequestToJson(
  CheckInStatusRequest instance,
) => <String, dynamic>{
  'emp_id': instance.empId,
  'in_date': instance.inDate,
  'in_time': instance.inTime,
  'out_date': instance.outDate,
  'out_time': instance.outTime,
  'checkin_status': instance.checkinStatus,
  'message': instance.message,
  'success': instance.success,
};
