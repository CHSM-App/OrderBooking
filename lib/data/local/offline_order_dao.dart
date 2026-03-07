import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:order_booking_app/domain/models/order_item.dart';
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
      'emp_name': order.empName,
      'address': order.address,
      'owner_name': order.ownerName,
      'mobile_no': order.mobileNo,
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
      'owner_name': order.ownerName,
      'mobile_no': order.mobileNo,
      'local_order_id': order.localOrderId,
      'server_order_id': serverOrderId,
      'employee_id': order.employeeId,
      'shop_id': order.shopId,
      'shop_name': order.shopNamep,
      'emp_name': order.empName,
      'address': order.address,
      'order_date': order.orderDate,
      'total_price': order.totalPrice,
      'company_id': order.companyId,
      'status': 'synced',
      'is_delivered': order.isDelivered??0,
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

  Future<List<Order>> fetchCachedCompanyOrders(String companyId) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'offline_orders',
      where: 'company_id = ? AND status = ?',
      whereArgs: [companyId, 'synced'],
      orderBy: 'order_date DESC',
    );
    return _mapOrdersWithItems(rows);
  }

  Future<void> replaceCachedCompanyOrders(
    String companyId,
    List<Order> orders,
  ) async {
    final db = await AppDatabase.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'offline_orders',
        columns: ['local_order_id'],
        where: 'company_id = ? AND status = ? AND local_order_id LIKE ?',
        whereArgs: [companyId, 'synced', 'server-%'],
      );

      for (final row in existing) {
        final localId = row['local_order_id'] as String?;
        if (localId == null) continue;
        await txn.delete(
          'offline_order_items',
          where: 'local_order_id = ?',
          whereArgs: [localId],
        );
      }

      await txn.delete(
        'offline_orders',
        where: 'company_id = ? AND status = ? AND local_order_id LIKE ?',
        whereArgs: [companyId, 'synced', 'server-%'],
      );

      final batch = txn.batch();
      for (final o in orders) {
        final serverOrderId = o.serverOrderId;
        if (serverOrderId == null) continue;
        final localId = 'server-$serverOrderId';
        batch.insert('offline_orders', {
          'local_order_id': localId,
          'server_order_id': serverOrderId,
          'employee_id': o.employeeId,
          'shop_id': o.shopId,
          'owner_name': o.ownerName,
          'mobile_no': o.mobileNo,
          'shop_name': o.shopNamep,
          'emp_name': o.empName,
          'address': o.address,
          'order_date': o.orderDate,
          'total_price': o.totalPrice,
          'company_id': o.companyId ?? companyId,
          'status': 'synced',
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        for (final item in o.items) {
          batch.insert('offline_order_items', {
            'local_order_id': localId,
            'product_id': item.productId,
            'product_name': item.productName,
            'sub_item_id': item.subItemId,
            'product_unit': item.productUnit,
            'price': item.price,
            'quantity': item.quantity,
            'total_price': item.totalPrice,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      await batch.commit(noResult: true);
    });
  }

  Future<List<Order>> _mapOrdersWithItems(
    List<Map<String, dynamic>> rows,
  ) async {
    final result = <Order>[];
    for (final row in rows) {
      final localOrderId = row['local_order_id'] as String;
      final itemRows = await fetchItems(localOrderId);
      final items = itemRows.map(_mapRowToOrderItem).toList();
      result.add(
        Order(
          localOrderId: localOrderId,
          serverOrderId: row['server_order_id'] as int?,
          employeeId: row['employee_id'] as int,
          shopId: row['shop_id'] as int,
          shopNamep: row['shop_name'] as String?,
          empName: row['emp_name'] as String?,
          address: row['address'] as String?,
          ownerName: row['owner_name'] as String?,
          mobileNo: row['mobile_no'] as String?,
          orderDate: row['order_date'] as String,
          items: items,
          totalPrice: (row['total_price'] as num).toDouble(),
          companyId: row['company_id'] as String?,
        ),
      );
    }
    return result;
  }

  OrderItem _mapRowToOrderItem(Map<String, dynamic> row) {
    return OrderItem(
      productId: row['product_id'] as int,
      productName: row['product_name'] as String?,
      subItemId: row['sub_item_id'] as int,
      productUnit: row['product_unit'] as String,
      price: (row['price'] as num).toDouble(),
      quantity: row['quantity'] as int,
      totalPrice: (row['total_price'] as num).toDouble(),
    );
  }

  Future<void> markDeliveredByLocalIds(List<String> localOrderIds) async {
    if (localOrderIds.isEmpty) return;
    final db = await AppDatabase.database;
    final placeholders = List.filled(localOrderIds.length, '?').join(',');
    await db.rawUpdate('''
      UPDATE offline_orders
      SET is_delivered = 1
      WHERE local_order_id IN ($placeholders)
    ''', localOrderIds);
  }

  Future<void> insertDeliveredOrders(
    List<int> serverOrderIds, {
    String status = 'pending',
    DateTime? deliveredOn,
  }) async {
    if (serverOrderIds.isEmpty) return;
    final db = await AppDatabase.database;
    final day = deliveredOn ?? DateTime.now();
    final dateOnly = DateTime(day.year, day.month, day.day).toIso8601String();

    final batch = db.batch();
    for (final serverId in serverOrderIds) {
      batch.insert('delivered_orders', {
        'server_order_id': serverId ,
        'status': status,
        'delivered_on': dateOnly,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<List<int>> fetchPendingDeliveredServerIds() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'delivered_orders',
      columns: ['server_order_id'],
      where: 'status = ?',
      whereArgs: ['pending'],
    );
    return rows
        .map((r) => r['server_order_id'])
        .whereType<int>()
        .toList();
  }

  Future<void> markDeliveredSynced(List<int> serverOrderIds) async {
    if (serverOrderIds.isEmpty) return;
    final db = await AppDatabase.database;
    final placeholders = List.filled(serverOrderIds.length, '?').join(',');
    await db.rawUpdate(
      '''
      UPDATE delivered_orders
      SET status = ?
      WHERE server_order_id IN ($placeholders)
    ''',
      ['synced', ...serverOrderIds],
    );
  }
}
