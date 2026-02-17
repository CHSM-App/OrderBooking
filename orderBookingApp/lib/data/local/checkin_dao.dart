import 'dart:convert';

import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:sqflite/sqflite.dart';

class OfflineAttendanceDao {

  
  Future<void> upsertStatus({
    required int empId,
    required CheckInStatusRequest status,
  }) async {
    final db = await AppDatabase.database;
    final capturedAt = DateTime.now().toIso8601String();
    final dayKey = status.inDate ?? status.outDate ?? capturedAt.substring(0, 10);
    final localId = '$empId-$dayKey';

    await db.insert(
      'offline_checkin_status',
      {
        'local_id': localId,
        'emp_id': empId,
        'in_date': status.inDate,
        'in_time': status.inTime,
        'out_date': status.outDate,
        'out_time': status.outTime,
        'checkin_status': status.success,
        'latitude': status.latitude,
        'longitude': status.longitude,
        'payload': jsonEncode(status.toJson()),
        'captured_at': capturedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CheckInStatusRequest?> fetchLatest(int empId) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'offline_checkin_status',
      where: 'emp_id = ?',
      whereArgs: [empId],
      orderBy: 'captured_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    final payload = rows.first['payload'] as String?;
    if (payload == null) return null;

    return CheckInStatusRequest.fromJson(
      jsonDecode(payload) as Map<String, dynamic>,
    );
  }
}
