

import 'package:order_booking_app/domain/models/orders.dart';

abstract class OrdersRepository {
  Future<dynamic> addProduct(Order order);

  Future<List<Order>> getOrderList();
}