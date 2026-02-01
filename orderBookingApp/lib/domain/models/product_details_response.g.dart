// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDetailsResponse _$ProductDetailsResponseFromJson(
  Map<String, dynamic> json,
) => ProductDetailsResponse(
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  subitems: (json['subitems'] as List<dynamic>)
      .map((e) => ProductSubType.fromJson(e as Map<String, dynamic>))
      .toList(),
)..productName = json['productName'];

Map<String, dynamic> _$ProductDetailsResponseToJson(
  ProductDetailsResponse instance,
) => <String, dynamic>{
  'product': instance.product,
  'subitems': instance.subitems,
  'productName': instance.productName,
};
