

import 'package:order_booking_app/domain/models/orders.dart';

abstract class OrdersRepository {
  Future<dynamic> addProduct(Order order);
  Future<void> syncOfflineOrders();
  Future<List<Order>> getAllOrders(int empId);
  Future<void> syncServerOrdersToLocal(int empId);

  Future<List<Order>> getOrderList(String companyId);
  Future<List<Order>> getCachedOrderList(String companyId);
  Future<void> cacheOrderList(String companyId, List<Order> orders);

  Future<List<Order>> getEmployeeOrders(int empId);
}
