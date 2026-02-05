import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/region.dart';

class OfflineRegionDao {
  Future<void> insertPending(Region region) async {
    final db = await AppDatabase.database;

    await db.insert('offline_regions', {
      'local_id': region.localId,
      'payload': jsonEncode(region.toLocalJson()),
      'status': 'pending',
      'captured_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> fetchPending() async {
    final db = await AppDatabase.database;

    return db.query(
      'offline_regions',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'captured_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final db = await AppDatabase.database;

    return db.query(
      'offline_regions',
      where: 'is_deleted = 0',
      orderBy: 'captured_at ASC',
    );
  }

  Future<void> markSyncing(int id) async {
    final db = await AppDatabase.database;

    await db.update(
      'offline_regions',
      {'status': 'syncing'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(int id, int serverId) async {
    final db = await AppDatabase.database;

    await db.update(
      'offline_regions',
      {
        'status': 'synced',
        'server_id': serverId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetry(int id) async {
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

  /// 🔥 Upsert server data into local cache
  Future<void> upsertFromServer(Region region) async {
    final db = await AppDatabase.database;

    /// 1️⃣ Check if region already exists locally using server_id
    final existing = await db.query(
      'offline_regions',
      where: 'server_id = ?',
      whereArgs: [region.regionId],
      limit: 1,
    );

    final now = DateTime.now().toIso8601String();

    /// 2️⃣ If record exists → Decide update logic
    if (existing.isNotEmpty) {
      final row = existing.first;

      final status = row['status'];

      /// 🔥 IMPORTANT:
      /// If region is pending locally, do NOT overwrite
      if (status == 'pending' || status == 'syncing') {
        return;
      }

      /// Update synced record
      await db.update(
        'offline_regions',
        {
          'payload': jsonEncode(region.toLocalJson()),
          'status': 'synced',
          'updated_at': now,
          'is_deleted': 0,
        },
        where: 'server_id = ?',
        whereArgs: [region.regionId],
      );
    }
    /// 3️⃣ If record does NOT exist → Insert new
    else {
      await db.insert('offline_regions', {
        'server_id': region.regionId,
        'payload': jsonEncode(region.toLocalJson()),
        'status': 'synced',
        'captured_at': now,
        'updated_at': now,
        'is_deleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
