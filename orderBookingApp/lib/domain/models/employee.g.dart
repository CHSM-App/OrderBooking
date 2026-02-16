// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeLogin _$EmployeeLoginFromJson(Map<String, dynamic> json) =>
    EmployeeLogin(
      empName: json['emp_name'] as String?,
      empMobile: json['emp_mobile'] as String,
      empAddress: json['emp_address'] as String?,
      empEmail: json['emp_email'] as String?,
      regionId: (json['region_id'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      idProof: json['id_proof'] as String?,
      activeStatus: (json['active_status'] as num?)?.toInt(),
      empId: (json['emp_id'] as num?)?.toInt(),
      joiningDate: json['joining_date'] as String?,
      roleId: (json['role_id'] as num?)?.toInt(),
      companyId: json['company_id'] as String?,
      adminId: (json['admin_id'] as num?)?.toInt(),
      regionName: json['region_name'] as String?,
      companyName: json['company_name'] as String?,
      checkinStatus: (json['checkin_status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmployeeLoginToJson(EmployeeLogin instance) =>
    <String, dynamic>{
      'emp_name': instance.empName,
      'emp_mobile': instance.empMobile,
      'emp_address': instance.empAddress,
      'emp_email': instance.empEmail,
      'region_id': instance.regionId,
      'image_url': instance.imageUrl,
      'id_proof': instance.idProof,
      'active_status': instance.activeStatus,
      'emp_id': instance.empId,
      'joining_date': instance.joiningDate,
      'role_id': instance.roleId,
      'company_id': instance.companyId,
      'admin_id': instance.adminId,
      'region_name': instance.regionName,
      'company_name': instance.companyName,
      'checkin_status': instance.checkinStatus,
    };
