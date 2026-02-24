import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/usecase/order_usecase.dart';

class ordersState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final AsyncValue<List<Order>>? orders;
  final String? companyId;
  final int? empId;
  final double? todayRevenue;
  final int? todayOrdars;
  final double? monthlyRevenue;

  const ordersState({
    this.todayOrdars,
    this.todayRevenue,
    this.monthlyRevenue,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.orders,
    this.companyId,
    this.empId,
  });

  ordersState copyWith({
    double? todayRevenue,
    double? monthlyRevenue,
    int? todayOrdars,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    final AsyncValue<List<Order>>? orders,
  }) {
    return ordersState(
      todayOrdars: todayOrdars ?? this.todayOrdars,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ordersStateNotifier extends StateNotifier<ordersState> {
  final OrderUsecase usecase;

  ordersStateNotifier(this.usecase) : super(ordersState());

  Future<void> addOrderLineItem(Order order) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );
    try {
      await usecase.addProduct(order);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );

      print("error $e");
    }
  }

  //get Offline orders of that employee
  Future<void> getAllOrders(int empId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final result = await usecase.getAllOrders(empId);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        orders: AsyncValue.data(result),
      );

      await countTodayOrders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  //Get all orders by companyId
  Future<void> getOrderList(
    String companyId, {
    bool useCacheFirst = true,
  }) async {
    var hasCached = false;

    if (useCacheFirst) {
      try {
        final cached = await usecase.getCachedOrderList(companyId);
        if (cached.isNotEmpty) {
          final hasDetailFields = cached.any((o) {
            final empOk = (o.empName ?? '').trim().isNotEmpty;
            final shopOk = (o.shopNamep ?? '').trim().isNotEmpty;
            final addrOk = (o.address ?? '').trim().isNotEmpty;
            return empOk || shopOk || addrOk;
          });
          if (hasDetailFields) {
            hasCached = true;
            state = state.copyWith(
              isLoading: false,
              errorMessage: null,
              isSuccess: true,
              orders: AsyncValue.data(cached),
            );
          }
        }
      } catch (_) {}
    }

    state = state.copyWith(
      isLoading: !hasCached,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final result = await usecase.getOrderList(companyId);
      await usecase.cacheOrderList(companyId, result);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        orders: AsyncValue.data(result),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: hasCached ? null : e.toString(),
        isSuccess: false,
      );
    }
  }

  //get all order for an employee(remote)
  Future<void> getEmployeeOrders(int empId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final result = await usecase.getEmployeeOrders(empId);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        orders: result.length < 1
            ? AsyncValue.data([])
            : AsyncValue.data(result),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> countTodayOrders() async {
    final list =
        state.orders?.maybeWhen(data: (value) => value, orElse: () => []) ?? [];
    final todaysOrders = list
        .where((order) => _isToday(order.orderDate))
        .length;
    final todaysRevenue = list
        .where((order) => _isToday(order.orderDate))
        .fold<double>(0.0, (sum, order) => sum + order.totalPrice);
    final monthlyRevenue = list
        .where((order) => _isThisMonth(order.orderDate))
        .fold(0.0, (sum, order) => sum + order.totalPrice);

    state = state.copyWith(
      todayOrdars: todaysOrders,
      todayRevenue: todaysRevenue,
      monthlyRevenue: monthlyRevenue,
    );
  }

  bool _isToday(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final local = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      return local.year == now.year &&
          local.month == now.month &&
          local.day == now.day;
    } catch (_) {
      return false;
    }
  }

  bool _isThisMonth(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final local = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      return local.year == now.year && local.month == now.month;
    } catch (_) {
      return false;
    }
  }
}
