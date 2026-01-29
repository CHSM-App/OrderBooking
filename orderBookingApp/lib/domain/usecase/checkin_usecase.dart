import 'dart:io';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';


class CheckinUsecase {
  final CheckinRepository repository;

  CheckinUsecase(this.repository);

  Future<void> checkIn(int empId) {
    return repository.checkIn(empId);
  }

  Future<void> checkOut(int empId) {
    return repository.checkOut(empId);
  }

  Future<CheckInStatusRequest?> fetchTodayStatus(int empId) {
    return repository.fetchTodayStatus(empId);
  }
}
