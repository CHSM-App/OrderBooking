import 'package:json_annotation/json_annotation.dart';

part 'employeeMap.g.dart';

@JsonSerializable()
class EmployeeMap {
  final String polyline;
  final int empId;
  final String checkIn;
  final String checkout;
  final double total_distance_km;
  final DateTime checkInDate;
  final List<Shop> shops;

  EmployeeMap({
    required this.polyline,
    required this.empId,
    required this.checkIn,
    required this.checkout,
    required this.checkInDate,
    required this.shops,
    required this.total_distance_km,
  });

  factory EmployeeMap.fromJson(Map<String, dynamic> json) {
    return EmployeeMap(
      polyline: json['polyline'] ?? '',
      empId: json['emp_id'] ?? 0,
      checkIn: json['checkIn'] ?? '',
      checkout: json['checkout'] ?? '',
      total_distance_km: (json['total_distance_km']).toDouble(),
      checkInDate: DateTime.parse(json['checkInDate']),
      shops: (json['shops'] as List<dynamic>? ?? [])
          .map((e) => Shop.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polyline': polyline,
      'emp_id': empId,
      'checkIn': checkIn,
      'checkout': checkout,
      'checkInDate': checkInDate.toIso8601String(),
      'shops': shops.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper: convert checkIn to LatLng
  List<double> get checkInLatLng =>
      checkIn.split(',').map((e) => double.parse(e)).toList();

  List<double> get checkOutLatLng =>
      checkout.split(',').map((e) => double.parse(e)).toList();
}

class Shop {
  final String shopName;
  final String address;
  final String ownerName;
  final String mobileNo;
  final double latitude;
  final double longitude;
  final String punchIn;   // ADD
  final String punchOut;  // ADD

  Shop({
    required this.shopName,
    required this.address,
    required this.ownerName,
    required this.mobileNo,
    required this.latitude,
    required this.longitude,
    required this.punchIn,
    required this.punchOut,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopName: json['shop_name'] ?? '',
      address: json['address'] ?? '',
      ownerName: json['owner_name'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      punchIn: json['punchIn'],    // ADD
      punchOut: json['punchOut'],  // ADD
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_name': shopName,
      'address': address,
      'owner_name': ownerName,
      'mobile_no': mobileNo,
      'latitude': latitude,
      'longitude': longitude,
      'punchIn': punchIn,
      'punchOut': punchOut,
    };
  }
}
