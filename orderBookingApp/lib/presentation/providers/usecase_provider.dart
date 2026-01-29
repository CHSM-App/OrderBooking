import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/usecase/checkin_usecase.dart';
import 'package:order_booking_app/domain/usecase/login_usecase.dart';
import 'package:order_booking_app/domain/usecase/auth_usecase.dart';
import 'package:order_booking_app/domain/usecase/employeelogin_usecase.dart';

import 'package:order_booking_app/domain/usecase/product_usecase.dart';

import 'package:order_booking_app/domain/usecase/shop_usecase.dart';
import 'package:order_booking_app/domain/usecase/shop_visit.dart';
import 'package:order_booking_app/presentation/providers/repository_provider.dart';
import 'package:order_booking_app/domain/usecase/add_region_usecase.dart';

final authUsecaseProvider = Provider<AuthUsecase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthUsecase(authRepo);
});

final employeeloginUsecaseProvider=Provider<EmployeeloginUsecase>((ref){
  final employeeloginRepo=ref.watch(employeeloginRepositoryProvider);
  return EmployeeloginUsecase(employeeloginRepo);
});

final adminloginUsecaseProvider=Provider<AdminloginUsecase>((ref){
  final adminloginRepo=ref.watch(adminloginRepositoryProvider);
  return AdminloginUsecase(adminloginRepo);
});

final regionUsecaseProvider=Provider<AddRegionUsecase>((ref){
  final regionRepo=ref.watch(regionRepositoryProvider);
  return AddRegionUsecase(regionRepo);
});

final addShopUsecaseProvider=Provider<ShopUsecase>((ref){
  final shopRepo=ref.watch(shopRepositoryProvider);
  return ShopUsecase(shopRepo);});

final checkInUsecaseProvider=Provider<CheckinUsecase>((ref){
  final checkInRepo=ref.watch(checkInRepositoryProvider);
  return CheckinUsecase(checkInRepo);});
  
final productUsecaseProvider=Provider<ProductUsecase>((ref){
  final productRepo=ref.watch(productRepositoryProvider);
  return ProductUsecase(productRepo);});


final visitUseCaseProvider = Provider<VisitUseCase>((ref) {
  final visitRepo = ref.watch(visitRepositoryProvider);
  return VisitUseCase(visitRepo);
});