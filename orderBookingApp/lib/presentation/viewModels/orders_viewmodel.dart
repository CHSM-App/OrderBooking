
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

  const ordersState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.orders,
    this.companyId,
    this.empId,
  });

  ordersState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    final AsyncValue<List<Order>>? orders,
  }) {
    return ordersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ordersStateNotifier extends StateNotifier<ordersState> {
  final OrderUsecase usecase;

  ordersStateNotifier(this.usecase)
    : super(ordersState());

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
        orders: result.length< 1 ? AsyncValue.data([]): AsyncValue.data(result),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }
}
