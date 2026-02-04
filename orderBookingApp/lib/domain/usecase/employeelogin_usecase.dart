import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/repository/employee_repo.dart';

class EmployeeloginUsecase {
  final EmployeeloginRepository employeeloginRepository;

  EmployeeloginUsecase(this.employeeloginRepository);

  Future<dynamic> addEmployee(EmployeeLogin employeeLogin) {
    return employeeloginRepository.addEmployee(employeeLogin);
  }

  Future<List<EmployeeLogin>> getEmployeeList(String companyId) {
    return employeeloginRepository.getEmployeeList(companyId);
  }

  Future<List<EmployeeLogin>> fetchEmployeeDetails(int empId) {
    return employeeloginRepository.fetchEmployeeDetails(empId);
  }

  Future<List<EmployeeLogin>> fetchEmployeeInfo(String mobileNo) {
    return employeeloginRepository.fetchEmployeeInfo(mobileNo);
  }

  Future<EmployeeLogin> deleteEmployee(int empId) {
    return employeeloginRepository.deleteEmployee(empId);
  }
}
