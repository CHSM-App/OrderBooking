  import 'package:json_annotation/json_annotation.dart';

  part 'employee.g.dart';

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
   String? idProof;

   @JsonKey(name: 'active_status')
  final int? activeStatus;

   @JsonKey(name: 'emp_id')
  final int? empId;

  @JsonKey(name: 'joining_date')
  final String? joiningDate;
  
  @JsonKey(name: 'role_id')
  final int? roleId;
  
  @JsonKey(name: 'company_id')
  final String? companyId;

  @JsonKey(name: 'admin_id')
  final int? adminId;

  @JsonKey(name: 'region_name')
  final String? regionName;

   @JsonKey(name: 'company_name')
  final String? companyName;

  @JsonKey(name : 'checkin_status')
  final int? checkinStatus;






 
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
    this.joiningDate,
    this.roleId,
    this.companyId,
    this.adminId,
    this.regionName,
    this.companyName,
    this.checkinStatus,
  });

    // JSON deserialization
    factory EmployeeLogin.fromJson(Map<String, dynamic> json) =>
        _$EmployeeLoginFromJson(json);

  

    // JSON serialization
    Map<String, dynamic> toJson() => _$EmployeeLoginToJson(this);
  }
