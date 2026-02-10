import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/domain/usecase/employeelogin_usecase.dart';

/// =======================
/// STATE
/// =======================
class EmployeeloginState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<EmployeeLogin>> employeeList;
  final AsyncValue<List<EmployeeLogin>> employeeDetails;
  final AsyncValue<List<VisitPayload>> employeeVisits;

  final String? companyId;
  final bool? isPhoneNoExists;

  const EmployeeloginState({
    this.isLoading = false,
    this.error,
    this.companyId,
    this.isPhoneNoExists,
    this.employeeList = const AsyncValue.loading(),
    this.employeeDetails = const AsyncValue.loading(),
    this.employeeVisits = const AsyncValue.loading(),
  });

  EmployeeloginState copyWith({
    bool? isPhoneNoExists,
    bool? isLoading,
    String? error,
    AsyncValue<List<EmployeeLogin>>? employeeList,
    AsyncValue<List<EmployeeLogin>>? employeeDetails,
    AsyncValue<List<VisitPayload>>? employeeVisits,
    String? companyId,
  }) {
    return EmployeeloginState(
      isLoading: isLoading ?? this.isLoading,
      isPhoneNoExists: isPhoneNoExists ?? this.isPhoneNoExists,
      error: error ?? this.error,
      employeeList: employeeList ?? this.employeeList,
      employeeDetails: employeeDetails ?? this.employeeDetails,
      employeeVisits: employeeVisits ?? this.employeeVisits,
      companyId: companyId ?? this.companyId,
    );
  }
}

/// =======================
/// VIEWMODEL
/// =======================
class EmployeeloginViewModel extends StateNotifier<EmployeeloginState> {
  final EmployeeloginUsecase usecase;

  
  EmployeeloginViewModel(this.usecase) : super(const EmployeeloginState());
  




  // EXISTING: Add Employee
  Future<void> addEmployee(EmployeeLogin employeeLogin) async {
    if (state.companyId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addEmployee(employeeLogin);

      // refresh list
      await getEmployeeList(state.companyId!);

      state = state.copyWith(isLoading: false);
      // Refresh employee list after adding
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// -----------------------
  /// GET EMPLOYEE LIST
  /// -----------------------
  Future<void> getEmployeeList(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await usecase.getEmployeeList(companyId);

      state = state.copyWith(
        isLoading: false,
        employeeList: AsyncValue.data(employees),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        employeeList: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// -----------------------
  /// FETCH EMPLOYEE DETAILS BY ID
  /// -----------------------
  Future<void> fetchEmployeeDetails(int empId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
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

  /// -----------------------
  /// FETCH EMPLOYEE INFO (LOGIN / PROFILE)
  /// 🔥 FIXED FIRST-TIME ERROR
  Future<void> fetchEmployeeInfo(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await usecase.fetchEmployeeInfo(mobile);
      state = state.copyWith(
        isLoading: false,
        employeeDetails: AsyncData(response),
      );

      debugPrint('⏳ Loading FALSE (success)');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// DELETE EMPLOYEE
  Future<void> deleteEmployee(int empId) async {
    if (state.companyId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await usecase.deleteEmployee(empId);

      
      state = state.copyWith(
        employeeDetails: const AsyncValue.data([]),
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


  //check weather mobile number already exists in table
  Future<void> checkMobileExists(String mobileNo, String companyId) async {
    state = state.copyWith(isLoading: true, error: null,isPhoneNoExists: null );

    try {
      final exists = await usecase.checkMobileExists(
        mobileNo,
        companyId,
      );

      state = state.copyWith(isLoading: false, isPhoneNoExists: exists);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isPhoneNoExists: false,
      );
    }
}

Future<void> getEmployeeVisit(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await usecase.getEmployeeVisit(empId);
      for (var employee in employees){
        print(employee);
      }

      state = state.copyWith(
        isLoading: false,
        employeeVisits: AsyncValue.data(employees),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
         employeeVisits: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

}

