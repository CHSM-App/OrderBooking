import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/models/otp_response.dart';
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

  Future<dynamic> addUpdateAdmin(AdminLogin admin){
    return adminloginRepository.addUpdateAdmin(admin);
  }

  Future<List<AdminLogin>> fetchAdmins(String companyId) {
     return adminloginRepository.fetchAdmins(companyId);
  }

  Future<dynamic> deleteAdmin(int adminId){
    return adminloginRepository.deleteAdmin(adminId);
  }

  Future<OtpResponse> sendOtp(OtpResponse payload) {
    return adminloginRepository.sendOtp(payload);
  }

  Future<OtpResponse> verifyOtp(OtpResponse payload) {
    return adminloginRepository.verifyOtp(payload);
  }

}