import 'package:json_annotation/json_annotation.dart';

part 'product_data.g.dart'; // <-- this is required for code generation

@JsonSerializable()
class ProductData {
  @JsonKey(name: 'product_name')
  final String productName;

  @JsonKey(name: 'total_sales')
  final double? totalSales;

  @JsonKey(name: 'order_date')
  final DateTime orderDate;

  @JsonKey(name: 'item_total_price')
  final double? itemTotalPrice;

  @JsonKey(name: 'company_id')
  final String? companyId;

  @JsonKey(name: 'region_name')
  final String? regionName;

  @JsonKey(name: 'emp_name')
  final String? emp_name;

  @JsonKey(name: 'company_name')
  final String? companyName;

  final int? type;

  ProductData({
    this.type,
    required this.productName,
    this.companyId,
    this.itemTotalPrice,
    this.totalSales,
    required this.orderDate,
    this.regionName,
    this.emp_name,
    this.companyName,
  });
  // factory constructor for JSON deserialization
  factory ProductData.fromJson(Map<String, dynamic> json) =>
      _$ProductDataFromJson(json);

  // method for JSON serialization
  Map<String, dynamic> toJson() => _$ProductDataToJson(this);
}
