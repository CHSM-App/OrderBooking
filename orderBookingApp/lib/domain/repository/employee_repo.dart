import 'package:order_booking_app/domain/models/employee.dart';

abstract class EmployeeloginRepository {
  Future<dynamic> addEmployee(EmployeeLogin employeeLogin);

  Future<List<EmployeeLogin>> getEmployeeList();

  Future<List<EmployeeLogin>> fetchEmployeeDetails(int empId);

  Future<List<EmployeeLogin>> fetchEmployeeInfo(String mobileNo);

  Future<EmployeeLogin> deleteEmployee(int empId);
}
