import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';

class ProductUsecase {
  final ProductRepository productRepository;

  ProductUsecase(this.productRepository);

  /// Add / Update Product
  Future<ProductResponse> addOrUpdateProduct(
      Product product) {
    return productRepository.addOrUpdateProduct(product);
  }
  Future<List<Product>>fetchProductList(int adminId){
    return productRepository.fetchProductList(adminId);
  }

  Future<ProductDetailsResponse> fetchProductDetails( int productId, int adminId,) {
    return productRepository.fetchProductDetails(productId, adminId);
  }
}
