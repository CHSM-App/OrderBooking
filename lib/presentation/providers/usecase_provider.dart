import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/usecase/auth_usecase.dart';
import 'package:order_booking_app/domain/usecase/employeelogin_usecase.dart';
import 'package:order_booking_app/presentation/providers/repository_provider.dart';

final authUsecaseProvider = Provider<AuthUsecase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthUsecase(authRepo);
});
final employeeloginUsecaseProvider=Provider<EmployeeloginUsecase>((ref){
  final employeeloginRepo=ref.watch(employeeloginRepositoryProvider);
  return EmployeeloginUsecase(employeeloginRepo);
});
