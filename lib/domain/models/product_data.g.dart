// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductData _$ProductDataFromJson(Map<String, dynamic> json) => ProductData(
  type: (json['type'] as num?)?.toInt(),
  productName: json['product_name'] as String,
  companyId: json['company_id'] as String?,
  itemTotalPrice: (json['item_total_price'] as num?)?.toDouble(),
  totalSales: (json['total_sales'] as num?)?.toDouble(),
  orderDate: DateTime.parse(json['order_date'] as String),
  regionName: json['region_name'] as String?,
  emp_name: json['emp_name'] as String?,
  companyName: json['company_name'] as String?,
);

Map<String, dynamic> _$ProductDataToJson(ProductData instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'total_sales': instance.totalSales,
      'order_date': instance.orderDate.toIso8601String(),
      'item_total_price': instance.itemTotalPrice,
      'company_id': instance.companyId,
      'region_name': instance.regionName,
      'emp_name': instance.emp_name,
      'company_name': instance.companyName,
      'type': instance.type,
    };
