
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_data.dart';

abstract class ProductRepository {

  Future<void> addOrUpdateProductOffline(Product product);
  Future<List<Product>> getAllProducts(String companyId);
  // Future<void> syncLocalToRemote();
  Future<void> syncRemoteToLocal(String companyId);
  // Future<void> sync(String companyId);
  Future<void> deleteSubProduct(List<int> SubItemId);
  // Future<void> syncDeletedSubProducts();
  Future<List<ProductData>> productReport(String companyId);
}
