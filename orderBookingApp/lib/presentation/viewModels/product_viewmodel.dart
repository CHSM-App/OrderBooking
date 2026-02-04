import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/usecase/product_usecase.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  final AsyncValue<ProductResponse?>? addUpdateResponse;
  final AsyncValue<List<Product>>? productList;
  final AsyncValue<ProductDetailsResponse?> productDetails;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.addUpdateResponse = const AsyncValue.data(null),
    this.productList = const AsyncValue.loading(),
    this.productDetails = const AsyncValue.data(null),
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<ProductResponse>? addUpdateResponse,
    AsyncValue<List<Product>>? productList,
    AsyncValue<ProductDetailsResponse?>? productDetails,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      addUpdateResponse: addUpdateResponse ?? this.addUpdateResponse,
      productList: productList ?? this.productList,
      productDetails: productDetails ?? this.productDetails,
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
      final response = await usecase.addOrUpdateProduct(product);
      state = state.copyWith(
        isLoading: false,
        addUpdateResponse: AsyncValue.data(response),
      );
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        addUpdateResponse: AsyncValue.error(e, st),
      );
    }
  }

  /// Fetch Product List
  Future<void> fetchProductList(int adminId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await usecase.getAllProducts(adminId);
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

  /// Fetch Product Details by ID
  Future<void> fetchProductDetails(int productId, int adminId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      productDetails: const AsyncValue.loading(),
    );

    try {
      final details = await usecase.fetchProductDetails(productId, adminId);
      state = state.copyWith(
        isLoading: false,
        productDetails: AsyncValue.data(details),
      );
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        productDetails: AsyncValue.error(e, st),
      );
    }
  }

  /// Delete a Product Subtype
  Future<void> deleteProductSubType(int subItemId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await usecase.deleteProductSubType(subItemId);
      state = state.copyWith(
        isLoading: false,
        addUpdateResponse: AsyncValue.data(response),
      );
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        addUpdateResponse: AsyncValue.error(e, st),
      );
    }
  }

  /// Clear Product Details (Optional)
  void clearProductDetails() {
    state = state.copyWith(
      productDetails: const AsyncValue.data(null),
    );
  }

  /// Sync Unsynced Products
  Future<void> syncProducts() async {
    await usecase.syncProducts();
    // Optionally refresh product list after sync
    if (state.productList?.value?.isNotEmpty ?? false) {
      final adminId = state.productList!.value!.first.adminId ?? 0;
      await fetchProductList(adminId);
    }
  }
}
