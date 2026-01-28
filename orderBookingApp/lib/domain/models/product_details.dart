import 'package:json_annotation/json_annotation.dart';

part 'product_details.g.dart';

@JsonSerializable()
class ProductDetails {

  @JsonKey(name: 'product_id')
  final int? productId;

  @JsonKey(name: 'product_name')
  final String? productName;

  @JsonKey(name: 'product_type')
  final String? productType;

    @JsonKey(name: 'created_by')
  final String? createdBy;

    @JsonKey(name: 'created_at')
  final String? createdAt;

  ProductDetails({
    this.productId,
    this.productName,
    this.productType,
    this.createdBy,
    this.createdAt,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailsToJson(this);
}
 