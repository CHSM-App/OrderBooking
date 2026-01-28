// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDetails _$ProductDetailsFromJson(Map<String, dynamic> json) =>
    ProductDetails(
      productId: (json['product_id'] as num?)?.toInt(),
      productName: json['product_name'] as String?,
      productType: json['product_type'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ProductDetailsToJson(ProductDetails instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_type': instance.productType,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
    };
