import 'package:json_annotation/json_annotation.dart';

part 'login_info.g.dart';

@JsonSerializable()
class LoginInfo {
  // Common fields
  @JsonKey(name: 'user_id')
  final int? userId;

  final String? name;

    @JsonKey(name: 'token')
  final String? Token;

  @JsonKey(name: 'mobile_no')
  final String? mobileNo;

  final String? email;

  final String? address;

  @JsonKey(name: 'role_id')
  final int? roleId;

  final String? role;

  @JsonKey(name: 'user_type')
  final String? userType; // ADMIN / EMPLOYEE

  // Admin-specific
  @JsonKey(name: 'company_name')
  final String? companyName;

  @JsonKey(name: 'gstin_no')
  final String? gstinNo;

  // Employee-specific
  @JsonKey(name: 'region_id')
  final int? regionId;

  @JsonKey(name: 'joining_date')
  final String? joiningDate;

  @JsonKey(name: 'active_status')
  final int? activeStatus;

  @JsonKey(name: 'isCheckedIn')
  final String? isCheckedIn;

    @JsonKey(name: 'admin_id')
  final int? adminId;
    @JsonKey(name: 'emp_id')
  final int? empId;

  LoginInfo({
    this.isCheckedIn,
    this.Token,
    this.userId,
    this.name,
    this.mobileNo,
    this.email,
    this.address,
    this.roleId,
    this.role,
    this.userType,
    this.companyName,
    this.gstinNo,
    this.regionId,
    this.joiningDate,
    this.activeStatus,
    this.adminId,
    this.empId
  });

  /// From JSON
  factory LoginInfo.fromJson(Map<String, dynamic> json) =>
      _$LoginInfoFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _$LoginInfoToJson(this);
}
