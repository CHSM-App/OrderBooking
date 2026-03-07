import 'package:json_annotation/json_annotation.dart';

part 'login_details.g.dart';

@JsonSerializable()
class AdminLogin {

  @JsonKey(name: 'admin_id')
  final int? adminId;

  @JsonKey(name: 'token')
  final String? Token;

  @JsonKey(name: 'admin_name')
  final String? adminName;

  @JsonKey(name: 'company_name')
  final String? companyName;

  @JsonKey(name: 'mobile_no')
  final String? mobileNo;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'gstin_no')
  final String? gstinNo;

   @JsonKey(name: 'company_id')
  final String? companyId;
  
  @JsonKey(name: 'role_id')
  final int? role_id;

  @JsonKey(name: 'is_superadmin')
  final bool? isSuperadmin;





  AdminLogin({
    this.Token,
    this.adminId,
    this.adminName,
    this.companyName,
    this.mobileNo,
    this.email,
    this.address,
    this.gstinNo,
    this.role_id,
    this.companyId,
    this.isSuperadmin,
  });

  /// 🔹 From JSON
  factory AdminLogin.fromJson(Map<String, dynamic> json) =>
      _$AdminLoginFromJson(json);

  /// 🔹 To JSON (used for Insert / Update)
  Map<String, dynamic> toJson() => _$AdminLoginToJson(this);
}

