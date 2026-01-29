import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'product_details_response.g.dart';

@JsonSerializable()
class ProductDetailsResponse {
  final Product product;
  final List<ProductSubType> subitems;

  ProductDetailsResponse({
    required this.product,
    required this.subitems,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailsResponseToJson(this);
}
