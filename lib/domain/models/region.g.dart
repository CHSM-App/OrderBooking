// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
  regionId: (json['region_id'] as num?)?.toInt(),
  regionName: json['region_name'] as String?,
  pincode: json['pincode'] as String?,
  district: json['district'] as String?,
  state: json['state'] as String?,
  createdBy: (json['created_by'] as num?)?.toInt(),
);

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
  'region_id': instance.regionId,
  'region_name': instance.regionName,
  'pincode': instance.pincode,
  'district': instance.district,
  'state': instance.state,
  'created_by': instance.createdBy,
};
