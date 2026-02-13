
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/dio_provider.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/logout_dao.dart';
import 'package:order_booking_app/data/local/offline_order_dao.dart';
import 'package:order_booking_app/data/local/offline_region_dao.dart';
import 'package:order_booking_app/data/local/offline_visit_dao.dart';
import 'package:order_booking_app/data/local/product_dao.dart';
import 'package:order_booking_app/data/local/shop_dao.dart';
import 'package:order_booking_app/data/repositories/checkin_status_impl.dart';
import 'package:order_booking_app/data/repositories/orders_impl.dart';
import 'package:order_booking_app/data/repositories/product_impl.dart';
import 'package:order_booking_app/data/repositories/region_impl.dart';


import 'package:order_booking_app/data/repositories/shop_impl.dart';
import 'package:order_booking_app/data/repositories/login_impl.dart';
import 'package:order_booking_app/data/repositories/auth_impl.dart';
import 'package:order_booking_app/data/repositories/employee_impl.dart';
import 'package:order_booking_app/data/repositories/shot_visit.dart';
import 'package:order_booking_app/domain/repository/checkin_repo.dart';
import 'package:order_booking_app/domain/repository/orders_repo.dart';
import 'package:order_booking_app/domain/repository/product_repo.dart';
import 'package:order_booking_app/domain/repository/region.dart';


import 'package:order_booking_app/domain/repository/shop_repo.dart';
import 'package:order_booking_app/domain/repository/login_repo.dart';
import 'package:order_booking_app/domain/repository/auth_repo.dart';
import 'package:order_booking_app/domain/repository/employee_repo.dart';
import 'package:order_booking_app/domain/repository/shop_visit.dart';


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
  final local = LogoutDao();
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return AdminloginImpl(api, local);
});


final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  final local = ShopDao();
  return ShopImpl(api, local);
});

final checkInRepositoryProvider = Provider<CheckinRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return CheckinStatusRequestImpl(api);
});




final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  final local = ProductDao();
  return ProductImpl(api, local);
});

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);  
  final  local = OfflineVisitDao();
  return VisitImpl(
    local: local,
    apiService: api,
  );
});


final regionRepositorofflineProvider = Provider<RegionRepooffline>((ref) {
 final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  final local = OfflineRegionDao();
  return RegionImplOffline(api, local);
    
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  final local = OfflineOrderDao();
  return OrdersRepositoryImpl(api, local);
});