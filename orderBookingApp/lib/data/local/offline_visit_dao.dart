import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
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
}
