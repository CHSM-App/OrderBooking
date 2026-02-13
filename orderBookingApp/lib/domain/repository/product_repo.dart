
import 'package:order_booking_app/domain/models/product.dart';

abstract class ProductRepository {

  Future<void> addOrUpdateProductOffline(Product product);
  Future<List<Product>> getAllProducts(String companyId);
  Future<void> syncLocalToRemote();
  Future<void> syncRemoteToLocal(String companyId);
  Future<void> sync(String companyId);
  Future<void> deleteSubProduct(int SubItemId);
  Future<void> syncDeletedSubProducts();
}
