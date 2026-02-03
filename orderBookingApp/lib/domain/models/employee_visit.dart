class EmployeeVisit {
  final int locationId;
  final double latitude;
  final double longitude;
  final String date;
  final String time;
  final int empId;
  final double accuracy;
  final int shopId;

  const EmployeeVisit({
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.time,
    required this.empId,
    required this.accuracy,
    required this.shopId,
  });

  factory EmployeeVisit.fromJson(Map<String, dynamic> json) {
    return EmployeeVisit(
      locationId: json['location_id'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      date: json['date'] as String,
      time: json['time'] as String,
      empId: json['emp_id'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      shopId: json['shop_id'] as int,
    );
  }
}
