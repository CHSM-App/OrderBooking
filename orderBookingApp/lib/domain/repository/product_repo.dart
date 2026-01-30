import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';

abstract class ProductRepository {
  /// Insert / Update product
  Future<ProductResponse> addOrUpdateProduct(
      Product product);
        Future<List<Product>>fetchProductList(int adminId);
       
  Future<ProductDetailsResponse> fetchProductDetails(
    int productId,
    int adminId,
  );

 
  Future<ProductResponse> deleteProductSubType(int subItemId);
}
