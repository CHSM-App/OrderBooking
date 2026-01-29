
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/domain/usecase/shop_usecase.dart';

class ShopState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<ShopDetails>>? shopList;
  

   const ShopState({
    this.isLoading = false,
    this.error,
    this.shopList,
  });

  ShopState copyWith({
    bool? isLoading,  
    String? error,
    // bool clearError = false,
    AsyncValue<List<ShopDetails>>? shopList,
  }) {
    return ShopState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      shopList: shopList ?? this.shopList,
    );
  }
}



class ShopViewModel extends StateNotifier<ShopState> {
  final ShopUsecase usecase;

  ShopViewModel(this.usecase) : super(const ShopState());

  Future<void> addShop(ShopDetails shopDetails) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.execute(shopDetails);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  //GET SHOP LIST
  Future<void> getShopList() async {
    debugPrint("Fetching shop list...");
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shop = await usecase.getShopList();
      state = state.copyWith(
  isLoading: false,
  shopList: AsyncValue.data(shop),
);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }



  //Add Visit
  Future<bool> addVisit(VisitPayload visitPayload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await usecase.addVisit(visitPayload);
      state = state.copyWith(isLoading: false);
      return result['success'];
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}


