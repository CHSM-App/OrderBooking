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
  productUnit: json['product_unit'] as String?,
  shopId: (json['shop_id'] as num?)?.toInt(),
  totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0,
  orderDates:
      (json['order_dates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      if (instance.productId case final value?) 'product_id': value,
      if (instance.productName case final value?) 'product_name': value,
      if (instance.productType case final value?) 'product_type': value,
      if (instance.createdBy case final value?) 'created_by': value,
      if (instance.companyId case final value?) 'company_id': value,
      if (instance.subtypes case final value?)
        'subtypes': value.map((e) => e.toJson()).toList(),
      if (instance.employeeId case final value?) 'employee_id': value,
      if (instance.adminId case final value?) 'admin_id': value,
      if (instance.totalPrice case final value?) 'total_price': value,
      if (instance.itemTotalPrice case final value?) 'item_total_price': value,
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
