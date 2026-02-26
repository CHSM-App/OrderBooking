import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/employeeMap.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/domain/usecase/employeelogin_usecase.dart';

/// =======================
/// STATE
/// =======================
class EmployeeloginState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<EmployeeLogin>> employeeList;
  final AsyncValue<List<EmployeeLogin>> employeeDetails;
  final AsyncValue<List<EmployeeMap>> employeeMapData;
  final AsyncValue<List<EmployeeVisit>> employeeVisitLocation;
  final AsyncValue<List<AttendanceReport>> attendanceReport;

  final int? empId;
  final String? companyId;
  final bool? isPhoneNoExists;
  final bool? mobileNoStatus;

  const EmployeeloginState({
    this.employeeVisitLocation = const AsyncValue.loading(),
    this.isLoading = false,
    this.error,
    this.empId,
    this.companyId,
    this.isPhoneNoExists,
    this.mobileNoStatus,
    this.employeeList = const AsyncValue.loading(),
    this.employeeDetails = const AsyncValue.loading(),
    this.employeeMapData = const AsyncValue.loading(),
    this.attendanceReport = const AsyncValue.loading(),
  });

  EmployeeloginState copyWith({
    bool? isPhoneNoExists,
    bool? mobileNoStatus,
    bool? isLoading,
    bool clearError = false,
    String? error,
    AsyncValue<List<EmployeeLogin>>? employeeList,
    AsyncValue<List<EmployeeLogin>>? employeeDetails,
    AsyncValue<List<EmployeeMap>>? employeeMapData,
    AsyncValue<List<EmployeeVisit>>? employeeVisitLocation,
    AsyncValue<List<AttendanceReport>>? attendanceReport,
    String? companyId,
    int? empId,
  }) {
    return EmployeeloginState(
      employeeVisitLocation:
          employeeVisitLocation ?? this.employeeVisitLocation,
      isLoading: isLoading ?? this.isLoading,
      isPhoneNoExists: isPhoneNoExists ?? this.isPhoneNoExists,
      mobileNoStatus: mobileNoStatus ?? this.mobileNoStatus,
      error: clearError ? null : (error ?? this.error),
      employeeList: employeeList ?? this.employeeList,
      employeeDetails: employeeDetails ?? this.employeeDetails,
      employeeMapData: employeeMapData ?? this.employeeMapData,
      attendanceReport: attendanceReport ?? this.attendanceReport,
      companyId: companyId ?? this.companyId,
      empId: empId ?? this.empId,
    );
  }
}

/// =======================
/// VIEWMODEL
/// =======================
class EmployeeloginViewModel extends StateNotifier<EmployeeloginState> {
  final EmployeeloginUsecase usecase;

  EmployeeloginViewModel(this.usecase) : super(const EmployeeloginState());

  Future<int> addEmployee(EmployeeLogin employeeLogin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await usecase.addEmployee(employeeLogin);
      // Extract empId from response map
      final int newEmpId = response['emp_id'] as int;
      // Refresh employee list
      await getEmployeeList(employeeLogin.companyId!);
      state = state.copyWith(isLoading: false);
      return newEmpId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> uploadEmployeeIdProof(File image, int empId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await usecase.uploadEmployeeIdProof(image, empId.toString());
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// -----------------------
  /// GET EMPLOYEE LIST
  /// -----------------------
  Future<void> getEmployeeList(
    String companyId, {
    bool useCacheFirst = true,
  }) async {
    var hasCached = false;
    if (useCacheFirst) {
      final cached = state.employeeList.value;
      if (cached != null && cached.isNotEmpty) {
        hasCached = true;
        state = state.copyWith(isLoading: false, clearError: true);
      }
    }

    state = state.copyWith(
      isLoading: !hasCached,
      clearError: true,
      employeeList: hasCached ? state.employeeList : const AsyncValue.loading(),
    );
    try {
      final employees = await usecase.getEmployeeList(companyId);
      state = state.copyWith(
        isLoading: false,
        employeeList: AsyncValue.data(employees),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: hasCached ? null : e.toString(),
        employeeList: hasCached
            ? state.employeeList
            : AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  Future<void> fetchEmployeeDetails(int empId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      employeeDetails: const AsyncValue.loading(),
    );
    try {
      final details = await usecase.fetchEmployeeDetails(empId);
      state = state.copyWith(
        isLoading: false,
        employeeDetails: AsyncValue.data(details),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        employeeDetails: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  Future<void> fetchEmployeeInfo(String mobile) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await usecase.fetchEmployeeInfo(mobile);
      state = state.copyWith(
        isLoading: false,
        employeeDetails: AsyncData(response),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// DELETE EMPLOYEE
  Future<void> deleteEmployee(int empId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await usecase.deleteEmployee(empId);

      state = state.copyWith(employeeDetails: const AsyncValue.data([]));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  //check weather mobile number already exists in table
  Future<void> checkMobileExists(
    String mobileNo,
    String companyId,
    int empId,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isPhoneNoExists: null,
      mobileNoStatus: null,
    );

    try {
      final exists = await usecase.checkMobileExists(
        mobileNo,
        companyId,
        empId,
      );

      state = state.copyWith(
        isLoading: false,
        isPhoneNoExists: exists['exists'],
        mobileNoStatus: exists['status'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isPhoneNoExists: false,
        mobileNoStatus: false,
      );
    }
  }

  //will use this for map
  Future<void> getEmployeeVisit(int empId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final employees = await usecase.getEmployeeVisit(empId);

      state = state.copyWith(
        isLoading: false,
        employeeMapData: AsyncValue.data(employees),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        employeeMapData: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  Future<void> getEmployeeVisitLocation(int empId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final employees = await usecase.getEmployeeVisitLocation(empId);

      state = state.copyWith(
        isLoading: false,
        employeeVisitLocation: AsyncValue.data(employees),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        employeeVisitLocation: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  Future<void> getAttendanceReport(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employeesReport = await usecase.getAttendanceReport(companyId);

      state = state.copyWith(
        isLoading: false,
        attendanceReport: AsyncValue.data(employeesReport),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        attendanceReport: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  void resetPhoneExistStatus() {
    state = state.copyWith(isPhoneNoExists: null);
  }

  void setNull() {
    state = state.copyWith(isPhoneNoExists: null, mobileNoStatus: null);
  }
}
