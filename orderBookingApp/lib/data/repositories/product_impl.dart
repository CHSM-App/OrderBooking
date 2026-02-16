import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/product_dao.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';

class ProductImpl implements ProductRepository {
  final ApiService api;
  final ProductDao local;

  ProductImpl(this.api, this.local);

  @override
  Future<void> addOrUpdateProductOffline(Product product) async {
    await api.addOrUpdateProduct(product);
  }

  @override
  Future<List<Product>> getAllProducts(String companyId) async {
    await syncRemoteToLocal(companyId);
    return local.getAllProducts();
  }

    /// User-triggered delete
  Future<void> deleteSubProduct(List<int> subItemId) async {
     await api.deleteProductSubType(subItemId);
  }
@override
Future<void> syncRemoteToLocal(String companyId) async {
  try {
    final remoteProducts = await api.fetchProductList(companyId);

    if (remoteProducts.isEmpty) {
      await local.deleteProductsNotIn([]);
      await local.deleteSubtypesNotIn([], []);
      return;
    }

    final serverProductIds = <int>[];
    final serverSubItemIds = <int>[];

    for (final product in remoteProducts) {
      if (product.productId != null) {
        serverProductIds.add(product.productId!);
      }

      if (product.subtypes != null) {
        for (final sub in product.subtypes!) {
          if (sub.subItemId != null) {
            serverSubItemIds.add(sub.subItemId!);
          }
        }
      }
    }

    // 1️⃣ Upsert everything
    await local.insertProducts(remoteProducts, markSynced: true);

    // 2️⃣ Delete stale products
    await local.deleteProductsNotIn(serverProductIds);

    // 3️⃣ Delete stale subtypes
    await local.deleteSubtypesNotIn(
      serverProductIds,
      serverSubItemIds,
    );

  } catch (e) {
    print('Remote → Local sync failed');
  }
}

Future<void>productReport(String companyId) async {
    try {
      final report = await api.productReport(companyId);
      // Handle the report data as needed
    } catch (e) {
      print('Failed to fetch product report: $e');
    }
  }

}


