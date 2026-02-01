import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:sqflite/sqflite.dart';

class ProductDao {
  Future<void> insertProducts(List<Product> products) async {
    final db = await AppDatabase.database;
    final batch = db.batch();

    for (final product in products) {
      batch.insert(
        'products',
        {
          'product_id': product.productId,
          'product_name': product.productName,
          'product_type': product.productType,
          'created_by': product.createdBy,
          'admin_id': product.adminId,
          'company_id': product.companyId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final sub in product.subtypes ?? []) {
        batch.insert(
          'product_subtypes',
          {
            'sub_item_id': sub.subItemId,
            'product_id': product.productId,
            'measuring_unit': sub.measuringUnit,
            'available_unit': sub.availableUnit,
            'price': sub.price,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await AppDatabase.database;

    final productRows = await db.query('products');

    final result = <Product>[];

    for (final p in productRows) {
      final subtypeRows = await db.query(
        'product_subtypes',
        where: 'product_id = ?',
        whereArgs: [p['product_id']],
      );

      result.add(
        Product(
          productId: p['product_id'] as int,
          productName: p['product_name'] as String?,
          productType: p['product_type'] as String?,
          createdBy: p['created_by'] as int?,
          adminId: p['admin_id'] as int?,
          companyId: p['company_id'] as String?,
          subtypes: subtypeRows.map((s) {
            return ProductSubType(
              subItemId: s['sub_item_id'] as int?,
              measuringUnit: s['measuring_unit'] as String?,
              availableUnit:
                  (s['available_unit'] as num?)?.toDouble(),
              price: (s['price'] as num?)?.toDouble(),
            );
          }).toList(),
        ),
      );
    }

    return result;
  }
}
