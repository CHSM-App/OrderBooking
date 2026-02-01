
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/repository/orders_repo.dart';

class OrderUsecase {

  final OrdersRepository ordersRepository;

  OrderUsecase(this.ordersRepository);
  Future<dynamic> addProduct(Order order) {
    return ordersRepository.addProduct(order);
  }

}