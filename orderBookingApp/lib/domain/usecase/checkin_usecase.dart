import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';


class CheckinUsecase {
  final CheckinRepository repository;

  CheckinUsecase(this.repository);

  Future<CheckInStatusRequest> checkIn(
    int empId,
    double latitude,
    double longitude,
  ) {
    return repository.checkIn(empId, latitude, longitude);
  }

  Future<CheckInStatusRequest> checkOut(int empId,     double latitude,
    double longitude,) {
    return repository.checkOut(empId, latitude, longitude);
  }

  Future<CheckInStatusRequest?> fetchTodayStatus(int empId) {
    return repository.fetchTodayStatus(empId);
  }

  Future<List<CheckInStatusRequest>> getAttendance(int empId){
    return repository.getAttendance(empId);
  }
}


