import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class AttendanceReport {
  @JsonKey(name: 'emp_id')
  final int? empId;

  @JsonKey(name: 'emp_name')
  final String? empName;

  @JsonKey(name: 'total_working_days')
  final int? totalWorkingDays;

  @JsonKey(name: 'total_hours')
  final double? totalHours;

  @JsonKey(name: 'company_id')
  final String? companyId;

  @JsonKey(name: 'month')
  final String? month;

  AttendanceReport({
     this.empId,
     this.empName,
     this.totalWorkingDays,
     this.totalHours,
     this.companyId,
      this.month
  });


   factory AttendanceReport.fromJson(Map<String, dynamic> json) =>
      _$AttendanceReportFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceReportToJson(this);
}
