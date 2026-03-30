import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/models/otp_response.dart';

abstract class AdminloginRepository {

  Future<dynamic> addAdminDetails(AdminLogin adminLogin);
  Future<List<AdminLogin>>fetchAdminDetails(String mobileNo);
   Future<List<LoginInfo>> checkPhoneNumber(String mobile_no);
   Future<void> logoutUser(String refreshToken);

   Future<dynamic> addUpdateAdmin(AdminLogin admin);

  Future<List<AdminLogin>> fetchAdmins(String companyId);

  Future<dynamic> deleteAdmin(int adminId);

  //send otp
    Future<OtpResponse> sendOtp(OtpResponse payload);
  Future<OtpResponse> verifyOtp(OtpResponse payload);

}
