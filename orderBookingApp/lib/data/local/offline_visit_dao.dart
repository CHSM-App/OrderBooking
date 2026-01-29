import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/visite.dart';
import 'app_database.dart';

class OfflineVisitDao {
  Future<void> insert(VisitPayload visit) async {
    debugPrint('Inserting offline visit: ${visit.toJson()}');
    debugPrintOfflineVisits();
    final db = await AppDatabase.database;

    await db.insert('offline_visits', {
      'local_id': visit.localId,
      'payload': jsonEncode(visit.toLocalJson()),
      'status': 'pending',
      'captured_at': visit.capturedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> fetchPending({int limit = 20}) async {
    debugPrint('Fetching pending offline visits');
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
    debugPrint('marking as syncking offline');
    final db = await AppDatabase.database;
    await db.update(
      'offline_visits',
      {'status': 'syncing'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetry(int id) async {
    debugPrint('incrementing retry count');
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
    debugPrint('Deleting offline visit with id $id');
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
