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

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final product in products) {
        final localId = product.localId ?? const Uuid().v4();

        // 🔥 Always REPLACE product
        batch.insert('products', {
          'local_id': localId,
          'product_id': product.productId,
          'product_name': product.productName,
          'quantity_per_box': product.quantityPerBox,
          'created_by': product.createdBy,
          'admin_id': product.adminId,
          'company_id': product.companyId,
          'product_unit': product.productUnit,
          'total_price': product.totalPrice,
          'shop_id': product.shopId,
          'is_synced': markSynced ? 1 : 0,
          'updated_at': product.updatedAt?.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // 🔥 Always REPLACE subtypes
        // if (product.subtypes != null) {
        //   for (final sub in product.subtypes!) {
        //     // await txn.delete(
        //     //   'product_subtypes',
        //     //   where: 'server_product_id = ?',
        //     //   whereArgs: [product.productId],
        //     // );
        //     batch.insert('product_subtypes', {
        //       'local_id': sub.localId ?? const Uuid().v4(),
        //       'product_local_id': localId,
        //       'server_product_id': product.productId,
        //       'sub_item_id': sub.subItemId, // must be UNIQUE
        //       'measuring_unit': sub.measuringUnit,
        //       'available_unit': sub.availableUnit,
            
        //       'total': sub.total,
        //       'is_synced': markSynced ? 1 : 0,
        //       'is_deleted': 0,
        //       'updated_at': product.updatedAt?.toIso8601String(),
        //     }, conflictAlgorithm: ConflictAlgorithm.replace);
        //   }
        // }
      }

      await batch.commit(noResult: true);
    });
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
          quantityPerBox: row['quantity_per_box'] as int?,
          createdBy: row['created_by'] as int?,
          adminId: row['admin_id'] as int?,
          companyId: row['company_id'] as String?,
          productUnit: row['product_unit'] as String?,
          totalPrice: row['total_price'] != null
              ? (row['total_price'] as num).toDouble()
              : null,
          shopId: row['shop_id'] as int?,
          // subtypes: subtypes,
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
     
        total: row['total'] as int?,
        localId: row['local_id'] as String?,
        productLocalId: row['product_local_id'] as String?,
        isSynced: (row['is_synced'] ?? 0) == 1,
      );
    }).toList();
  }

  Future<void> deleteSubtypesNotIn(
    List<int> serverProductIds,
    List<int> serverSubItemIds,
  ) async {
    final db = await AppDatabase.database;

    await db.transaction((txn) async {
      if (serverProductIds.isNotEmpty) {
        final productPlaceholders = List.filled(
          serverProductIds.length,
          '?',
        ).join(',');

        await txn.delete(
          'product_subtypes',
          where: 'server_product_id NOT IN ($productPlaceholders)',
          whereArgs: serverProductIds,
        );
      }

      if (serverSubItemIds.isNotEmpty) {
        final subtypePlaceholders = List.filled(
          serverSubItemIds.length,
          '?',
        ).join(',');

        await txn.delete(
          'product_subtypes',
          where: 'sub_item_id NOT IN ($subtypePlaceholders)',
          whereArgs: serverSubItemIds,
        );
      }
    });
  }

  Future<void> deleteProductsNotIn(List<int> serverProductIds) async {
    final db = await AppDatabase.database;

    if (serverProductIds.isEmpty) {
      // If server returns nothing, clear everything
      await db.delete('product_subtypes');
      await db.delete('products');
      return;
    }

    final placeholders = List.filled(serverProductIds.length, '?').join(',');

    await db.delete(
      'products',
      where: 'product_id NOT IN ($placeholders)',
      whereArgs: serverProductIds,
    );

    await db.delete(
      'product_subtypes',
      where: 'server_product_id NOT IN ($placeholders)',
      whereArgs: serverProductIds,
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
