// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductData _$ProductDataFromJson(Map<String, dynamic> json) => ProductData(
  productName: json['product_name'] as String,
  totalSales: (json['total_sales'] as num).toDouble(),
  orderDates: (json['order_dates'] as List<dynamic>)
      .map((e) => DateTime.parse(e as String))
      .toList(),
);

Map<String, dynamic> _$ProductDataToJson(
  ProductData instance,
) => <String, dynamic>{
  'product_name': instance.productName,
  'total_sales': instance.totalSales,
  'order_dates': instance.orderDates.map((e) => e.toIso8601String()).toList(),
};
