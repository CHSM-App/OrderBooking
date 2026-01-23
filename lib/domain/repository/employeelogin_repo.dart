import 'package:order_booking_app/domain/models/employee_login.dart';


abstract class EmployeeloginRepository {

  Future<dynamic> addEmployee(EmployeeLogin employeeLogin);

Future<List<EmployeeLogin>>getEmployeeList();

Future<List<EmployeeLogin>>fetchEmployeeDetails(int empId);
  Future<List<EmployeeLogin>>fetchEmployeeInfo(String mobileNo);
}
