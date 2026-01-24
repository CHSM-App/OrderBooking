 
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/employee_login.dart';

import 'package:order_booking_app/domain/repository/employeelogin_repo.dart';

class EmployeeloginImpl implements EmployeeloginRepository {
  final ApiService apiService;

  EmployeeloginImpl(this.apiService);

  @override
  Future<dynamic> addEmployee(EmployeeLogin employeeLogin) {
    return apiService.addEmployee(employeeLogin);
  }
  @override
  Future<List<EmployeeLogin>> getEmployeeList() {
    return apiService.getEmployeeList();
  }
    @override
  Future<List<EmployeeLogin>> fetchEmployeeDetails(int empId) {
    return apiService.fetchEmployeeDetails(empId);
  }
      @override
  Future<List<EmployeeLogin>> fetchEmployeeInfo(String mobileNo) {
    return apiService.fetchEmployeeInfo(mobileNo);
  }
}