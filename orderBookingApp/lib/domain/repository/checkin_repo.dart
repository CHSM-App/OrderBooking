
import 'dart:io';

import 'package:order_booking_app/domain/models/checkin_status.dart';

abstract class CheckinRepository {

  /// Employee check-in
  Future<void> checkIn(int empId);

  /// Employee check-out
  Future<void> checkOut(int empId);

  /// Get today's attendance record
  Future<CheckInStatusRequest?> fetchTodayStatus(int empId);
}
