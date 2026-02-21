import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/checkin_dao.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';

class CheckinStatusRequestImpl implements CheckinRepository {
  final ApiService apiService;
  final OfflineAttendanceDao offline;

  CheckinStatusRequestImpl(this.apiService, this.offline);

  @override
  Future<CheckInStatusRequest> checkIn(
    int empId,
    double latitude,
    double longitude,
  ) async {
    CheckInStatusRequest? remoteStatus;
    try {
      remoteStatus = await apiService.checkIn(empId, latitude, longitude);
      await offline.upsertStatus(empId: empId, status: remoteStatus);
    } catch (_) {
      // Ignore remote errors; we still return the local cache.
    }

    final cached = await offline.fetchLatest(empId);
    if (cached != null) return cached;
    if (remoteStatus != null) return remoteStatus;
    throw Exception('No local check-in status available.');
  }

  @override
  Future<CheckInStatusRequest> checkOut(
    int empId,
    double latitude,
    double longitude,
  ) async {
    CheckInStatusRequest? remoteStatus;
    try {
      remoteStatus = await apiService.checkOut(empId, latitude, longitude);
      await offline.upsertStatus(empId: empId, status: remoteStatus);
    } catch (_) {
      // Ignore remote errors; we still return the local cache.
    }

    final cached = await offline.fetchLatest(empId);
    if (cached != null) return cached;
    if (remoteStatus != null) return remoteStatus;
    throw Exception('No local check-out status available.');
  }

  @override
  Future<CheckInStatusRequest?> fetchTodayStatus(int empId) async {
    try {
      final list = await apiService.fetchTodayAttendance(empId);
      final status = list.isNotEmpty ? list.first : null;
      if (status != null) {
        await offline.upsertStatus(empId: empId, status: status);
      }
      return status;
    } catch (_) {
      return offline.fetchLatest(empId);
    }
  }

  @override
  Future<List<CheckInStatusRequest>> getAttendance(int empId) async {
    return await apiService.getAttendance(empId);
  }
}
