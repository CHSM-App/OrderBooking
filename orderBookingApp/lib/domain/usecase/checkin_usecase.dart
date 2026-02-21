import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';

class CheckinUsecase {
  final CheckinRepository repository;

  CheckinUsecase(this.repository);

  Future<CheckInStatusRequest> checkIn(int empId, double lat, double long) =>
      repository.checkIn(empId, lat, long);

  Future<CheckInStatusRequest> checkOut(int empId, double lat, double long) =>
      repository.checkOut(empId, lat, long);

  Future<CheckInStatusRequest?> fetchTodayStatus(int empId) =>
      repository.fetchTodayStatus(empId);

  Future<List<CheckInStatusRequest>> getAttendance(int empId) =>
      repository.getAttendance(empId);
}


