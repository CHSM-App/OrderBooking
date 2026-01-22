import 'package:order_booking_app/domain/models/admin_login.dart';
import 'package:order_booking_app/domain/repository/adminlogin_repo.dart';


class AdminloginUsecase {
  final AdminloginRepository adminloginRepository;

  AdminloginUsecase(this.adminloginRepository);

  Future<dynamic> addAdminDetails(AdminLogin adminLogin) {
    return adminloginRepository.addAdminDetails(adminLogin);
  }
  
}