import 'package:json_annotation/json_annotation.dart';

part 'visite.g.dart';

@JsonSerializable()
class VisitPayload {
  /// Local-only unique ID for offline sync
  final String localId;

  final int shopId;
  final double lat;
  final double lng;
  final double accuracy;
  final DateTime capturedAt;
  final DateTime visitedAt;
  final int? employeeId;

  VisitPayload({
    required this.localId,
    required this.shopId,
    this.employeeId,
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.capturedAt,
    required this.visitedAt,
  });

  /// Payload sent to backend
  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'capturedAt': capturedAt.toIso8601String(),
        'visitedAt': visitedAt.toIso8601String(),
        'employeeId': employeeId,
      };

  /// Full JSON including localId (for SQLite)
  Map<String, dynamic> toLocalJson() => {
        'localId': localId,
        ...toJson(),
      };

  factory VisitPayload.fromJson(Map<String, dynamic> json) {
    return VisitPayload(
      localId: json['localId'],
      shopId: json['shopId'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      capturedAt: DateTime.parse(json['capturedAt']),
      visitedAt: DateTime.parse(json['visitedAt']),
      employeeId: json['employeeId'],
    );
  }
}
