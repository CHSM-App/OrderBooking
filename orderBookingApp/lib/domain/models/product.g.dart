// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  orderDate: json['order_date'] == null
      ? null
      : DateTime.parse(json['order_date'] as String),
  itemTotalPrice: (json['item_total_price'] as num?)?.toDouble(),
  productId: (json['product_id'] as num?)?.toInt(),
  productName: json['product_name'] as String?,
  productType: json['product_type'] as String?,
  createdBy: (json['created_by'] as num?)?.toInt(),
  companyId: json['company_id'] as String?,
  subtypes: (json['subtypes'] as List<dynamic>?)
      ?.map((e) => ProductSubType.fromJson(e as Map<String, dynamic>))
      .toList(),
  employeeId: (json['employee_id'] as num?)?.toInt(),
  adminId: (json['admin_id'] as num?)?.toInt(),
  totalPrice: (json['total_price'] as num?)?.toDouble(),
  productUnit: json['productUnit'] as String?,
  shopId: (json['shopId'] as num?)?.toInt(),
  totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0,
  orderDates:
      (json['orderDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'product_id': instance.productId,
  'product_name': instance.productName,
  'product_type': instance.productType,
  'created_by': instance.createdBy,
  'company_id': instance.companyId,
  'subtypes': instance.subtypes?.map((e) => e.toJson()).toList(),
  'employee_id': instance.employeeId,
  'admin_id': instance.adminId,
  'total_price': instance.totalPrice,
  'item_total_price': instance.itemTotalPrice,
  'productUnit': instance.productUnit,
  'shopId': instance.shopId,
  'order_date': instance.orderDate?.toIso8601String(),
  'totalSales': instance.totalSales,
  'orderDates': instance.orderDates.map((e) => e.toIso8601String()).toList(),
};

ProductSubType _$ProductSubTypeFromJson(Map<String, dynamic> json) =>
    ProductSubType(
      subItemId: (json['sub_item_id'] as num?)?.toInt(),
      measuringUnit: json['measuring_unit'] as String?,
      availableUnit: (json['available_unit'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProductSubTypeToJson(ProductSubType instance) =>
    <String, dynamic>{
      'sub_item_id': instance.subItemId,
      'measuring_unit': instance.measuringUnit,
      'available_unit': instance.availableUnit,
      'price': instance.price,
    };
