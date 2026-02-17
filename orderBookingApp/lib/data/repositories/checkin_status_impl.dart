import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/checkin_dao.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';
import 'package:order_booking_app/presentation/providers/connectivity_provider.dart';

class CheckinRepositoryImpl implements CheckinRepository {
  final ApiService apiService;
  final Ref ref;
  final OfflineAttendanceDao offlineDao = OfflineAttendanceDao();

CheckinRepositoryImpl(this.apiService, this.ref);



Future<bool> _isOnline() async {
  final connectivityList = await ref.read(connectivityProvider.future);
  final latest = connectivityList.isNotEmpty ? connectivityList.last : ConnectivityResult.none;
  return latest != ConnectivityResult.none;
}


  /// CHECK IN
  @override
  Future<CheckInStatusRequest> checkIn(
      int empId, double latitude, double longitude) async {
      // Save locally
      await offlineDao.insertAttendance(
          empId: empId, type: 1, latitude: latitude, longitude: longitude);
      return CheckInStatusRequest(
          success: 1, message: "CheckIn saved offline");
    
  }

  /// CHECK OUT
  @override
  Future<CheckInStatusRequest> checkOut(
      int empId, double latitude, double longitude) async {
  
      await offlineDao.insertAttendance(
          empId: empId, type: 0, latitude: latitude, longitude: longitude);
      return CheckInStatusRequest(
          success: 1, message: "CheckOut saved offline");
    }
  

  /// FETCH TODAY STATUS
  @override
  Future<CheckInStatusRequest?> fetchTodayStatus(int empId) async {
 
      // Fetch from offline database
      final lastType = await offlineDao.getLastStatus(empId);
      return CheckInStatusRequest(
        success: 1,
        message: lastType == 1
            ? "Last check-in offline"
            : lastType == 0
                ? "Last check-out offline"
                : "No offline record",
        checkinStatus: lastType,
      );
    }
  

  /// FETCH ATTENDANCE LIST
  @override
  Future<List<CheckInStatusRequest>> getAttendance(int empId) async {
  
      // Fetch all offline attendance
      final rows = await offlineDao.fetchAll();
      return rows.map((e) {
        return CheckInStatusRequest(
          success: 1,
          message: e['type'] == 1 ? "Check-in offline" : "Check-out offline",
          checkinStatus: e['type'] as int?,
        );
      }).toList();
    
  }
}

