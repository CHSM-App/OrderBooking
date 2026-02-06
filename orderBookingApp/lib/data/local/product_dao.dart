import 'package:flutter/foundation.dart';
import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ProductDao {

  Future<void> insertProducts(
    List<Product> products, {
    bool markSynced = true,
  }) async {
    final db = await AppDatabase.database;
    final batch = db.batch();

    for (final product in products) {
      // 1️⃣ Check if product exists locally by productId (if synced) or productName (if offline)
      final existing = await db.query(
        'products',
        where: '(product_id = ? OR product_name = ?)',
        whereArgs: [product.productId, product.productName],
        limit: 1,
      );

      String localId;

      if (existing.isNotEmpty) {
        // Product exists → reuse localId
        localId = existing.first['local_id'] as String;

        // Update product info (optional)
        batch.update(
          'products',
          {
            'product_type': product.productType,
            'total_price': product.totalPrice,
            'updated_at': product.updatedAt?.toIso8601String(),
            'is_synced': markSynced ? 1 : 0,
          },
          where: 'local_id = ?',
          whereArgs: [localId],
        );
      } else {
        // New product → insert
        localId = product.localId ?? const Uuid().v4();
        batch.insert('products', {
          'local_id': localId,
          'product_id': product.productId,
          'product_name': product.productName,
          'product_type': product.productType,
          'created_by': product.createdBy,
          'admin_id': product.adminId,
          'company_id': product.companyId,
          'product_unit': product.productUnit,
          'total_price': product.totalPrice,
          'shop_id': product.shopId,
          'is_synced': markSynced ? 1 : 0,
          'updated_at': product.updatedAt?.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 2️⃣ Insert subtypes only if they don’t exist
      if (product.subtypes != null) {
        for (final sub in product.subtypes!) {
          final existingSub = await db.query(
            'product_subtypes',
            where: 'product_local_id = ? AND measuring_unit = ? AND price = ?',
            whereArgs: [localId, sub.measuringUnit, sub.price],
            limit: 1,
          );

          if (existingSub.isEmpty) {
            batch.insert('product_subtypes', {
              'local_id': sub.localId ?? const Uuid().v4(),
              'product_local_id': localId,
              'server_product_id': product.productId,
              'sub_item_id': sub.subItemId,
              'measuring_unit': sub.measuringUnit,
              'available_unit': sub.availableUnit,
              'price': sub.price,
              'total': sub.total,
              'is_synced': markSynced ? 1 : 0,
              'updated_at': product.updatedAt?.toIso8601String(),
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
    }

    await batch.commit(noResult: true);
  }

  /// Fetch all products with subtypes
  Future<List<Product>> getAllProducts() async {
    final db = await AppDatabase.database;
    final rows = await db.query('products', orderBy: 'product_name ASC');
    final result = <Product>[];

    for (final row in rows) {
      final localId = row['local_id'] as String?;
      final serverProductId = row['product_id'] as int?;
      final subtypes = await getProductSubTypes(
        localId,
        serverProductId: serverProductId,
      );

      result.add(
        Product(
          productId: serverProductId,
          productName: row['product_name'] as String?,
          productType: row['product_type'] as String?,
          createdBy: row['created_by'] as int?,
          adminId: row['admin_id'] as int?,
          companyId: row['company_id'] as String?,
          productUnit: row['product_unit'] as String?,
          totalPrice: row['total_price'] != null
              ? (row['total_price'] as num).toDouble()
              : null,
          shopId: row['shop_id'] as int?,
          subtypes: subtypes,
          localId: localId,
          isSynced: (row['is_synced'] ?? 0) == 1,
          updatedAt: row['updated_at'] != null
              ? DateTime.parse(row['updated_at'] as String)
              : null,
        ),
      );
    }

    return result;
  }

  /// Get product subtypes
  Future<List<ProductSubType>> getProductSubTypes(
    String? productLocalId, {
    int? serverProductId,
  }) async {
    if (productLocalId == null) return [];

    final db = await AppDatabase.database;
    final whereClause = serverProductId != null
        ? '(product_local_id = ? OR server_product_id = ?)'
        : 'product_local_id = ?';
    final whereArgs = serverProductId != null
        ? [productLocalId, serverProductId]
        : [productLocalId];

final rows = await db.query(
  'product_subtypes',
  where: '$whereClause AND is_deleted = 0',
  whereArgs: whereArgs,
);


    return rows.map((row) {
      return ProductSubType(
        subItemId: row['sub_item_id'] as int?,
        measuringUnit: row['measuring_unit'] as String?,
        availableUnit: row['available_unit'] != null
            ? (row['available_unit'] as num).toDouble()
            : null,
        price: row['price'] != null ? (row['price'] as num).toDouble() : null,
        total: row['total'] as int?,
        localId: row['local_id'] as String?,
        productLocalId: row['product_local_id'] as String?,
        isSynced: (row['is_synced'] ?? 0) == 1,
      );
    }).toList();
  }

  /// Fetch unsynced products
  Future<List<Product>> getUnsyncedProducts() async {
    final db = await AppDatabase.database;
    final rows = await db.query('products', where: 'is_synced = 0');
    final result = <Product>[];

    for (final row in rows) {
      final localId = row['local_id'] as String?;
      final serverProductId = row['product_id'] as int?;
      final subtypes = await getProductSubTypes(
        localId,
        serverProductId: serverProductId,
      );

      result.add(
        Product(
          productId: serverProductId,
          productName: row['product_name'] as String?,
          productType: row['product_type'] as String?,
          createdBy: row['created_by'] as int?,
          adminId: row['admin_id'] as int?,
          companyId: row['company_id'] as String?,
          productUnit: row['product_unit'] as String?,
          totalPrice: row['total_price'] != null
              ? (row['total_price'] as num).toDouble()
              : null,
          shopId: row['shop_id'] as int?,
          subtypes: subtypes,
          localId: localId,
          isSynced: false,
          updatedAt: row['updated_at'] != null
              ? DateTime.parse(row['updated_at'] as String)
              : null,
        ),
      );
    }

    return result;
  }

  /// Update product ID after server assigns it
  Future<void> updateProductId(String localId, int serverProductId) async {
    final db = await AppDatabase.database;

    await db.update(
      'products',
      {'product_id': serverProductId, 'is_synced': 1},
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    await db.update(
      'product_subtypes',
      {'server_product_id': serverProductId, 'is_synced': 1},
      where: 'product_local_id = ?',
      whereArgs: [localId],
    );
  }

  /// Delete a subtype
  Future<void> deleteProductSubType(String localId) async {
    final db = await AppDatabase.database;
    await db.delete(
      'product_subtypes',
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  /// Get product by ID
  Future<Product?> getProductById(int productId) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'products',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final localId = row['local_id'] as String?;
    final subtypes = await getProductSubTypes(
      localId,
      serverProductId: productId,
    );

    return Product(
      productId: row['product_id'] as int?,
      productName: row['product_name'] as String?,
      productType: row['product_type'] as String?,
      createdBy: row['created_by'] as int?,
      adminId: row['admin_id'] as int?,
      companyId: row['company_id'] as String?,
      productUnit: row['product_unit'] as String?,
      totalPrice: row['total_price'] != null
          ? (row['total_price'] as num).toDouble()
          : null,
      shopId: row['shop_id'] as int?,
      subtypes: subtypes,
      localId: localId,
      isSynced: (row['is_synced'] ?? 0) == 1,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }


/// Mark sub-product as deleted locally (soft delete)
Future<void> markSubProductDeleted(String localSubId) async {
  final db = await AppDatabase.database;

  await db.update(
    'product_subtypes',
    {
      'is_deleted': 1,
      'is_synced': 0,
      'updated_at': DateTime.now().toIso8601String(),
    },
    where: 'local_id = ?',
    whereArgs: [localSubId],
  );
}

/// Get sub-products that need remote delete
Future<List<Map<String, dynamic>>> getPendingSubProductDeletes() async {
  final db = await AppDatabase.database;

  return db.query(
    'product_subtypes',
    where: 'is_deleted = 1 AND is_synced = 0',
  );
}


Future<void> hardDeleteSubProduct(String localSubId) async {
  print("hard detelted product done");
  final db = await AppDatabase.database;

  await db.delete(
    'product_subtypes',
    where: 'local_id = ?',
    whereArgs: [localSubId],
  );
}


Future<void> incrementSubProductDeleteRetry(String localSubId) async {
  final db = await AppDatabase.database;

  await db.rawUpdate(
    '''
    UPDATE product_subtypes
    SET delete_retry = COALESCE(delete_retry, 0) + 1
    WHERE local_id = ?
    ''',
    [localSubId],
  );
}


  Future<void> debugPrintOfflineSubProduct() async {
    final db = await AppDatabase.database;
    final rows = await db.query('product_subtypes');
    debugPrint('current Sub types');
    for (final row in rows) {
      debugPrint(row.toString());
    }
  }



}
