import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/dio_provider.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/repositories/adminlogin_impl.dart';
import 'package:order_booking_app/data/repositories/auth_impl.dart';
import 'package:order_booking_app/data/repositories/employeelogin_impl.dart';
import 'package:order_booking_app/domain/repository/adminlogin_repo.dart';
import 'package:order_booking_app/domain/repository/auth_repo.dart';
import 'package:order_booking_app/domain/repository/employeelogin_repo.dart';

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





