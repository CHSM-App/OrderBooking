import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/product_details.dart';
import 'package:order_booking_app/domain/usecase/product_details_usecase.dart';

/// STATE
class ProductState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<ProductDetails>>? productList;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.productList = const AsyncValue.loading(),
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<List<ProductDetails>>? productList,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      productList: productList ?? this.productList,
    );
  }
}


/// VIEWMODEL
class ProductViewModel extends StateNotifier<ProductState> {
  final GetProductListUseCase usecase;
  final int adminId = 1;

  ProductViewModel(this.usecase, int adminId) : super(const ProductState());

  Future<void> getProductList() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await usecase.getProductList(adminId);
      state = state.copyWith(
        isLoading: false,
        productList: AsyncValue.data(products),
      );
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        productList: AsyncValue.error(e, st),
      );
    }
  }
}

