import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/offline_order_dao.dart';
import 'package:order_booking_app/domain/models/order_item.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/repository/orders_repo.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final ApiService _apiService;
  final OfflineOrderDao offlineOrderDao;

  OrdersRepositoryImpl(this._apiService, this.offlineOrderDao);

  @override
  Future<void> addProduct(Order order) async {
    try {
      print("in the repository, Syncing offline");
      // await _apiService.addProduct(order);
      await offlineOrderDao.insertOrder(order);
      await syncOfflineOrders();
    } catch (e) {
      throw Exception('Failed to add order line item: $e');
    }
  }

  Future<void> syncOfflineOrders() async {
    print("in the syncOfflineOrders of repo");
    final orders = await offlineOrderDao.fetchPendingOrders();

    for (final o in orders) {
      final localOrderId = o['local_order_id'] as String;

      try {
        final itemRows = await offlineOrderDao.fetchItems(localOrderId);

        final items = itemRows.map((r) {
          return OrderItem(
            productId: r['product_id'],
            subItemId: r['sub_item_id'],
            productUnit: r['product_unit'],
            price: r['price'],
            quantity: r['quantity'],
          );
        }).toList();

        final order = Order(
          localOrderId: o['local_order_id'],
          employeeId: o['employee_id'],
          shopId: o['shop_id'],
          orderDate: o['order_date'],
          items: items,
          totalPrice: o['total_price'],
        );

        // 🔥 Send to server
        final response = await _apiService.addProduct(order);

        final serverOrderId = response['order_id'] as int;

        // ✅ Mark local order synced
        await offlineOrderDao.markSynced(localOrderId, serverOrderId);
      } catch (e) {
        await offlineOrderDao.incrementRetry(localOrderId);
      }
    }
  }


  Future<List<Order>> getAllOrders() async {
  final rows = await offlineOrderDao.fetchAllOrders();

  final result = <Order>[];

  for (final row in rows) {
    final localOrderId = row['local_order_id'] as String;

    final itemRows =
        await offlineOrderDao.fetchItems(localOrderId);

    final items = itemRows.map((r) {
      return OrderItem(
        productId: r['product_id'],
        subItemId: r['sub_item_id'],
        productName: r['product_name'],
        productUnit: r['product_unit'],
        price: (r['price'] as num).toDouble(),
        quantity: r['quantity'],
      );
    }).toList();

    result.add(
      Order(
        localOrderId: row['local_order_id'],
        employeeId: row['employee_id'],
        shopId: row['shop_id'],
        shopNamep: row['shop_name'],
        orderDate: row['order_date'],
        items: items,
        totalPrice: (row['total_price'] as num).toDouble(),
      ),
    );
  }

  return result;
}




  
  Future<List<Order>> getOrderList(){
     return _apiService.getOrderList();
  }
}
