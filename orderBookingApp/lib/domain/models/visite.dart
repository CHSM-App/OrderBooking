import 'package:json_annotation/json_annotation.dart';

part 'visite.g.dart';

@JsonSerializable(explicitToJson: true)
class VisitPayload {
  final String? localId;

  @JsonKey(name: 'shop_id')
  final int? shopId;

  final double? lat;
  final double? lng;

  @JsonKey(name: 'punch_in')
  final String punchIn;

  @JsonKey(name: 'punch_out')
  final String? punchOut;

  @JsonKey(name: 'employee_id')
  final int? employeeId;

  @JsonKey(name: 'region_name')
  final String? regionName;

  @JsonKey(name: 'shop_name')
  final String? shopName;

  @JsonKey(name: 'owner_name')
  final String? ownerName;

  final String? address;

  @JsonKey(name: 'mobile_no')
  final String? mobileNo;

  final String? email;

  final double? accuracy;

  @JsonKey(name: 'captured_at')
  final DateTime? capturedAt;

  VisitPayload({
    this.localId,
    this.shopId,
    this.lat,
    this.lng,
    required this.punchIn,
    this.punchOut,
    this.employeeId,
    this.regionName,
    this.shopName,
    this.ownerName,
    this.address,
    this.mobileNo,
    this.email,
    this.accuracy,
    this.capturedAt,
  });

  factory VisitPayload.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // Normalize different backend key styles
    normalized['shop_id'] ??= json['shopId'];
    normalized['employee_id'] ??= json['employeeId'];
    normalized['punch_in'] ??= json['punchIn'];
    normalized['punch_out'] ??= json['punchOut'];
    normalized['region_name'] ??= json['regionName'];
    normalized['shop_name'] ??= json['shopName'];
    normalized['owner_name'] ??= json['ownerName'];
    normalized['mobile_no'] ??= json['mobileNo'];
    normalized['captured_at'] ??= json['capturedAt'];

    return _$VisitPayloadFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$VisitPayloadToJson(this);

  /// For SQLite storage (include localId)
  Map<String, dynamic> toLocalJson() => {
        'localId': localId,
        ...toJson(),
      };
}
