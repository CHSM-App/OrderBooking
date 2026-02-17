// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceReport _$AttendanceReportFromJson(Map<String, dynamic> json) =>
    AttendanceReport(
      empId: (json['emp_id'] as num?)?.toInt(),
      empName: json['emp_name'] as String?,
      totalWorkingDays: (json['total_working_days'] as num?)?.toInt(),
      totalHours: (json['total_hours'] as num?)?.toDouble(),
      companyId: json['company_id'] as String?,
      month: json['month'] as String?,
    );

Map<String, dynamic> _$AttendanceReportToJson(AttendanceReport instance) =>
    <String, dynamic>{
      'emp_id': instance.empId,
      'emp_name': instance.empName,
      'total_working_days': instance.totalWorkingDays,
      'total_hours': instance.totalHours,
      'company_id': instance.companyId,
      'month': instance.month,
    };
