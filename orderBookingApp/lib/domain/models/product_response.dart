import 'package:json_annotation/json_annotation.dart';

part 'product_response.g.dart';

@JsonSerializable()
class ProductResponse {
  final bool success;

  @JsonKey(name: 'product_id')
  final int? productId;

  final String message;

  ProductResponse({
    required this.success,
    this.productId,
    required this.message,
  });

  // JSON → Dart
  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);

  // Dart → JSON (rarely needed, but good practice)
  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}
