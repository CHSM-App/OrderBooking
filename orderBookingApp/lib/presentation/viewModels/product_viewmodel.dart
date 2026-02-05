import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/usecase/product_usecase.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  // final AsyncValue<ProductResponse?>? addUpdateResponse;
  final AsyncValue<List<Product>>? productList;
  // final AsyncValue<ProductDetailsResponse?> productDetails;

  const ProductState({
    this.isLoading = false,
    this.error,
    // this.addUpdateResponse = const AsyncValue.data(null),
    this.productList = const AsyncValue.loading(),
    // this.productDetails = const AsyncValue.data(null),
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<ProductResponse>? addUpdateResponse,
    AsyncValue<List<Product>>? productList,
    // AsyncValue<ProductDetailsResponse?>? productDetails,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      // addUpdateResponse: addUpdateResponse ?? this.addUpdateResponse,
      productList: productList ?? this.productList,
      // productDetails: productDetails ?? this.productDetails,
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
  Future<void> deleteProductSubType(String subItemId) async {
    print("sub Item Id $subItemId");
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

  Future<void> syncProducts(String companyId) async {
    await fetchProductList(companyId);
  }
}
