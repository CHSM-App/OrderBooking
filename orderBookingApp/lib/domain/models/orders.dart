import 'package:json_annotation/json_annotation.dart';
import 'order_item.dart';

part 'orders.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {

  final String? localOrderId;

  @JsonKey(name: 'order_id')
  final int? serverOrderId;

  @JsonKey(name: 'employee_id')
  final int employeeId;

  @JsonKey(name : 'shop_name')
  final String? shopNamep;
  
  @JsonKey(name: 'shop_id')
  final int shopId;

  @JsonKey(name: 'order_date')
  final String orderDate;

  @JsonKey(name: 'total_price')
  final double totalPrice;

  @JsonKey(name: 'items')
  final List<OrderItem> items;

  Order({
    this.shopNamep,
    this.serverOrderId,
    this.localOrderId,
    required this.employeeId,
    required this.shopId,
    required this.orderDate,
    required this.items,
    double? totalPrice,
  }) : totalPrice =
          totalPrice ?? items.fold(0, (sum, i) => sum + i.totalPrice);

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
