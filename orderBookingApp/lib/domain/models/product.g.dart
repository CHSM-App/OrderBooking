// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  productId: (json['product_id'] as num?)?.toInt(),
  productName: json['product_name'] as String?,
  productType: json['product_type'] as String?,
  createdBy: (json['created_by'] as num?)?.toInt(),
  adminId: (json['admin_id'] as num?)?.toInt(),
  subtypes: (json['subtypes'] as List<dynamic>?)
      ?.map((e) => ProductSubType.fromJson(e as Map<String, dynamic>))
      .toList(),
  companyId: json['company_id'] as String?,
  productUnit: json['productUnit'] as String?,
  employeeId: (json['employee_id'] as num?)?.toInt(),
  shopId: (json['shopId'] as num?)?.toInt(),
  TotalPrice: (json['TotalPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'product_id': instance.productId,
  'product_name': instance.productName,
  'employee_id': instance.employeeId,
  'product_type': instance.productType,
  'created_by': instance.createdBy,
  'admin_id': instance.adminId,
  'subtypes': instance.subtypes?.map((e) => e.toJson()).toList(),
  'company_id': instance.companyId,
  'productUnit': instance.productUnit,
  'TotalPrice': instance.TotalPrice,
  'shopId': instance.shopId,
};

ProductSubType _$ProductSubTypeFromJson(Map<String, dynamic> json) =>
    ProductSubType(
      subItemId: (json['sub_item_id'] as num?)?.toInt(),
      measuringUnit: json['measuring_unit'] as String?,
      availableUnit: (json['available_unit'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductSubTypeToJson(ProductSubType instance) =>
    <String, dynamic>{
      'sub_item_id': instance.subItemId,
      'measuring_unit': instance.measuringUnit,
      'available_unit': instance.availableUnit,
      'price': instance.price,
      'total': instance.total,
    };
