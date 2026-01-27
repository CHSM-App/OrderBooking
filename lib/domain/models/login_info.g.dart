// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginInfo _$LoginInfoFromJson(Map<String, dynamic> json) => LoginInfo(
      userId: (json['user_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      mobileNo: json['mobile_no'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      roleId: (json['role_id'] as num?)?.toInt(),
      role: json['role'] as String?,
      userType: json['user_type'] as String?,
      companyName: json['company_name'] as String?,
      gstinNo: json['gstin_no'] as String?,
      regionId: (json['region_id'] as num?)?.toInt(),
      joiningDate: json['joining_date'] as String?,
      activeStatus: (json['active_status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LoginInfoToJson(LoginInfo instance) => <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'mobile_no': instance.mobileNo,
      'email': instance.email,
      'address': instance.address,
      'role_id': instance.roleId,
      'role': instance.role,
      'user_type': instance.userType,
      'company_name': instance.companyName,
      'gstin_no': instance.gstinNo,
      'region_id': instance.regionId,
      'joining_date': instance.joiningDate,
      'active_status': instance.activeStatus,
    };
