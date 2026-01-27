import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';

abstract class AdminloginRepository {

  Future<dynamic> addAdminDetails(AdminLogin adminLogin);
  Future<List<AdminLogin>>fetchAdminDetails(String mobileNo);
   Future<List<LoginInfo>> checkPhoneNumber(String mobile_no);

}
