import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';

class ProductUsecase {
  final ProductRepository productRepository;

  ProductUsecase(this.productRepository);
  
  /// Add or update a product (offline + online)
  Future<void> addOrUpdateProduct(Product product) async {
   await productRepository.addOrUpdateProductOffline(product);
  }

  /// Sync all unsynced products with server
  Future<void> sync(String companyId) {
    return productRepository.sync(companyId);
  }

  /// Get all products (local + fetch remote if possible)
  Future<List<Product>> getAllProducts(String companyId) {
    return productRepository.getAllProducts(companyId);
  }

  /// Delete a product subtype
  Future<void> deleteProductSubType(String subItemId) async {
    // return productRepository.deleteProductSubType(subItemId);
    await productRepository.deleteSubProduct(subItemId.toString());
  }
  
}
