import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable(explicitToJson: true)
class Product {
  @JsonKey(name: 'product_id')
  final int? productId;

  @JsonKey(name: 'product_name')
  final String? productName;

  @JsonKey(name: 'product_type')
  final String? productType;

  @JsonKey(name: 'created_by')
  final int? createdBy;

 @JsonKey(name: 'admin_id')
  final int? adminId;
  @JsonKey(name: 'subtypes')
  final List<ProductSubType>? subtypes;

    @JsonKey(name: 'company_id')
  final String? companyId;

  Product({
    this.productId,
    this.productName,
    this.productType,
    this.createdBy,
    this.adminId,
    this.subtypes,
    this.companyId
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class ProductSubType {
    @JsonKey(name: 'sub_item_id')
  final int? subItemId;
  @JsonKey(name: 'measuring_unit')
  final String? measuringUnit;

  @JsonKey(name: 'available_unit')
  final double? availableUnit;

  @JsonKey(name: 'price')
  final double? price;

  ProductSubType({
    this.subItemId,
    this.measuringUnit,
    this.availableUnit,
    this.price,
  });

  factory ProductSubType.fromJson(Map<String, dynamic> json) =>
      _$ProductSubTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSubTypeToJson(this);
}
