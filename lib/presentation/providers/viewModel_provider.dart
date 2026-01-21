import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/usecase_provider.dart';
import 'package:order_booking_app/presentation/viewModels/employeelogin_viewmodel.dart';
import 'package:order_booking_app/presentation/viewModels/network_model.dart';

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


