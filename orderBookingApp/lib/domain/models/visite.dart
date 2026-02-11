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
  final String punchIn;
  final int? employeeId;
  final String? punchOut;

  VisitPayload({
    required this.localId,
    required this.shopId,
    this.employeeId,
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.capturedAt,
    required this.punchIn,
    this.punchOut,
  });

  static String formatForApi(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${dt.year}-'
        '${two(dt.month)}-'
        '${two(dt.day)} '
        '${two(dt.hour)}:'
        '${two(dt.minute)}:'
        '${two(dt.second)}';
  }

  static String? normalizeDateTimeForApi(String? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return formatForApi(parsed.toLocal());
  }

  /// Payload sent to backend
  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'capturedAt': capturedAt.toIso8601String(),
        'punchIn': normalizeDateTimeForApi(punchIn),
        'employeeId': employeeId,
        'punchOut': normalizeDateTimeForApi(punchOut),
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
      punchIn: json['punchIn'],
      employeeId: json['employeeId'],
      punchOut: json['punchOut'] ,
    );
  }
}
