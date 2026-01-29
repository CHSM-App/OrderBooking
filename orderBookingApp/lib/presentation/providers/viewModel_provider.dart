
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/usecase_provider.dart';
import 'package:order_booking_app/presentation/viewModels/checkin_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/login_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/employee_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/network_model.dart';
import 'package:order_booking_app/presentation/viewModels/addRegion_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/product_details.viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/shop_viewmodel.dart';



final networkStateProvider =
    StateNotifierProvider<EnhancedNetworkStateNotifier, NetworkState>(
        (ref) => EnhancedNetworkStateNotifier());


final employeeloginViewModelProvider =
    StateNotifierProvider<EmployeeloginViewModel, EmployeeloginState>((ref) {
  final usecase = ref.watch(employeeloginUsecaseProvider);
  return EmployeeloginViewModel(usecase);
});

final adminloginViewModelProvider =
    StateNotifierProvider<AdminloginViewModel, AdminloginState>((ref) {
  final usecase = ref.watch(adminloginUsecaseProvider);
  return AdminloginViewModel(usecase);
});

final regionViewModelProvider =
    StateNotifierProvider<RegionViewModel, RegionState>((ref) {
  final usecase = ref.watch(regionUsecaseProvider);
  return RegionViewModel(usecase);
});

final shopViewModelProvider =
    StateNotifierProvider<ShopViewModel, ShopState>((ref) {
  final usecase = ref.watch(addShopUsecaseProvider);
  return ShopViewModel(usecase);
});

final checkInViewModelProvider =
    StateNotifierProvider<CheckinViewmodel, CheckinState>((ref) {
      final usecase = ref.watch(checkInUsecaseProvider);
  return CheckinViewmodel(usecase);
});

final productViewModelProvider =
    StateNotifierProvider<ProductViewModel, ProductState>((ref) {
  final usecase = ref.read(getProductListUseCaseProvider);
  const adminId =1 ;
  return ProductViewModel(usecase, adminId );
});
