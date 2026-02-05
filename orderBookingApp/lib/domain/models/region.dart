import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

@JsonSerializable()
class Region {
 
 
  @JsonKey(ignore: true)
  final String? localId; 
  // offline tracking
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

   @JsonKey(name: 'company_id')
  final String? companyId;

  @JsonKey(ignore: true)
  final String? syncStatus;
  Region({
      this.localId,
    this.regionId,
    this.regionName,
    this.pincode,
    this.district,
    this.state,
    this.createdBy,
    this.companyId,
       this.syncStatus,
  });


  factory Region.fromJson(Map<String, dynamic> json) =>
      _$RegionFromJson(json);

  /// To API JSON
  Map<String, dynamic> toJson() => _$RegionToJson(this);

    /// For SQLite
  Map<String, dynamic> toLocalJson() => {
        'localId': localId,
        ...toJson(),
      };
       /// ✅ Add this
 factory Region.fromLocalJson(Map<String, dynamic> json, {String? localId}) {
  return Region(
    localId: localId,
    regionId: json['region_id'] as int?,
    regionName: json['region_name'] as String?,
    pincode: json['pincode'] as String?,
    district: json['district'] as String?,
    state: json['state'] as String?,
    createdBy: json['created_by'] as int?,
    companyId: json['company_id'] as String?,
  );
}

}
