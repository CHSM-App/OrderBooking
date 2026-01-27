import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/dio_provider.dart';
import 'package:order_booking_app/data/api/api_service.dart';

import 'package:order_booking_app/data/repositories/shop_impl.dart';
import 'package:order_booking_app/data/repositories/login_impl.dart';
import 'package:order_booking_app/data/repositories/auth_impl.dart';
import 'package:order_booking_app/data/repositories/employee_impl.dart';

import 'package:order_booking_app/domain/repository/shop_repo.dart';
import 'package:order_booking_app/domain/repository/login_repo.dart';
import 'package:order_booking_app/domain/repository/auth_repo.dart';
import 'package:order_booking_app/domain/repository/employee_repo.dart';
import 'package:order_booking_app/domain/repository/region_repo.dart';
import 'package:order_booking_app/data/repositories/region_impl.dart';

//Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return AuthImpl(api);
});

//Employeelogin Repository
final employeeloginRepositoryProvider = Provider<EmployeeloginRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return EmployeeloginImpl(api);
});

//Adminlogin Repository 
//Employeelogin Repository
final adminloginRepositoryProvider = Provider<AdminloginRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return AdminloginImpl(api);
});

final regionRepositoryProvider = Provider<RegionRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return RegionImpl(api);
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return ShopImpl(api);
});






