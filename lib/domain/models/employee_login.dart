import 'package:json_annotation/json_annotation.dart';

part 'employee_login.g.dart';

@JsonSerializable()
class EmployeeLogin {
  @JsonKey(name: 'emp_name')
  final String? empName;

  @JsonKey(name: 'emp_mobile')
  final String? empMobile;

  @JsonKey(name: 'emp_address')
  final String? empAddress;

  @JsonKey(name: 'emp_email')
  final String? empEmail;

  @JsonKey(name: 'region_id')
  final int? regionId;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'id_proof')
  final String? idProof;
   @JsonKey(name: 'active_status')
  final int? activeStatus;
   @JsonKey(name: 'emp_id')
  final int? empId;

  EmployeeLogin({
    this.empName,
    this.empMobile,
    this.empAddress,
    this.empEmail,
    this.regionId,
    this.imageUrl,
    this.idProof,
    this.activeStatus,
    this.empId,
  });

  // JSON deserialization
  factory EmployeeLogin.fromJson(Map<String, dynamic> json) =>
      _$EmployeeLoginFromJson(json);

  // JSON serialization
  Map<String, dynamic> toJson() => _$EmployeeLoginToJson(this);
}
