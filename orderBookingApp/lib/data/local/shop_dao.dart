import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/shop_details.dart';


class ShopDao {
  Future<void> insert(ShopDetails shop) async {
    final db = await AppDatabase.database;

    await db.insert(
      'shops',
      {
        'local_id': shop.localId,
        'server_id': shop.shopId,
        'shop_name': shop.shopName,
        'owner_name': shop.ownerName,
        'address': shop.address,
        'mobile_no': shop.mobileNo,
        'email': shop.email,
        'region_id': shop.regionId,
        'created_by': shop.createdBy,
        'latitude': shop.latitude,
        'longitude': shop.longitude,
        'is_synced': shop.isSynced ? 1 : 0,
        'updated_at': shop.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<ShopDetails>> getAll() async {
    final db = await AppDatabase.database;
    final rows = await db.query('shops', orderBy: 'shop_name');

    return rows.map(_mapToShop).toList();
  }

  Future<List<ShopDetails>> getUnsynced() async {
    final db = await AppDatabase.database;
    final rows =
        await db.query('shops', where: 'is_synced = 0');

    return rows.map(_mapToShop).toList();
  }

  Future<void> markSynced({
    required String localId,
    required int serverId,
  }) async {
    final db = await AppDatabase.database;
    await db.update(
      'shops',
      {
        'server_id': serverId,
        'is_synced': 1,
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<bool> existsByServerId(int serverId) async {
    final db = await AppDatabase.database;
    final res = await db.query(
      'shops',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
    return res.isNotEmpty;
  }

  ShopDetails _mapToShop(Map<String, dynamic> row) {
    return ShopDetails(
      localId: row['local_id'],
      shopId: row['server_id'],
      shopName: row['shop_name'],
      ownerName: row['owner_name'],
      address: row['address'],
      mobileNo: row['mobile_no'],
      email: row['email'],
      regionId: row['region_id'],
      createdBy: row['created_by'],
      latitude: row['latitude'],
      longitude: row['longitude'],
      isSynced: row['is_synced'] == 1,
      updatedAt: DateTime.parse(row['updated_at']),
    );
  }
}
