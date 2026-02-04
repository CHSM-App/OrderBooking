import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';

class ProductUsecase {
  final ProductRepository productRepository;

  ProductUsecase(this.productRepository);

  /// Add or update a product (offline + online)
  Future<ProductResponse> addOrUpdateProduct(Product product) {
    return productRepository.addOrUpdateProduct(product);
  }

  /// Sync all unsynced products with server
  Future<void> syncProducts() {
    return productRepository.syncOfflineProducts();
  }

  /// Get all products (local + fetch remote if possible)
  Future<List<Product>> getAllProducts(int adminId) {
    return productRepository.getAllProducts(adminId);
  }

  /// Get product details by ID
  Future<ProductDetailsResponse> fetchProductDetails(int productId, int adminId) {
    return productRepository.fetchProductDetails(productId, adminId);
  }

  /// Delete a product subtype
  Future<ProductResponse> deleteProductSubType(int subItemId) {
    return productRepository.deleteProductSubType(subItemId);
  }
  
}
