import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/repository/orders_repo.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final ApiService _apiService;

  OrdersRepositoryImpl(this._apiService);

  @override
  Future<void> addProduct(Order order) async {
    try {
     
        await _apiService.addProduct(order);
      
    } catch (e) {
      throw Exception('Failed to add order line item: $e');
    }
  }
}
