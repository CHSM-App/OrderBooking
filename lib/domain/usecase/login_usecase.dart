import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/repository/login_repo.dart';


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

  Future<void> logOut(String refreshToken) async {
    adminloginRepository.logoutUser(refreshToken);
  }

}