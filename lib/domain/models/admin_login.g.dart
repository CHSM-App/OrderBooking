// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminLogin _$AdminLoginFromJson(Map<String, dynamic> json) => AdminLogin(
      adminId: (json['admin_id'] as num?)?.toInt(),
      adminName: json['admin_name'] as String?,
      companyName: json['company_name'] as String?,
      mobileNo: json['mobile_no'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      gstinNo: json['gstin_no'] as String?,
      role_id: (json['role_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdminLoginToJson(AdminLogin instance) =>
    <String, dynamic>{
      'admin_id': instance.adminId,
      'admin_name': instance.adminName,
      'company_name': instance.companyName,
      'mobile_no': instance.mobileNo,
      'email': instance.email,
      'address': instance.address,
      'gstin_no': instance.gstinNo,
      'role_id': instance.role_id,
    };
