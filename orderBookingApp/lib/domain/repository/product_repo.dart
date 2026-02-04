
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';

abstract class ProductRepository {
  /// Insert or update a product (offline first, then online)
  Future<ProductResponse> addOrUpdateProduct(Product product);

  /// Sync all unsynced products from local database to server
  Future<void> syncOfflineProducts();

  /// Fetch all products (tries online first, falls back to local)
  Future<List<Product>> getAllProducts(int adminId);

  /// Fetch product details by product ID and admin ID
  Future<ProductDetailsResponse> fetchProductDetails(
    int productId,
    int adminId,
  );

  /// Delete a product subtype (offline + online)
  Future<ProductResponse> deleteProductSubType(int subItemId);
}
