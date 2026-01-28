import 'package:order_booking_app/domain/models/product_details.dart';
import 'package:order_booking_app/domain/repository/product_details_repo.dart';

class GetProductListUseCase {
  final ProductRepository repository;

  GetProductListUseCase(this.repository);

  Future<List<ProductDetails>> getProductList(int i) {
    return repository.getProducts(i);
  }
}
