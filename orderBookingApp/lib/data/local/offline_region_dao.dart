import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/region.dart';

class OfflineRegionDao {

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final db = await AppDatabase.database;

    return db.query(
      'offline_regions',
      where: 'is_deleted = 0',
      orderBy: 'captured_at ASC',
    );
  }

  /// 🔥 Upsert server data into local cache
 Future<void> upsertFromServer(List<Region> regions) async {
  final db = await AppDatabase.database;

  await db.transaction((txn) async {
    final batch = txn.batch();

    final now = DateTime.now().toIso8601String();

    for (final region in regions) {
      batch.insert(
        'offline_regions',
        {
          'server_id': region.regionId,
          'region_name': region.regionName,
          'pincode': region.pincode,
          'district': region.district,
          'state': region.state,
          'company_id': region.companyId,
          'created_by': region.createdBy,
          'status': 'synced',
          'is_deleted': 0,
          'captured_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  });
}


Future<void> 
deleteRegionsNotIn(List<int> serverIds) async {
  final db = await AppDatabase.database;

  if (serverIds.isEmpty) {
    await db.delete('offline_regions');
    return;
  }

  final placeholders = List.filled(serverIds.length, '?').join(',');

  await db.delete(
    'offline_regions',
    where: 'server_id NOT IN ($placeholders)',
    whereArgs: serverIds,
  );
}

}
