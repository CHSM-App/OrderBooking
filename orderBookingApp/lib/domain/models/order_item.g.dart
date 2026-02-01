// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  productId: (json['product_id'] as num).toInt(),
  subItemId: (json['sub_item_id'] as num).toInt(),
  productUnit: json['product_unit'] as String,
  price: (json['price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'product_id': instance.productId,
  'sub_item_id': instance.subItemId,
  'product_unit': instance.productUnit,
  'price': instance.price,
  'quantity': instance.quantity,
};
