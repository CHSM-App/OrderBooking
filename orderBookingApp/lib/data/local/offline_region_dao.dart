import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/region.dart';
import 'app_database.dart';

class OfflineRegionDao {
  /// Insert a region into the offline_regions table
  Future<void> insert(Region region) async {
    debugPrint('Inserting offline region: ${region.toJson()}');
    debugPrintOfflineRegions();
    final db = await AppDatabase.database;

    await db.insert('offline_regions', {
      'local_id': region.localId,
      'payload': jsonEncode(region.toLocalJson()),
      'status': 'pending',
      'captured_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Fetch pending regions for sync
  Future<List<Map<String, dynamic>>> fetchPending({int limit = 20}) async {
    debugPrint('Fetching pending offline regions');
    final db = await AppDatabase.database;

    return db.query(
      'offline_regions',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'captured_at ASC',
      limit: limit,
    );
  }

  /// Mark a region as syncing
  Future<void> markSyncing(int id) async {
    debugPrint('Marking offline region as syncing');
    final db = await AppDatabase.database;
    await db.update(
      'offline_regions',
      {'status': 'syncing'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increment retry count if sync fails
  Future<void> incrementRetry(int id) async {
    debugPrint('Incrementing retry count for offline region');
    final db = await AppDatabase.database;
    await db.rawUpdate(
      '''
      UPDATE offline_regions
      SET retry_count = retry_count + 1,
          status = 'pending'
      WHERE id = ?
      ''',
      [id],
    );
  }

  /// Delete a region from offline table
  Future<void> delete(int id) async {
    debugPrint('Deleting offline region with id $id');
    final db = await AppDatabase.database;
    await db.delete('offline_regions', where: 'id = ?', whereArgs: [id]);
  }

  /// Debug helper to print all offline regions
  Future<void> debugPrintOfflineRegions() async {
    final db = await AppDatabase.database;
    final rows = await db.query('offline_regions');
    debugPrint('Current offline_regions table:');
    for (final row in rows) {
      debugPrint(row.toString());
    }
  }

  
}
