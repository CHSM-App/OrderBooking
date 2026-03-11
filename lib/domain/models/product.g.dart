// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  orderDate: json['order_date'] == null
      ? null
      : DateTime.parse(json['order_date'] as String),
  quantityPerBox: (json['quantity_per_box'] as num?)?.toInt(),
  itemTotalPrice: (json['item_total_price'] as num?)?.toDouble(),
  productId: (json['product_id'] as num?)?.toInt(),
  productName: json['product_name'] as String?,
  productType: json['product_type'] as String?,
  createdBy: (json['created_by'] as num?)?.toInt(),
  companyId: json['company_id'] as String?,
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
  'quantity_per_box': instance.quantityPerBox,
  'product_id': instance.productId,
  'product_name': instance.productName,
  'product_type': instance.productType,
  'created_by': instance.createdBy,
  'company_id': instance.companyId,
  'employee_id': instance.employeeId,
  'admin_id': instance.adminId,
  'total_price': instance.totalPrice,
  'item_total_price': instance.itemTotalPrice,
};

ProductSubType _$ProductSubTypeFromJson(Map<String, dynamic> json) =>
    ProductSubType(
      subItemId: (json['sub_item_id'] as num?)?.toInt(),
      measuringUnit: json['measuring_unit'] as String?,
      availableUnit: (json['available_unit'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      quantityPerBox: (json['quantity_per_box'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductSubTypeToJson(ProductSubType instance) =>
    <String, dynamic>{
      'sub_item_id': instance.subItemId,
      'measuring_unit': instance.measuringUnit,
      'available_unit': instance.availableUnit,
      'price': instance.price,
      'quantity_per_box': instance.quantityPerBox,
    };
