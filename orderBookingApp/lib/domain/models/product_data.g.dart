// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductData _$ProductDataFromJson(Map<String, dynamic> json) => ProductData(
  productName: json['product_name'] as String,
  companyId: json['company_id'] as String?,
  itemTotalPrice: (json['item_total_price'] as num?)?.toDouble(),
  totalSales: (json['total_sales'] as num?)?.toDouble(),
  orderDate: DateTime.parse(json['order_date'] as String),
);

Map<String, dynamic> _$ProductDataToJson(ProductData instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'total_sales': instance.totalSales,
      'order_date': instance.orderDate.toIso8601String(),
      'item_total_price': instance.itemTotalPrice,
      'company_id': instance.companyId,
    };
