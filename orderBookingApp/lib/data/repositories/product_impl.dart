import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/product_dao.dart';

import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';

class ProductImpl implements ProductRepository {
  final ApiService apiService;
    final ProductDao local;

  ProductImpl(this.apiService, this.local);

  @override
  Future<ProductResponse> addOrUpdateProduct(Product product) {
    return apiService.addOrUpdateProduct(product);
  }

   @override
  Future<List<Product>> fetchProductList(int adminId) async {
     // 1️⃣ Load from local immediately
    final localData = await local.getAllProducts();

    // 2️⃣ Refresh from server in background
    try {
      final remoteData = await apiService.fetchProductList(adminId);
      await local.insertProducts(remoteData);
    } catch (_) {
      // ignore network errors
    }

    // 3️⃣ Return local (updated if fetch succeeded)
    return await local.getAllProducts();
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
