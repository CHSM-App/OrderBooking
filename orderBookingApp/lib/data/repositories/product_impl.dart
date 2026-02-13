import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/product_dao.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';
import 'package:uuid/uuid.dart';

class ProductImpl implements ProductRepository {
  final ApiService api;
  final ProductDao local;

  ProductImpl(this.api, this.local);

  @override
  Future<void> addOrUpdateProductOffline(Product product) async {
    // final offlineProduct = product.copyWith(
    //   localId: product.localId ?? const Uuid().v4(),
    //   isSynced: false,
    //   updatedAt: DateTime.now(),
    // );

    // await local.insertProducts([offlineProduct], markSynced: false);

    await api.addOrUpdateProduct(product);
  }

  @override
  Future<List<Product>> getAllProducts(String companyId) async {
    // await syncLocalToRemote();
    await syncRemoteToLocal(companyId);
    await syncDeletedSubProducts();
    return local.getAllProducts();

  }


    /// User-triggered delete
  Future<void> deleteSubProduct(int subItemId) async {
     await api.deleteProductSubType(subItemId);
    // 1️⃣ Local first (instant UI update)
    // await local.markSubProductDeleted(localSubId);

    // await syncDeletedSubProducts();

    // await local.debugPrintOfflineSubProduct();
  }

  @override
  Future<void> syncLocalToRemote() async {
    final unsyncedProducts = await local.getUnsyncedProducts();

    for (final product in unsyncedProducts) {
      try {
        if (product.subtypes == null || product.subtypes!.isEmpty) {
          continue;
        }

        final response = await api.addOrUpdateProduct(product);

        if (response.success &&
            response.productId != null &&
            product.localId != null) {
          await local.updateProductId(product.localId!, response.productId!);
        }
      } catch (e) {
        print('Local → Remote sync failed: ${product.productName}');
      }
    }
  }

  @override
  Future<void> syncRemoteToLocal(String companyId) async {
    try {
      final remoteProducts = await api.fetchProductList(companyId);

      if (remoteProducts.isEmpty) return;

      await local.insertProducts(remoteProducts, markSynced: true);
    } catch (e) {
      print('Remote → Local sync failed');
    }
  }



  Future<void> syncDeletedSubProducts() async {
    final pendingDeletes = await local.getPendingSubProductDeletes();

    for (final row in pendingDeletes) {
      final localId = row['local_id'] as String?;
      final serverSubItemId = row['sub_item_id'] as int?;

      if (localId == null) continue;

      // Case 1: never synced to server
      if (serverSubItemId == null) {
        await local.hardDeleteSubProduct(localId);
        continue;
      }

      try {
        final result = await api.deleteProductSubType(serverSubItemId);
        if (!result.success) {
          throw Exception("Deleting from server Failed");
        }
        await local.hardDeleteSubProduct(localId);
      } catch (e) {
        await local.incrementSubProductDeleteRetry(localId);
      }
    }
  }

  Future<void> sync(String companyId) async {
    await syncLocalToRemote();
    await syncRemoteToLocal(companyId);
    await syncDeletedSubProducts();
    getAllProducts(companyId);
  }
}


