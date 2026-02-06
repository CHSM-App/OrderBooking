// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:order_booking_app/domain/models/employee.dart';
// import 'package:order_booking_app/domain/usecase/employeelogin_usecase.dart';

// class EmployeeloginState {
//   final bool isLoading;
//   final String? error;
//   final AsyncValue<List<EmployeeLogin>>? employeeList;
//   final AsyncValue<List<EmployeeLogin>>? employeeDetails;
//   final String? companyId;

//   const EmployeeloginState({
//     this.isLoading = false,
//     this.companyId,
//     this.error,
//     this.employeeList = const AsyncValue.loading(),
//     this.employeeDetails = const AsyncValue.loading(),
//   });

//   EmployeeloginState copyWith({
//     bool? isLoading,
//     String? error,
//     AsyncValue<List<EmployeeLogin>>? employeeList,
//     AsyncValue<List<EmployeeLogin>>? employeeDetails,
//   }) {
//     return EmployeeloginState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       employeeList: employeeList ?? this.employeeList,
//       employeeDetails: employeeDetails ?? this.employeeDetails,
//     );
//   }
// }

// class EmployeeloginViewModel extends StateNotifier<EmployeeloginState> {
//   final EmployeeloginUsecase usecase;

//   var companyId;
//   EmployeeloginViewModel(this.usecase) : super(const EmployeeloginState());

//   // EXISTING: Add Employee
//   Future<void> addEmployee(EmployeeLogin employeeLogin) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       await usecase.addEmployee(employeeLogin);
//       state = state.copyWith(isLoading: false);
//       // Refresh employee list after adding
//       getEmployeeList(companyId);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   // EXISTING: Get Employee List
//   Future<void> getEmployeeList(String companyId) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final employees = await usecase.getEmployeeList(companyId);
//       state = state.copyWith(
//         isLoading: false,
//         employeeList: AsyncValue.data(employees),
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   // EXISTING: Fetch Employee Details
//   Future<void> fetchEmployeeDetails(int empId) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final employeedetails = await usecase.fetchEmployeeDetails(empId);
//       state = state.copyWith(
//         isLoading: false,
//         employeeDetails: AsyncValue.data(employeedetails),
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

  
//   Future<void> fetchEmployeeInfo(String mobileNo) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final employeedetails = await usecase.fetchEmployeeInfo(mobileNo);
//       state = state.copyWith(
//         isLoading: false,
//         employeeDetails: AsyncValue.data(employeedetails),
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

  
//   Future<void> deleteEmployee(int empId) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       await usecase.deleteEmployee(empId);

//       // ✅ Clear stale employee details so nothing tries to re-fetch the deleted ID
//       state = state.copyWith(employeeDetails: null);

//       // ✅ Refresh the list (this already sets isLoading: false internally)
//       await getEmployeeList(companyId);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/usecase/employeelogin_usecase.dart';

/// =======================
/// STATE
/// =======================
class EmployeeloginState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<EmployeeLogin>> employeeList;
  final AsyncValue<List<EmployeeLogin>> employeeDetails;
  final String? companyId;

  const EmployeeloginState({
    this.isLoading = false,
    this.error,
    this.companyId,
    this.employeeList = const AsyncValue.data([]),
    this.employeeDetails = const AsyncValue.data([]),
  });

  EmployeeloginState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<List<EmployeeLogin>>? employeeList,
    AsyncValue<List<EmployeeLogin>>? employeeDetails,
    String? companyId,
  }) {
    return EmployeeloginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      employeeList: employeeList ?? this.employeeList,
      employeeDetails: employeeDetails ?? this.employeeDetails,
      companyId: companyId ?? this.companyId,
    );
  }
}

/// =======================
/// VIEWMODEL
/// =======================
class EmployeeloginViewModel extends StateNotifier<EmployeeloginState> {
  final EmployeeloginUsecase usecase;

  EmployeeloginViewModel(this.usecase)
      : super(const EmployeeloginState());

  /// -----------------------
  /// SET COMPANY ID
  /// -----------------------
  void setCompanyId(String id) {
    state = state.copyWith(companyId: id);
  }

  /// -----------------------
  /// ADD EMPLOYEE
  /// -----------------------
  Future<void> addEmployee(EmployeeLogin employeeLogin) async {
    if (state.companyId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addEmployee(employeeLogin);

      // refresh list
      await getEmployeeList(state.companyId!);

      state = state.copyWith(isLoading: false);
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
    if (companyId.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      employeeList: const AsyncValue.loading(),
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
  debugPrint('🚀 fetchEmployeeInfo called');
  debugPrint('📞 Mobile param: $mobile');

  state = state.copyWith(isLoading: true, error: null);
  debugPrint('⏳ Loading TRUE');

  try {
    final response = await usecase.fetchEmployeeInfo(mobile);

    debugPrint('✅ API SUCCESS');
    debugPrint('📦 Response length: ${response.length}');
    debugPrint('📦 Response data: $response');

    state = state.copyWith(
      isLoading: false,
      employeeDetails: AsyncData(response),
    );

    debugPrint('⏳ Loading FALSE (success)');
  } catch (e, stack) {
    debugPrint('❌ API ERROR: $e');
    debugPrint('🧵 STACK: $stack');

    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }
}


  /// -----------------------
  /// DELETE EMPLOYEE
  /// -----------------------
  Future<void> deleteEmployee(int empId) async {
    if (state.companyId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await usecase.deleteEmployee(empId);

      // ✅ CLEAR DETAILS SAFELY
      state = state.copyWith(
        employeeDetails: const AsyncValue.data([]),
      );

      await getEmployeeList(state.companyId!);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
