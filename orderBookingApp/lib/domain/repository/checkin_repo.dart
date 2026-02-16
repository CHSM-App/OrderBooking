

import 'package:order_booking_app/domain/models/checkin_status.dart';

abstract class CheckinRepository {

  /// Employee check-in
  Future<CheckInStatusRequest> checkIn(
    int empId,
    double latitude,
    double longitude,
  );

  /// Employee check-out
  Future<CheckInStatusRequest> checkOut(int empId,     double latitude,
    double longitude,);

  /// Get today's attendance record
  Future<CheckInStatusRequest?> fetchTodayStatus(int empId);

  Future<List<CheckInStatusRequest>> getAttendance(int empId);
}
