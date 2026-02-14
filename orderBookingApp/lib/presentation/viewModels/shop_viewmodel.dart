import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/usecase/shop_usecase.dart';

class ShopState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<ShopDetails>>? shopList;

  const ShopState({this.isLoading = false, this.error, this.shopList});

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
  bool _isAddingShop = false;

  ShopViewModel(this.usecase) : super(const ShopState());

  Future<void> addShop(ShopDetails shopDetails) async {
    if (_isAddingShop || state.isLoading) return;
    _isAddingShop = true;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addShop(shopDetails);
      await getEmpShopList(shopDetails.companyId, shopDetails.regionId ?? 0);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      _isAddingShop = false;
    }
  }

  //GET SHOP LIST
  Future<void> getEmpShopList(String companyId, int regionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shop = await usecase.getEmpShopList(companyId, regionId);

      state = state.copyWith(isLoading: false, shopList: AsyncValue.data(shop));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getShopList(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shop = await usecase.getShopList(companyId);

      state = state.copyWith(isLoading: false, shopList: AsyncValue.data(shop));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateShop(ShopDetails shop) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await usecase.updateShop(shop);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteShop(ShopDetails shop) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await usecase.deleteShop(shop);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
