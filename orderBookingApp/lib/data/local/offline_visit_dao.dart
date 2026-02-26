import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/employee_visit.dart';
import '../../domain/models/visite.dart';
import '../DB/app_database.dart';

class OfflineVisitDao {
  Future<void> insert(VisitPayload visit) async {
    debugPrintOfflineVisits();
    final db = await AppDatabase.database;

    await db.insert('offline_visits', {
      'local_id': visit.localId,
      'payload': jsonEncode(visit.toLocalJson()),
      'status': 'pending',
      'captured_at': visit.capturedAt!.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> fetchPending({int limit = 20}) async {
    final db = await AppDatabase.database;

    return db.query(
      'offline_visits',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'captured_at ASC',
      limit: limit,
    );
  }

  Future<void> markSyncing(int id) async {
    final db = await AppDatabase.database;
    await db.update(
      'offline_visits',
      {'status': 'syncing'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(int id) async {
    final db = await AppDatabase.database;
    await db.update(
      'offline_visits',
      {'status': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncedWithServerId(int id, int serverLocationId) async {
    final db = await AppDatabase.database;
    await db.update(
      'offline_visits',
      {
        'status': 'synced',
        'server_location_id': serverLocationId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> purgeSyncedBeforeToday() async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    await db.delete(
      'offline_visits',
      where: 'status = ? AND captured_at < ?',
      whereArgs: ['synced', start.toIso8601String()],
    );
  }

  Future<int> countTodayVisits() async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final res = await db.rawQuery(
      '''
      SELECT COUNT(*) AS c
      FROM offline_visits
      WHERE captured_at >= ? AND captured_at < ?
      ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> incrementRetry(int id) async {
    final db = await AppDatabase.database;
    await db.rawUpdate(
      '''
      UPDATE offline_visits
      SET retry_count = retry_count + 1,
          status = 'pending'
      WHERE id = ?
      ''',
      [id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.database;
    await db.delete('offline_visits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> debugPrintOfflineVisits() async {
    final db = await AppDatabase.database;
    final rows = await db.query('offline_visits');
    debugPrint('current offline visit table');
    for (final row in rows) {
      debugPrint(row.toString());
    }
  }

  Future<void> upsertSyncedFromServer(List<EmployeeVisit> visits) async {
    if (visits.isEmpty) return;
    final db = await AppDatabase.database;
    final batch = db.batch();
    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final existingServerMap = await _fetchServerLocationIdMap();
    final existingLocalIds = await _fetchLocalIds();

    for (final v in visits) {
      final capturedAt = v.punchIn ?? v.punchOut ?? DateTime.now();
      final capturedAtUtc = capturedAt.toUtc();
      if (capturedAtUtc.isBefore(todayStart) ||
          !capturedAtUtc.isBefore(todayEnd)) {
        continue;
      }
      final localId = 'srv-${v.locationId}';
      final payload = VisitPayload(
        localId: localId,
        shopId: v.shopId,
        lat: v.latitude,
        lng: v.longitude,
        punchIn: (v.punchIn ?? capturedAt).toIso8601String(),
        punchOut: v.punchOut?.toIso8601String(),
        employeeId: v.empId,
        regionName: null,
        shopName: v.shopName,
        ownerName: v.ownerName,
        address: v.address,
        mobileNo: v.mobileNo,
        email: null,
        accuracy: v.accuracy,
        capturedAt: capturedAt,
      );

      if (existingServerMap.containsKey(v.locationId)) {
        batch.update(
          'offline_visits',
          {
            'payload': jsonEncode(payload.toLocalJson()),
            'status': 'synced',
            'retry_count': 0,
            'captured_at': capturedAt.toIso8601String(),
          },
          where: 'server_location_id = ?',
          whereArgs: [v.locationId],
        );
        continue;
      }

      if (existingLocalIds.contains(localId)) {
        batch.update(
          'offline_visits',
          {
            'payload': jsonEncode(payload.toLocalJson()),
            'status': 'synced',
            'retry_count': 0,
            'captured_at': capturedAt.toIso8601String(),
            'server_location_id': v.locationId,
          },
          where: 'local_id = ?',
          whereArgs: [localId],
        );
        continue;
      }

      batch.insert(
        'offline_visits',
        {
          'local_id': payload.localId,
          'server_location_id': v.locationId,
          'payload': jsonEncode(payload.toLocalJson()),
          'status': 'synced',
          'retry_count': 0,
          'captured_at': capturedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<Map<int, String>> _fetchServerLocationIdMap() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'offline_visits',
      columns: ['server_location_id', 'captured_at'],
      where: 'server_location_id IS NOT NULL',
    );

    final map = <int, String>{};
    for (final r in rows) {
      final id = r['server_location_id'];
      final at = r['captured_at'];
      if (id is int && at is String) {
        map[id] = at;
      }
    }
    return map;
  }

  Future<Set<String>> _fetchLocalIds() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'offline_visits',
      columns: ['local_id'],
      where: 'local_id IS NOT NULL',
    );
    return rows
        .map((r) => r['local_id'])
        .whereType<String>()
        .toSet();
  }
}
