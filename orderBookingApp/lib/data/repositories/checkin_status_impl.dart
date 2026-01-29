
import 'dart:io';


import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';



class CheckinStatusRequestImpl implements CheckinRepository {
  final ApiService apiService;

  CheckinStatusRequestImpl(this.apiService);

  @override
  Future<void> checkIn(int empId) {
    return apiService.checkIn(empId);
  }

  @override
  Future<void> checkOut(int empId) {
    return apiService.checkOut(empId);
  }

  @override
  Future<CheckInStatusRequest?> fetchTodayStatus(int empId) async {
    final list = await apiService.fetchTodayAttendance(empId);
    return list.isNotEmpty ? list.first : null;
  }
}



