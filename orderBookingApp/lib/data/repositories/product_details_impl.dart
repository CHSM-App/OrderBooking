import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/product_details.dart';
import 'package:order_booking_app/domain/repository/product_details_repo.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiService apiService;

  ProductRepositoryImpl(this.apiService);

  @override
  Future<List<ProductDetails>> getProducts(int adminId) {
    return apiService.getProductList(adminId); 
  }
}
