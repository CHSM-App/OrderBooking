import 'package:json_annotation/json_annotation.dart';

part 'product_data.g.dart'; // <-- this is required for code generation

@JsonSerializable()
class ProductData {
  @JsonKey(name: 'product_name')
  final String productName;

  @JsonKey(name: 'total_sales')
  final double totalSales;

  @JsonKey(name: 'order_dates')
  final List<DateTime> orderDates;

  ProductData({
    required this.productName,
    required this.totalSales,
    required this.orderDates,
  });
 // factory constructor for JSON deserialization
  factory ProductData.fromJson(Map<String, dynamic> json) =>
      _$ProductDataFromJson(json);

  // method for JSON serialization
  Map<String, dynamic> toJson() => _$ProductDataToJson(this);
 
}
