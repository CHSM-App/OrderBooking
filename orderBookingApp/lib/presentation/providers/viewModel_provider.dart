
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/network_service.dart';
import 'package:order_booking_app/presentation/providers/usecase_provider.dart';
import 'package:order_booking_app/presentation/viewModels/checkin_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/login_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/employee_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/network_model.dart';
import 'package:order_booking_app/presentation/viewModels/orders_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/product_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/region_viewmodel.dart';

import 'package:order_booking_app/presentation/viewModels/shop_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/shop_visit.dart';

final networkServiceProvider = Provider((ref) => NetworkService());

final networkStateProvider =
    StateNotifierProvider<EnhancedNetworkStateNotifier, NetworkState>(
        (ref) => EnhancedNetworkStateNotifier());


final networkStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.onConnectivityChanged;
});


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
  final usecase = ref.watch(productUsecaseProvider);
  return ProductViewModel(usecase);
});

final visitViewModelProvider =
    StateNotifierProvider<VisitViewModel, EmployeeVisitState>((ref) {
  final usecase = ref.watch(visitUseCaseProvider);
  return VisitViewModel(usecase);
});


final regionofflineViewModelProvider =
    StateNotifierProvider<RegionofflineViewModel, RegionState>((ref) {
  final usecase = ref.watch(regionUseCaseofflineProvider);
  return RegionofflineViewModel(usecase);
});

final ordersViewModelProvider =
    StateNotifierProvider<ordersStateNotifier, ordersState>((ref) {
  final usecase = ref.watch(ordersUsecaseProvider);
  return ordersStateNotifier(usecase);
});

final EmployeeOrderViewModelProvider =
    StateNotifierProvider.family<
        ordersStateNotifier,
        ordersState,
        int>((ref, empId) {
  final usecase = ref.watch(ordersUsecaseProvider);
  return ordersStateNotifier(usecase)..getEmployeeOrders(empId);
});
