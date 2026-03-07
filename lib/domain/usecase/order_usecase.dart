import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/repository/orders_repo.dart';

class OrderUsecase {
  final OrdersRepository ordersRepository;

  OrderUsecase(this.ordersRepository);
  Future<dynamic> addProduct(Order order) {
    return ordersRepository.addProduct(order);
  }

  Future<void> syncOfflineOrders() {
    return ordersRepository.syncOfflineOrders();
  }

  Future<List<Order>> getAllOrders(int empId) {
    return ordersRepository.getAllOrders(empId);
  }

  Future<void> syncServerOrdersToLocal(int empId) {
    return ordersRepository.syncServerOrdersToLocal(empId);
  }

  Future<List<Order>> getOrderList(String companyId) {
    return ordersRepository.getOrderList(companyId);
  }

  Future<List<Order>> getCachedOrderList(String companyId) {
    return ordersRepository.getCachedOrderList(companyId);
  }

  Future<void> cacheOrderList(String companyId, List<Order> orders) {
    return ordersRepository.cacheOrderList(companyId, orders);
  }

  Future<List<Order>> getEmployeeOrders(int empId) async {
    return ordersRepository.getEmployeeOrders(empId);
  }

  Future<void> markDeliveredByLocalIds(List<String> localIds, List<int> serverIds) async {
    return ordersRepository.markDeliveredByLocalIds(localIds, serverIds);
  }
}
