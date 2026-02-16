import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/usecase/product_usecase.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<Product>>? productList;
  final AsyncValue<List<Product>>?productReport;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.productList = const AsyncValue.loading(),
    this.productReport = const AsyncValue.loading(),
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<ProductResponse>? addUpdateResponse,
    AsyncValue<List<Product>>? productList,
    AsyncValue<List<Product>>? productReport,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      productList: productList ?? this.productList,
      productReport: productReport ?? this.productReport,
    );
  }
}

class ProductViewModel extends StateNotifier<ProductState> {
  final ProductUsecase usecase;

  ProductViewModel(this.usecase) : super(const ProductState());

  /// Add or Update Product (offline + online)
  Future<void> addOrUpdateProduct(Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addOrUpdateProduct(product);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        addUpdateResponse: AsyncValue.error(e, st),
      );
    }
  }

  /// Fetch Product List
  Future<void> fetchProductList(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await usecase.getAllProducts(companyId);
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
                  
  /// Delete a Product Subtype
  Future<void> deleteProductSubType(List<int> subItemId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.deleteProductSubType(subItemId);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        addUpdateResponse: AsyncValue.error(e, st),
      );
    }
  }
  
  /// Get Product Report
  Future<void> getProductReport(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.getProductReport(companyId);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        productReport: AsyncValue.error(e, st),
      );
    }
  }

}
