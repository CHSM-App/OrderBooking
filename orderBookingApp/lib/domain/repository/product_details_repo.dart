import 'package:order_booking_app/domain/models/product_details.dart';

abstract class ProductRepository {
  Future<List<ProductDetails>> getProducts(int adminId);
}