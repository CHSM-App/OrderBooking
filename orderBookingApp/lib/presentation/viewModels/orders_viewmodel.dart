import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as ref;


import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/usecase/order_usecase.dart';

class ordersState{
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final companyId;
  
 const ordersState({
    required this.isLoading,
    required this.isSuccess,
     this.errorMessage,
     this.companyId
  });


  ordersState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ordersState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}


class ordersStateNotifier extends StateNotifier<ordersState> {
  final OrderUsecase usecase;

  ordersStateNotifier(this.usecase) : super(ordersState(isLoading: false, isSuccess: false));

  Future<void> addOrderLineItem(Order order) async {
    debugPrint("In the viwModal");
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
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

   Future<void> getOrderList(String companyId) async {
    debugPrint("In the viwModal");

    state = state.copyWith(isLoading: true, errorMessage: null,);
    try {
      final result=  await usecase.getOrderList();
      state = state.copyWith(isLoading: false,);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

}