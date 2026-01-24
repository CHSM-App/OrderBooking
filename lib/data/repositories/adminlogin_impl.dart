 
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/admin_login.dart';
import 'package:order_booking_app/domain/models/login_info.dart';

import 'package:order_booking_app/domain/repository/adminlogin_repo.dart';


class AdminloginImpl implements AdminloginRepository {
  final ApiService apiService;

  AdminloginImpl(this.apiService);

  @override
  Future<dynamic> addAdminDetails(AdminLogin adminLogin) {
    return apiService.addAdminDetails(adminLogin);
  }
     @override
  Future<List<AdminLogin>> fetchAdminDetails(String mobileNo) {
    return apiService.fetchAdminDetails(mobileNo);
  }
    @override
  Future<List<LoginInfo>> checkPhoneNumber(String mobile_no) async {
    return apiService.CheckPhone(mobile_no);
  }
}