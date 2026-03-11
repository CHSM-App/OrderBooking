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

  // ── existing ──
  final double? todayRevenue;   // keep if used elsewhere
  final int?    todayOrdars;    // keep if used elsewhere
  final double? monthlyRevenue; // keep if used elsewhere

  // ── new ──
  final int?    deliveredCount;
  final double? deliveredRevenue;
  final double? takenTotalPrice;

  const ordersState({
    this.todayOrdars,
    this.todayRevenue,
    this.monthlyRevenue,
    this.deliveredCount,
    this.deliveredRevenue,
    this.takenTotalPrice,
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
    int?    todayOrdars,
    int?    deliveredCount,
    double? deliveredRevenue,
    double? takenTotalPrice,
    bool?   isLoading,
    String? errorMessage,
    bool?   isSuccess,
    final AsyncValue<List<Order>>? orders,
  }) {
    return ordersState(
      todayOrdars:     todayOrdars     ?? this.todayOrdars,
      todayRevenue:    todayRevenue    ?? this.todayRevenue,
      monthlyRevenue:  monthlyRevenue  ?? this.monthlyRevenue,
      deliveredCount:  deliveredCount  ?? this.deliveredCount,
      deliveredRevenue:deliveredRevenue?? this.deliveredRevenue,
      takenTotalPrice: takenTotalPrice ?? this.takenTotalPrice,
      orders:          orders          ?? this.orders,
      isLoading:       isLoading       ?? this.isLoading,
      errorMessage:    errorMessage,
      isSuccess:       isSuccess       ?? this.isSuccess,
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
        state.orders?.maybeWhen(data: (v) => v, orElse: () => []) ?? [];

    final todayList     = list.where((o) => _isToday(o.orderDate)).toList();
    final deliveredList = todayList.where((o) => o.isDelivered == 1).toList();

    final takenCount    = todayList.length;
    final takenTotal    = todayList.fold<double>(0.0, (s, o) => s + o.totalPrice);
    final delivCount    = deliveredList.length;
    final delivRevenue  = deliveredList.fold<double>(0.0, (s, o) => s + o.totalPrice);

    // monthly = all delivered this month (for Products Revenue card if still needed)
    final monthlyRevenue = list
        .where((o) => _isThisMonth(o.orderDate) && o.isDelivered == 1)
        .fold<double>(0.0, (s, o) => s + o.totalPrice);

    state = state.copyWith(
      todayOrdars:     takenCount,
      todayRevenue:    takenTotal,      // repurposed: taken total price
      deliveredCount:  delivCount,
      deliveredRevenue:delivRevenue,
      takenTotalPrice: takenTotal,
      monthlyRevenue:  monthlyRevenue,
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

  Future<void> markDeliveredByLocalIds(
    List<String> localIds,
    List<int> serverIds, {
    DateTime? deliveredOn,
  }) async {

      state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
      try {
        await usecase.markDeliveredByLocalIds(
          localIds,
          serverIds,
          deliveredOn: deliveredOn,
        );
        state = state.copyWith(isLoading: false, isSuccess: true);
      } catch (e) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString(), isSuccess: false);
      }
  }
}

