import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/repository/employee_repo.dart';

class EmployeeloginUsecase {
  final EmployeeloginRepository employeeloginRepository;

  EmployeeloginUsecase(this.employeeloginRepository);

  Future<dynamic> addEmployee(EmployeeLogin employeeLogin) {
    return employeeloginRepository.addEmployee(employeeLogin);
  }
  Future<List<EmployeeLogin>>getEmployeeList(){
    return employeeloginRepository.getEmployeeList();
  }
    Future<List<EmployeeLogin>>fetchEmployeeDetails(int empId){
    return employeeloginRepository.fetchEmployeeDetails(empId);
  }

 
  Future<void> updateEmployee(EmployeeLogin employeeLogin) async {}

  Future<void> deleteEmployee(int empId) async {}
}