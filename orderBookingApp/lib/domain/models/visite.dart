import 'package:json_annotation/json_annotation.dart';

part 'visite.g.dart';

@JsonSerializable()
class VisitPayload {
  final String shopId;
  final double lat;
  final double lng;
  final double accuracy;
  final DateTime capturedAt;

  VisitPayload({
    required this.shopId,
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'capturedAt': capturedAt.toIso8601String(),
      };

  static VisitPayload fromJson(Map<String, dynamic> json) {
    return VisitPayload(
      shopId: json['shopId'],
      lat: json['lat'],
      lng: json['lng'],
      accuracy: json['accuracy'],
      capturedAt: DateTime.parse(json['capturedAt']),
    );
  }
}
