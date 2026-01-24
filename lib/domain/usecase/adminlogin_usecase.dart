import 'package:order_booking_app/domain/models/admin_login.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/repository/adminlogin_repo.dart';


class AdminloginUsecase {
  final AdminloginRepository adminloginRepository;

  AdminloginUsecase(this.adminloginRepository);

  Future<dynamic> addAdminDetails(AdminLogin adminLogin) {
    return adminloginRepository.addAdminDetails(adminLogin);
  }
      Future<List<AdminLogin>>fetchAdminDetails(String mobileNo){
    return adminloginRepository.fetchAdminDetails(mobileNo);
  }
    Future<List<LoginInfo>> checkPhoneNumber(String mobileNo) {
    return adminloginRepository.checkPhoneNumber(mobileNo);
  }

}