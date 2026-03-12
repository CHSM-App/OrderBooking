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

  // ── SO (type == 1) today stats ──
  final int?    soTakenCount;
  final double? soTakenTotal;
  final int?    soDeliveredCount;
  final double? soDeliveredRevenue;

  // ── ASM (type == 2) today stats ──
  final int?    asmTakenCount;
  final double? asmTakenTotal;
  final int?    asmDeliveredCount;
  final double? asmDeliveredRevenue;

  // ── legacy fields (kept for backward compat) ──
  final double? todayRevenue;
  final int?    todayOrdars;
  final double? monthlyRevenue;
  final int?    deliveredCount;
  final double? deliveredRevenue;
  final double? takenTotalPrice;

  const ordersState({
    this.soTakenCount,
    this.soTakenTotal,
    this.soDeliveredCount,
    this.soDeliveredRevenue,
    this.asmTakenCount,
    this.asmTakenTotal,
    this.asmDeliveredCount,
    this.asmDeliveredRevenue,
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
    int?    soTakenCount,
    double? soTakenTotal,
    int?    soDeliveredCount,
    double? soDeliveredRevenue,
    int?    asmTakenCount,
    double? asmTakenTotal,
    int?    asmDeliveredCount,
    double? asmDeliveredRevenue,
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
      soTakenCount:     soTakenCount     ?? this.soTakenCount,
      soTakenTotal:     soTakenTotal     ?? this.soTakenTotal,
      soDeliveredCount: soDeliveredCount ?? this.soDeliveredCount,
      soDeliveredRevenue: soDeliveredRevenue ?? this.soDeliveredRevenue,
      asmTakenCount:    asmTakenCount    ?? this.asmTakenCount,
      asmTakenTotal:    asmTakenTotal    ?? this.asmTakenTotal,
      asmDeliveredCount: asmDeliveredCount ?? this.asmDeliveredCount,
      asmDeliveredRevenue: asmDeliveredRevenue ?? this.asmDeliveredRevenue,
      todayOrdars:      todayOrdars      ?? this.todayOrdars,
      todayRevenue:     todayRevenue     ?? this.todayRevenue,
      monthlyRevenue:   monthlyRevenue   ?? this.monthlyRevenue,
      deliveredCount:   deliveredCount   ?? this.deliveredCount,
      deliveredRevenue: deliveredRevenue ?? this.deliveredRevenue,
      takenTotalPrice:  takenTotalPrice  ?? this.takenTotalPrice,
      orders:           orders           ?? this.orders,
      isLoading:        isLoading        ?? this.isLoading,
      errorMessage:     errorMessage,
      isSuccess:        isSuccess        ?? this.isSuccess,
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

      await countEmployeeOrders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

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
            final empOk  = (o.empName   ?? '').trim().isNotEmpty;
            final shopOk = (o.shopNamep ?? '').trim().isNotEmpty;
            final addrOk = (o.address   ?? '').trim().isNotEmpty;
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
            await countTodayOrders();
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
      await countTodayOrders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: hasCached ? null : e.toString(),
        isSuccess: false,
      );
    }
  }

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
        orders: result.isEmpty
            ? AsyncValue.data([])
            : AsyncValue.data(result),
      );

      await countEmployeeOrders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  // ── Admin: counts split by type (SO = 1, ASM = 2) ──────────────────────────
  Future<void> countTodayOrders() async {
    final list =
        state.orders?.maybeWhen(data: (v) => v, orElse: () => []) ?? [];

    // SO (type == 1)
    final soToday     = list.where((o) => o.type == 1 && _isToday(o.orderDate)).toList();
    final soDelivered = soToday.where((o) => o.isDelivered == 1).toList();

    final soTakenCount     = soToday.length;
    final soTakenTotal     = soToday.fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());
    final soDeliveredCount = soDelivered.length;
    final soDeliveredRev   = soDelivered.fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());

    // ASM (type == 2)
    final asmToday     = list.where((o) => o.type == 2 && _isToday(o.orderDate)).toList();
    final asmDelivered = asmToday.where((o) => o.isDelivered == 1).toList();

    final asmTakenCount     = asmToday.length;
    final asmTakenTotal     = asmToday.fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());
    final asmDeliveredCount = asmDelivered.length;
    final asmDeliveredRev   = asmDelivered.fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());

    final monthlyRevenue = list
        .where((o) => _isThisMonth(o.orderDate) && o.isDelivered == 1)
        .fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());

    state = state.copyWith(
      soTakenCount:        soTakenCount,
      soTakenTotal:        soTakenTotal,
      soDeliveredCount:    soDeliveredCount,
      soDeliveredRevenue:  soDeliveredRev,
      asmTakenCount:       asmTakenCount,
      asmTakenTotal:       asmTakenTotal,
      asmDeliveredCount:   asmDeliveredCount,
      asmDeliveredRevenue: asmDeliveredRev,
      monthlyRevenue:      monthlyRevenue,
    );
  }

  // ── Employee: no type filter, just today's orders + delivered check ─────────
  Future<void> countEmployeeOrders() async {
    final list =
        state.orders?.maybeWhen(data: (v) => v, orElse: () => []) ?? [];

    final todayList     = list.where((o) => _isToday(o.orderDate)).toList();
    final deliveredList = todayList.where((o) => o.isDelivered == 1).toList();

    final takenCount   = todayList.length;
    final takenTotal   = todayList.fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());
    final delivCount   = deliveredList.length;
    final delivRevenue = deliveredList.fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());

    final monthlyRevenue = list
        .where((o) => _isThisMonth(o.orderDate) && o.isDelivered == 1)
        .fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble());

    state = state.copyWith(
      todayOrdars:      takenCount,
      takenTotalPrice:  takenTotal,
      todayRevenue:     takenTotal,
      deliveredCount:   delivCount,
      deliveredRevenue: delivRevenue,
      monthlyRevenue:   monthlyRevenue,
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