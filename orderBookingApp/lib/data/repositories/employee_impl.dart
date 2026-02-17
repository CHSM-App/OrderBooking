import 'dart:io';

import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/domain/models/visite.dart';

import 'package:order_booking_app/domain/repository/employee_repo.dart';

class EmployeeloginImpl implements EmployeeloginRepository {
  final ApiService apiService;

  EmployeeloginImpl(this.apiService);

  @override
  Future<dynamic> addEmployee(EmployeeLogin employeeLogin) {
    return apiService.addEmployee(employeeLogin);
  }

  @override
  Future<List<EmployeeLogin>> getEmployeeList(String companyId) {
    return apiService.getEmployeeList(companyId);
  }

  @override
  Future<List<EmployeeLogin>> fetchEmployeeDetails(int empId) {
    return apiService.fetchEmployeeDetails(empId);
  }

  @override
  Future<List<EmployeeLogin>> fetchEmployeeInfo(String mobileNo) {
    return apiService.fetchEmployeeInfo(mobileNo);
  }

  @override
  Future<EmployeeLogin> deleteEmployee(int empId) {
    return apiService.deleteEmployee(empId);
  }

  @override
  Future<dynamic> checkMobileExists(String mobileNo, String companyId) {
    return apiService.checkMobileExists(mobileNo, companyId);
  }

  @override
  Future<List<VisitPayload>> getEmployeeVisit(int empId) {
    return apiService.getEmployeeVisit(empId);
  }

  @override
  Future uploadEmployeeIdProof(File image, String empId) {
    return apiService.uploadEmployeeIdProof(image, empId);
  }

  @override
  Future<List<EmployeeVisit>> getEmployeeVisitLocation(int empId) {
    return apiService.getEmployeeVisitLocation(empId);
  }

   @override
  Future<List<AttendanceReport>> getAttendanceReport(String companyId) {
    return apiService.getAttendanceReport(companyId);
  }
}
