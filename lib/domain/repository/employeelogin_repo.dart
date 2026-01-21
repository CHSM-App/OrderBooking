import 'package:order_booking_app/domain/models/employee_login.dart';

import '../models/token_response.dart';

abstract class EmployeeloginRepository {

  Future<dynamic> addEmployee(EmployeeLogin employeeLogin);

Future<List<EmployeeLogin>>getEmployeeList();

Future<List<EmployeeLogin>>fetchEmployeeDetails(int empId);
}
