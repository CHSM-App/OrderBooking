import 'package:json_annotation/json_annotation.dart';

part 'visite.g.dart';

@JsonSerializable()
// class VisitPayload {
//   /// Local-only unique ID for offline sync
//   final String? localId;
//   final int? shopId;
//   final double? lat;
//   final double? lng;
//   final double? accuracy;
//   final DateTime? capturedAt;
//   final String? punchIn;
//   final int? employeeId;
//   final String? punchOut;
//   final String? regionName;
//   final String? shopName;
//   final String? email;

//   VisitPayload({
//     this.localId,
//     this.shopId,
//     this.regionName,
//     this.shopName,
//     this.employeeId,
//     this.lat,
//     this.lng,
//     this.accuracy,
//     this.capturedAt,
//     this.punchIn,
//     this.punchOut,
//     this.email
//   });

class VisitPayload {
  final String? localId;
  final int? shopId;
  final double? lat;
  final double? lng;
  final String punchIn;
  final String? punchOut;
  final int? employeeId;
  final String? regionName;
  final String? shopName;
  final String? ownerName;
  final String? address;
  final String? mobileNo;
  final String? email;
  final double? accuracy;
 final DateTime? capturedAt;

  VisitPayload({
    this.localId,
    this.shopId,
    this.lat,
    this.lng,
    required this.punchIn,
   this.punchOut,
     this.employeeId,
    this.regionName,
    this.shopName,
    this.ownerName,
    this.address,
    this.mobileNo,
    this.email,
    this.accuracy,
     this.capturedAt

  });

  /// Payload sent to backend
  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'capturedAt': capturedAt!.toIso8601String(),
        'punchIn': punchIn,
        'employeeId': employeeId,
        'punchOut': punchOut,
        'shop_name': shopName,
        'region_name': regionName,
        'email' : email
      };


 


  /// Full JSON including localId (for SQLite)
  Map<String, dynamic> toLocalJson() => {
        'localId': localId,
        ...toJson(),
      };

  // factory VisitPayload.fromJson(Map<String, dynamic> json) {
  //   return VisitPayload(
  //     localId: json['localId'],
  //     shopId: json['shopId'],
  //     lat: (json['lat'] as num?)?.toDouble(),
  //     lng: (json['lng'] as num?)?.toDouble(),
  //     accuracy: (json['accuracy'] as num?)?.toDouble(),
  //     capturedAt: DateTime.parse(json['capturedAt']),
  //     punchIn: json['punchIn'],
  //     employeeId: json['employeeId'],
  //     punchOut: json['punchOut'] ,
  //     regionName: json['region_name'] ,
  //     shopName: json['shop_name'] ,
  //     email:json['email']
  //   );
  // }

   factory VisitPayload.fromJson(Map<String, dynamic> json) {
    return VisitPayload(
      shopId: json['location_id'] as int?, // ✅ FIX
      employeeId: json['emp_id'] as int?,

      lat: (json['latitude'] as num?)?.toDouble(),   // ✅ FIX
      lng: (json['longitude'] as num?)?.toDouble(),  // ✅ FIX

      punchIn: json['punchIn'] ,

      punchOut: json['punchOut'] ,

      shopName: json['shop_name']?.toString(),
      ownerName: json['owner_name']?.toString(),
      address: json['address']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      email: json['email']?.toString(),
      regionName: json['region_name']?.toString(),
    );
  }

}
