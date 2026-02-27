import 'dart:io';

import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/employee_dao.dart';
import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/employeeMap.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';

import 'package:order_booking_app/domain/repository/employee_repo.dart';

class EmployeeloginImpl implements EmployeeloginRepository {
  final ApiService apiService;
  final EmployeeDao employeeDao;

  EmployeeloginImpl(this.apiService, this.employeeDao);

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
Future<List<EmployeeLogin>> fetchEmployeeInfo(String mobileNo) async {
  try {
    final response = await apiService.fetchEmployeeInfo(mobileNo);

    if (response.isNotEmpty) {
      // Save first employee offline
      await employeeDao.insertOrReplace(response.first);

      return response; // Return API list
    }
  } catch (e) {
    print("API failed, loading offline data");
  }

  // If API fails → get from offline
  final offlineEmployee = await employeeDao.getEmployee();

  if (offlineEmployee != null) {
    return [offlineEmployee]; // Wrap into list
  }

  return []; // No data at all
}



  @override
  Future<EmployeeLogin> deleteEmployee(int empId) {
    return apiService.deleteEmployee(empId);
  }

  @override
  Future<dynamic> checkMobileExists(String mobileNo, String companyId, int empId) {
    return apiService.checkMobileExists(mobileNo, companyId, empId);
  }

  @override
  Future<List<EmployeeMap>> getEmployeeVisit(int empId) {
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
