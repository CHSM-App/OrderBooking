


import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';



class CheckinStatusRequestImpl implements CheckinRepository {
  final ApiService apiService;

  CheckinStatusRequestImpl(this.apiService);

  @override
  Future<CheckInStatusRequest> checkIn(
    int empId,
    double latitude,
    double longitude,
  ) {
    return apiService.checkIn(empId, latitude, longitude);
  }

  @override
  Future<CheckInStatusRequest> checkOut(int empId,     double latitude,
    double longitude,) {
    return apiService.checkOut(empId , latitude, longitude);
  }

  @override
  Future<CheckInStatusRequest?> fetchTodayStatus(int empId) async {
    final list = await apiService.fetchTodayAttendance(empId);
    return list.isNotEmpty ? list.first : null;
  }
  @override
  Future<List<CheckInStatusRequest>> getAttendance(int empId) async {
    return await apiService.getAttendance(empId);
  }

  
}



