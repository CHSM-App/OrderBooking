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

  @JsonKey(name : 'emp_name')
  final String? empName;

  @JsonKey(name: 'order_date')
  final String orderDate;

  @JsonKey(name: 'total_price')
  final double totalPrice;

   @JsonKey(name: 'company_id')
  final String? companyId;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'items')
  final List<OrderItem> items;

  @JsonKey(name: 'owner_name')
  final String? ownerName;

  @JsonKey(name: 'region_name')
  final String? regionName;

  @JsonKey(name: 'mobile_no')
  final String? mobileNo;
  final String? status;  

  Order({
    this.mobileNo,
    this.regionName,
    this.shopNamep,
    this.serverOrderId,
    this.localOrderId,
    required this.employeeId,
    required this.shopId,
    required this.orderDate,
    required this.items,
    this.address,
    this.empName,
    this.companyId,
    this.ownerName,
    double? totalPrice,
    this.status,
  }) : totalPrice =
          totalPrice ?? items.fold(0, (sum, i) => sum + i.totalPrice);

  factory Order.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['order_id'] ??= json['orderId'];
    normalized['employee_id'] ??= json['employeeId'];
    normalized['shop_id'] ??= json['shopId'];
    normalized['shop_name'] ??= json['shopName'];
    normalized['emp_name'] ??=
        json['employee_name'] ?? json['employeeName'] ?? json['empName'];
    normalized['address'] ??= json['shop_address'] ?? json['shopAddress'];
    normalized['order_date'] ??= json['orderDate'];
    normalized['total_price'] ??= json['totalPrice'];
    normalized['company_id'] ??= json['companyId'];
    normalized['owner_name'] ??= json['ownerName'];
    normalized['region_name'] ??= json['regionName'];
    normalized['mobile_no'] ??= json['mobileNo'];

    return _$OrderFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
