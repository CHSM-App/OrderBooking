import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee_login.dart';
import 'package:order_booking_app/domain/usecase/employeelogin_usecase.dart';


class EmployeeloginState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<EmployeeLogin>>? employeeList;
  final AsyncValue<List<EmployeeLogin>>? employeeDetails;
  
  const EmployeeloginState({
    this.isLoading = false,
    this.error,
    this.employeeList = const AsyncValue.loading(),
    this.employeeDetails = const AsyncValue.loading(),
  });

  EmployeeloginState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<List<EmployeeLogin>>? employeeList,
    AsyncValue<List<EmployeeLogin>>? employeeDetails,
  }) {
    return EmployeeloginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      employeeList: employeeList ?? this.employeeList,
      employeeDetails: employeeDetails ?? this.employeeDetails,
    );
  }
}

class EmployeeloginViewModel extends StateNotifier<EmployeeloginState> {
  final EmployeeloginUsecase usecase;
  EmployeeloginViewModel(this.usecase) : super(const EmployeeloginState());

  // EXISTING: Add Employee
  Future<void> addEmployee(EmployeeLogin employeeLogin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addEmployee(employeeLogin);
      state = state.copyWith(isLoading: false);
      // Refresh employee list after adding
      getEmployeeList();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // EXISTING: Get Employee List
  Future<void> getEmployeeList() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await usecase.getEmployeeList();
      state = state.copyWith(
        isLoading: false,
        employeeList: AsyncValue.data(employees),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // EXISTING: Fetch Employee Details
  Future<void> fetchEmployeeDetails(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employeedetails = await usecase.fetchEmployeeDetails(empId);
      state = state.copyWith(
        isLoading: false,
        employeeDetails: AsyncValue.data(employeedetails),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // NEW: Update Employee
  Future<void> updateEmployee(EmployeeLogin employeeLogin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.updateEmployee(employeeLogin);
      state = state.copyWith(isLoading: false);
      // Refresh employee list after updating
      getEmployeeList();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // NEW: Delete Employee
  Future<void> deleteEmployee(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.deleteEmployee(empId);
      state = state.copyWith(isLoading: false);
      // Refresh employee list after deleting
      getEmployeeList();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}