import 'package:json_annotation/json_annotation.dart';

part 'checkin_status.g.dart';

@JsonSerializable()
class CheckInStatusRequest {

  @JsonKey(name: 'emp_id')
  final int? empId;

  @JsonKey(name: 'in_date')
  final String? inDate;

  @JsonKey(name: 'in_time')
  final String? inTime;

  @JsonKey(name: 'out_date')
  final String? outDate;

  @JsonKey(name: 'out_time')
  final String? outTime;

  @JsonKey(name: 'checkin_status')
  final int? checkinStatus;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'success')
  final int? success;

  @JsonKey(name : 'latitude')
  final double? latitude;

  @JsonKey(name : 'longitude')
  final double? longitude;



  CheckInStatusRequest({
    this.latitude,
    this.longitude,
    this.message,
    this.success,
    this.empId,
    this.inDate,
    this.inTime,
    this.outDate,
    this.outTime,
    this.checkinStatus,
  });

  factory CheckInStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckInStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInStatusRequestToJson(this);
}
