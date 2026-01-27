 
import 'package:dio/dio.dart';
import 'package:order_booking_app/core/storage/token_storage.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';

import 'package:order_booking_app/domain/repository/login_repo.dart';


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
    final response =  await apiService.CheckPhone(mobile_no);

        if (response.isNotEmpty) {
      // Save values in secure storage

      await TokenStorage.saveValue('user_id', response[0].userId.toString());
      await TokenStorage.saveValue('name', response[0].name.toString());
      await TokenStorage.saveValue('mobile_no', response[0].mobileNo.toString());
      await TokenStorage.saveValue('email', response[0].email.toString());
      await TokenStorage.saveValue('role_id', response[0].roleId.toString());
      await TokenStorage.saveValue('company_name', response[0].companyName.toString());
      await TokenStorage.saveValue('token', response[0].Token.toString());
      await TokenStorage.saveValue('isCheckedIn', response[0].isCheckedIn.toString());
    }
    return response;
  }
}