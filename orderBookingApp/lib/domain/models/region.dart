import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

@JsonSerializable()
class Region {

  @JsonKey(name: 'region_id')
  final int? regionId;

  @JsonKey(name: 'region_name')
  final String? regionName;

  @JsonKey(name: 'pincode')
  final String? pincode;

  @JsonKey(name: 'district')
  final String? district;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  Region({
    this.regionId,
    this.regionName,
    this.pincode,
    this.district,
    this.state,
    this.createdBy,
  });


  factory Region.fromJson(Map<String, dynamic> json) =>
      _$RegionFromJson(json);

  /// To API JSON
  Map<String, dynamic> toJson() => _$RegionToJson(this);
}
