import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/usecase/order_usecase.dart';

class ordersState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final AsyncValue<List<Order>>? orders;

  const ordersState({
    required this.isLoading,
    required this.isSuccess,
    this.errorMessage,
    this.orders,
  });

  ordersState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
      final AsyncValue<List<Order>>? orders
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
    : super(ordersState(isLoading: false, isSuccess: false));

  Future<void> addOrderLineItem(Order order) async {
    debugPrint("In the viwModal");
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );
    try {
      await usecase.addProduct(order);
      state = state.copyWith(isLoading: false, isSuccess: true);
      await getAllOrders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> syncOfflineOrders(int empID) async {
    await usecase.syncOfflineOrders();
    await usecase.syncServerOrdersToLocal(empID);
  }

  Future<void> getAllOrders() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
     final result =  await usecase.getAllOrders();
       state = state.copyWith(isLoading: false, isSuccess: true, orders: AsyncValue.data(result));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }
}


