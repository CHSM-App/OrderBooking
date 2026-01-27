import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/usecase_provider.dart';
import 'package:order_booking_app/presentation/viewModels/adminlogin_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/employeelogin_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/network_model.dart';
import 'package:order_booking_app/presentation/viewModels/addRegion_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/shop_viewmodel.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

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