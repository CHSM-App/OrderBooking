import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../DB/app_database.dart';

class OfflineAttendanceDao {

  /// INSERT CHECKIN / CHECKOUT
  Future<void> insertAttendance({
    required int empId,
    required int type, // 1 = checkin, 0 = checkout
    required double latitude,
    required double longitude,
  }) async {

    final db = await AppDatabase.database;

    await db.insert(
      'offline_attendance',
      {
        'emp_id': empId,
        'type': type,
        'checkin_datetime':
            type == 1 ? DateTime.now().toIso8601String() : null,
        'checkout_datetime':
            type == 0 ? DateTime.now().toIso8601String() : null,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrintAttendance();
  }

  /// FETCH ALL
  Future<List<Map<String, dynamic>>> fetchAll() async {

    final db = await AppDatabase.database;

    return await db.query(
      'offline_attendance',
      orderBy: 'id DESC',
    );
  }

  /// FETCH LAST STATUS
  Future<int?> getLastStatus(int empId) async {

    final db = await AppDatabase.database;

    final result = await db.query(
      'offline_attendance',
      where: 'emp_id = ?',
      whereArgs: [empId],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first['type'] as int;
  }

  /// DEBUG PRINT
  Future<void> debugPrintAttendance() async {

    final db = await AppDatabase.database;

    final rows = await db.query('offline_attendance');

    debugPrint('---- OFFLINE ATTENDANCE TABLE ----');

    for (final row in rows) {
      debugPrint(row.toString());
    }
  }

}
