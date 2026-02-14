import 'package:order_booking_app/domain/models/orders.dart';

class EmployeeVisit {
  final int locationId;
  final double latitude;
  final double longitude;
  final int empId;
  final double? accuracy;
  final int shopId;
  final DateTime? punchIn;
  final DateTime? punchOut;
  final String? shopName;
  final String? ownerName;
  final String? mobileNo;
  final String? address;
  final List<Order>? orders;

  const EmployeeVisit({
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.empId,
    this.accuracy,
    required this.shopId,
    this.punchIn,
    this.punchOut,
    this.shopName,
    this.ownerName,
    this.mobileNo,
    this.address,
    this.orders,
  });

  factory EmployeeVisit.fromJson(Map<String, dynamic> json) {
    final ordersJson = json['orders'];
    return EmployeeVisit(
      locationId: json['location_id'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      empId: json['emp_id'] as int,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      shopId: json['shop_id'] as int,
      punchIn: json['punchIn'] != null
          ? DateTime.tryParse(json['punchIn'] as String)
          : null,
      punchOut: json['punchOut'] != null
          ? DateTime.tryParse(json['punchOut'] as String)
          : null,
      shopName: json['shop_name'] as String?,
      ownerName: json['owner_name'] as String?,
      mobileNo: json['mobile_no'] as String?,
      address: json['address'] as String?,
      orders: ordersJson is List
          ? ordersJson
              .whereType<Map>()
              .map((order) => Order.fromJson(
                    Map<String, dynamic>.from(order),
                  ))
              .toList()
          : null,
    );
  }
}
