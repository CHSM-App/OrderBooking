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
      // await _apiService.addProduct(order);
      await offlineOrderDao.insertOrder(order);
    } catch (e) {
      throw Exception('Failed to add order line item: $e');
    }
  }

  Future<void> syncOfflineOrders() async {
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
            measuringUnit: r['measuring_unit'],
          );
        }).toList();

        final order = Order(
          localOrderId: o['local_order_id'],
          employeeId: o['employee_id'],
          shopId: o['shop_id'],
          ownerName: o['owner_name'],
          mobileNo: o['mobile_no'],
          orderDate: o['order_date'],
          companyId: o['company_id'],
          isDelivered: o['is_delivered'],
          items: items,
          totalPrice: o['total_price'],
        );

        // 🔥 Send to server
        final response = await _apiService.addOrder(order);

        final serverOrderId = response['order_id'] as int;

        // ✅ Mark local order synced
        await offlineOrderDao.markSynced(localOrderId, serverOrderId);
      } catch (e) {
        await offlineOrderDao.incrementRetry(localOrderId);
      }
    }
  }

  Future<List<Order>> getAllOrders(int empId) async {
    try {
      await syncOfflineOrders();
    } catch (_) {
      // Ignore sync errors and fall back to local data.
    }
    try {
      await syncServerOrdersToLocal(empId);
    } catch (_) {
      // Ignore sync errors and fall back to local data.
    }
    final rows = await offlineOrderDao.fetchAllOrders();

    final result = <Order>[];

    for (final row in rows) {
      final localOrderId = row['local_order_id'] as String;

      final itemRows = await offlineOrderDao.fetchItems(localOrderId);

      final items = itemRows.map((r) {
        return OrderItem(
          productId: r['product_id'],
          subItemId: r['sub_item_id'],
          productName: r['product_name'],
          productUnit: r['product_unit'],
          price: (r['price'] as num).toDouble(),
          quantity: r['quantity'],
          measuringUnit: r['measuring_unit'],
        );
      }).toList();

      result.add(
        Order(
          localOrderId: row['local_order_id'],
          serverOrderId: row['server_order_id'],
          employeeId: row['employee_id'],
          shopId: row['shop_id'],
          shopNamep: row['shop_name'],
          empName: row['emp_name'],
          address: row['address'],
          ownerName: row['owner_name'],
          mobileNo: row['mobile_no'],
          orderDate: row['order_date'],
          isDelivered: row['is_delivered'],
          items: items,
          totalPrice: (row['total_price'] as num).toDouble(),
          companyId: row['company_id'],
        ),
      );
    }

    return result;
  }

  Future<void> syncServerOrdersToLocal(int employeeId) async {
    // Push pending delivered order ids before pulling latest orders
    try {
      await _syncDeliveredOrders();
    } catch (_) {
      // Ignore delivery sync errors; keep them pending.
    }

    // 1️⃣ Fetch from server
    final serverOrders = await _apiService.getOrders(employeeId);
    // assuming this returns List<Order>

    for (final serverOrder in serverOrders) {
      // 🔑 server order id must come from API
      final serverOrderId = serverOrder.serverOrderId; // or from JSON if mapped

      // 2️⃣ Skip if already stored locally
      final exists = await offlineOrderDao.existsByServerOrderId(
        serverOrderId ?? 0,
      );

      if (exists) continue;

      // 3️⃣ Create a stable localOrderId
      final localOrderId = 'server-$serverOrderId';

      final localOrder = Order(
        localOrderId: localOrderId,
        ownerName: serverOrder.ownerName,
        mobileNo: serverOrder.mobileNo,
        employeeId: serverOrder.employeeId,
        shopId: serverOrder.shopId,
        shopNamep: serverOrder.shopNamep,
        empName: serverOrder.empName,
        address: serverOrder.address,
        orderDate: serverOrder.orderDate,
        items: serverOrder.items,
        totalPrice: serverOrder.totalPrice,
        isDelivered: serverOrder.isDelivered,
        companyId: serverOrder.companyId,
      );

      // 4️⃣ Save to local DB
      await offlineOrderDao.insertRemoteOrder(
        order: localOrder,
        serverOrderId: serverOrderId ?? 0,
      );
    }
  }

  Future<void> markDeliveredByLocalIds(
    List<String> localIds,
    List<int> serverIds, {
    DateTime? deliveredOn,
  }) async {
    await offlineOrderDao.markDeliveredByLocalIds(localIds);
    await offlineOrderDao.insertDeliveredOrders(
      serverIds,
      deliveredOn: deliveredOn,
    );
  }

  Future<void> _syncDeliveredOrders() async {
    final pendingRows = await offlineOrderDao.fetchPendingDeliveredOrders();
    if (pendingRows.isEmpty) return;
    final payload = pendingRows
        .map((row) => {
              'order_id': row['server_order_id'],
              'delivered_on': row['delivered_on'],
            })
        .toList();
    final pendingIds = pendingRows
        .map((row) => row['server_order_id'])
        .whereType<int>()
        .toList();
    await _apiService.markDelivered(payload);
    await offlineOrderDao.markDeliveredSynced(pendingIds);
  }

  Future<List<Order>> getOrderList(String companyId) {
    return _apiService.getOrderList(companyId);
  }

  Future<List<Order>> getEmployeeOrders(int empId) {
    return _apiService.getOrders(empId);
  }

  Future<List<Order>> getCachedOrderList(String companyId) async {
    return offlineOrderDao.fetchCachedCompanyOrders(companyId);
  }

  Future<void> cacheOrderList(String companyId, List<Order> orders) async {
    await offlineOrderDao.replaceCachedCompanyOrders(companyId, orders);
  }
}
