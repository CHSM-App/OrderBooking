import 'package:order_booking_app/data/api/api_service.dart';

import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';

class ProductImpl implements ProductRepository {
  final ApiService apiService;

  ProductImpl(this.apiService);

  @override
  Future<ProductResponse> addOrUpdateProduct(Product product) {
    return apiService.addOrUpdateProduct(product);
  }

   @override
  Future<List<Product>> fetchProductList(int adminId) {
    return apiService.fetchProductList(adminId);
  }
  
  
  @override
  Future<ProductDetailsResponse> fetchProductDetails( int productId, int adminId,) {
    return apiService.fetchProductDetails(productId, adminId);
  }

   @override
  Future<ProductResponse> deleteProductSubType(int subItemId) {
    return apiService.deleteProductSubType(subItemId);
  }
}
