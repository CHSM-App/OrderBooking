import 'dart:io';

import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/employeeMap.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
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

  Future<dynamic> checkMobileExists(String mobileNo, String companyId, int empId) async {
      return employeeloginRepository.checkMobileExists(mobileNo, companyId, empId);
  }

  Future<List<EmployeeMap>> getEmployeeVisit(int empId) async {
      return employeeloginRepository.getEmployeeVisit(empId);
  }
  Future<List<EmployeeVisit>> getEmployeeVisitLocation(int empId) async {
      return employeeloginRepository.getEmployeeVisitLocation(empId);
  }
    Future<dynamic> uploadEmployeeIdProof(File image, String empId) {
    return employeeloginRepository.uploadEmployeeIdProof(image, empId);
  }

  Future<List<AttendanceReport>> getAttendanceReport(String companyId)  {
    return employeeloginRepository.getAttendanceReport(companyId);
  }
}
