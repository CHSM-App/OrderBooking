import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  @JsonKey(name: 'product_id')
  final int productId;

  @JsonKey(name:'product_name')
  final String? productName;

  @JsonKey(name: 'sub_item_id')
  final int subItemId;

  @JsonKey(name: 'product_unit')
  final String productUnit;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'total_price')
  final double totalPrice;

  @JsonKey(name: 'measuring_unit')
  final String? measuringUnit;

  OrderItem({
    this.productName,
    this.measuringUnit,
    required this.productId,
    required this.subItemId,
    required this.productUnit,
    required this.price,
    required this.quantity,
    double? totalPrice,
  }) : totalPrice = price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
