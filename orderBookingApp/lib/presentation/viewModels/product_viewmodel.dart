import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/models.dart';
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

  /// Add / Update Product
  Future<void> addOrUpdateProduct(Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await usecase.addOrUpdateProduct(product);
      state = state.copyWith(
        isLoading: false,
        addUpdateResponse: AsyncValue.data(response),
      );
    } catch (e) {
    state = state.copyWith(
  isLoading: false,
  error: e.toString(),
  addUpdateResponse: AsyncValue.error(
    e, 
    StackTrace.current,
  ),
);

    }
  }
   Future<void> fetchProductList(int adminId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final productlist = await usecase.fetchProductList(adminId);
      state = state.copyWith(
        isLoading: false,
        productList: AsyncValue.data(productlist),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }


  /// ✅ NEW: Fetch Product Details (Edit Screen)
  Future<void> fetchProductDetails( int productId, int adminId,) async {
    state = state.copyWith(isLoading: true,error: null,productDetails: const AsyncValue.loading(),
    );

    try {
      final details =
          await usecase.fetchProductDetails(productId, adminId);

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

  /// Optional reset
  void clearProductDetails() {
    state = state.copyWith(
      productDetails: const AsyncValue.data(null),
    );
  }
}