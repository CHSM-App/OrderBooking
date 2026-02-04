import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/product_dao.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';
import 'package:uuid/uuid.dart';

class ProductImpl implements ProductRepository {
  final ApiService apiService;
  final ProductDao local;

  ProductImpl(this.apiService, this.local);
Future<ProductResponse> addOrUpdateProduct(Product product) async {
  // 1️⃣ Always save offline first
  final offlineProduct = product.copyWith(
    localId: product.localId ?? const Uuid().v4(),
    isSynced: false,
    updatedAt: DateTime.now(),
  );

  await local.insertProducts([offlineProduct], markSynced: false);

  // 2️⃣ Check connectivity
  final connectivityResult = await Connectivity().checkConnectivity();
  final isOnline = connectivityResult != ConnectivityResult.none;

  if (!isOnline) {
    return ProductResponse(
      success: true,
      message: 'Saved offline, will sync later',
    );
  }

  // 3️⃣ Try online
  try {
    final response = await apiService.addOrUpdateProduct(product);
    if (response.success && response.productId != null && offlineProduct.localId != null) {
      await local.updateProductId(offlineProduct.localId!, response.productId!);
    }
    return response;
  } catch (e) {
    // 4️⃣ If online fails, return offline success
    print('Online sync failed: $e');
    return ProductResponse(
      success: true,
      message: 'Saved offline, will sync later',
    );
  }
}


  /// Sync all offline products to server
  @override
  Future<void> syncOfflineProducts() async {
    final unsyncedProducts = await local.getUnsyncedProducts();

    for (final product in unsyncedProducts) {
      try {
        if (product.subtypes == null || product.subtypes!.isEmpty) continue;

        final response = await apiService.addOrUpdateProduct(product);

        if (response.success &&
            response.productId != null &&
            product.localId != null) {
          await local.updateProductId(product.localId!, response.productId!);
        }
      } catch (e) {
        print('Sync failed for ${product.productName}: $e');
      }
    }
  }

  /// Get all products (remote first, fallback local)
  @override
  Future<List<Product>> getAllProducts(int adminId) async {
    try {
      final remoteProducts = await apiService.fetchProductList(adminId);
      if (remoteProducts.isNotEmpty) {
        await local.insertProducts(remoteProducts, markSynced: true);
      }
    } catch (_) {
      // fallback local
    }
    return local.getAllProducts();
  }

  /// Fetch product details
  @override
  Future<ProductDetailsResponse> fetchProductDetails(
      int productId, int adminId) async {
    final localProduct = await local.getProductById(productId);
    if (localProduct != null) {
      return ProductDetailsResponse(
        product: localProduct,
        subitems: localProduct.subtypes ?? [],
      );
    }

    final details = await apiService.fetchProductDetails(productId, adminId);
    await local.insertProducts([details.product], markSynced: true);
    return details;
  }

  /// Delete product subtype
  @override
  Future<ProductResponse> deleteProductSubType(int subItemId) async {
    final products = await local.getAllProducts();
    String? subLocalId;

    for (final product in products) {
      for (final sub in product.subtypes ?? []) {
        if (sub.subItemId == subItemId) {
          subLocalId = sub.localId;
          break;
        }
      }
      if (subLocalId != null) break;
    }

    if (subLocalId != null) {
      await local.deleteProductSubType(subLocalId);
    }

    try {
      return await apiService.deleteProductSubType(subItemId);
    } catch (e) {
      return ProductResponse(
        success: false,
        message: 'Deleted locally, failed to delete remotely.',
      );
    }
  }
}
