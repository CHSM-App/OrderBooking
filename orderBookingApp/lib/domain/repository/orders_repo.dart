

import 'package:order_booking_app/domain/models/orders.dart';

abstract class OrdersRepository {
  Future<dynamic> addProduct(Order order);
  Future<void> syncOfflineOrders();
  Future<List<Order>> getAllOrders();
  Future<void> syncServerOrdersToLocal(int empId);
}