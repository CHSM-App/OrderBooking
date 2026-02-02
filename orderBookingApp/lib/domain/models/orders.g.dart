// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  localOrderId: json['localOrderId'] as String,
  employeeId: (json['employee_id'] as num).toInt(),
  shopId: (json['shop_id'] as num).toInt(),
  orderDate: json['order_date'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalPrice: (json['total_price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'localOrderId': instance.localOrderId,
  'employee_id': instance.employeeId,
  'shop_id': instance.shopId,
  'order_date': instance.orderDate,
  'total_price': instance.totalPrice,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
