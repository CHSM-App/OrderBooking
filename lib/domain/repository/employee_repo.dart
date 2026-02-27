import 'dart:io';

import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/employeeMap.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';

abstract class EmployeeloginRepository {
  Future<dynamic> addEmployee(EmployeeLogin employeeLogin);

  Future<List<EmployeeLogin>> getEmployeeList(String companyId);

  Future<List<EmployeeLogin>> fetchEmployeeDetails(int empId);

  Future<List<EmployeeLogin>> fetchEmployeeInfo(String mobileNo);

  Future<EmployeeLogin> deleteEmployee(int empId);

   Future<dynamic> checkMobileExists(String mobileNo, String companyId, int empId);

  Future<List<EmployeeMap>> getEmployeeVisit(int empId);
  
  Future<List<EmployeeVisit>> getEmployeeVisitLocation(int empId);

   Future<dynamic> uploadEmployeeIdProof(File image, String empId);

  Future<List<AttendanceReport>> getAttendanceReport(String companyId);
   
}
