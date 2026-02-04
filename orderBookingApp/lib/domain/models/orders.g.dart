// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  shopNamep: json['shop_name'] as String?,
  serverOrderId: (json['order_id'] as num?)?.toInt(),
  localOrderId: json['localOrderId'] as String?,
  employeeId: (json['employee_id'] as num).toInt(),
  shopId: (json['shop_id'] as num).toInt(),
  orderDate: json['order_date'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  address: json['address'] as String?,
  empName: json['emp_name'] as String?,
  companyId: json['company_id'] as String?,
  totalPrice: (json['total_price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'localOrderId': instance.localOrderId,
  'order_id': instance.serverOrderId,
  'employee_id': instance.employeeId,
  'shop_name': instance.shopNamep,
  'shop_id': instance.shopId,
  'emp_name': instance.empName,
  'order_date': instance.orderDate,
  'total_price': instance.totalPrice,
  'company_id': instance.companyId,
  'address': instance.address,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
