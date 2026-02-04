import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:sqflite/sqflite.dart';

class OfflineOrderDao {
  Future<void> insertOrder(Order order) async {
    final db = await AppDatabase.database;
    final batch = db.batch();

    batch.insert('offline_orders', {
      'local_order_id': order.localOrderId,
      'employee_id': order.employeeId,
      'shop_id': order.shopId,
      'shop_name': order.shopNamep,
      'order_date': order.orderDate,
      'total_price': order.totalPrice,
      'status': 'pending',
      'company_id': order.companyId,
      'created_at': DateTime.now().toIso8601String(),
    });

    for (final item in order.items) {
      batch.insert('offline_order_items', {
        'local_order_id': order.localOrderId,
        'product_id': item.productId,
        'product_name': item.productName,
        'sub_item_id': item.subItemId,
        'product_unit': item.productUnit,
        'price': item.price,
        'quantity': item.quantity,
        'total_price': item.totalPrice,
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> fetchPendingOrders() async {
    final db = await AppDatabase.database;
    return db.query(
      'offline_orders',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> fetchItems(String localOrderId) async {
    final db = await AppDatabase.database;
    return db.query(
      'offline_order_items',
      where: 'local_order_id = ?',
      whereArgs: [localOrderId],
    );
  }

  Future<void> markSynced(String localOrderId, int serverOrderId) async {
    final db = await AppDatabase.database;
    await db.update(
      'offline_orders',
      {'server_order_id': serverOrderId, 'status': 'synced'},
      where: 'local_order_id = ?',
      whereArgs: [localOrderId],
    );
  }

  Future<void> incrementRetry(String localOrderId) async {
    final db = await AppDatabase.database;
    await db.rawUpdate(
      '''
      UPDATE offline_orders
      SET retry_count = retry_count + 1
      WHERE local_order_id = ?
    ''',
      [localOrderId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final db = await AppDatabase.database;

    return db.query('offline_orders', orderBy: 'created_at DESC');
  }

  Future<bool> existsByServerOrderId(int serverOrderId) async {
    final db = await AppDatabase.database;

    final res = await db.query(
      'offline_orders',
      where: 'server_order_id = ?',
      whereArgs: [serverOrderId],
    );

    return res.isNotEmpty;
  }

  Future<void> insertRemoteOrder({
    required Order order,
    required int serverOrderId,
  }) async {
    final db = await AppDatabase.database;
    final batch = db.batch();

    batch.insert('offline_orders', {
      'local_order_id': order.localOrderId,
      'server_order_id': serverOrderId,
      'employee_id': order.employeeId,
      'shop_id': order.shopId,
      'shop_name': order.shopNamep,
      'order_date': order.orderDate,
      'total_price': order.totalPrice,
      'status': 'synced',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    for (final item in order.items) {
      batch.insert('offline_order_items', {
        'local_order_id': order.localOrderId,
        'product_id': item.productId,
        'product_name': item.productName,
        'sub_item_id': item.subItemId,
        'product_unit': item.productUnit,
        'price': item.price,
        'quantity': item.quantity,
        'total_price': item.totalPrice,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }


  
}
