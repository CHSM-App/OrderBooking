import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/storage/token_storage.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/usecase/login_usecase.dart';

class AdminloginState {
  final bool isLoading;
  final String? error;
  final String? name;
  final String? mobileNo;
  final String? email;
  final String? roleId;
  final String? companyName;
  final String? token;
  final String? isCheckedIn;
  final String? companyId;

  final AsyncValue<List<AdminLogin>>? adminDetails;
  final AsyncValue<List<LoginInfo>> phoneCheckResult;
  final int userId;
  const AdminloginState({
    this.isLoading = false,
    this.error,
    this.adminDetails = const AsyncValue.loading(),
    this.phoneCheckResult = const AsyncValue.data([]),
    this.userId = 0,
    this.name,
    this.mobileNo,
    this.email,
    this.roleId,
    this.companyName,
    this.token,
    this.isCheckedIn,
    this.companyId,
  });

  AdminloginState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<List<AdminLogin>>? adminDetails,
    AsyncValue<List<LoginInfo>>? phoneCheckResult,
    int? userId,
    String? name,
    String? mobileNo,
    String? email,
    String? roleId,
    String? companyName,
    String? token,
    String? isCheckedIn,
    String? companyId,
  }) {
    return AdminloginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      adminDetails: adminDetails ?? this.adminDetails,
      phoneCheckResult: phoneCheckResult ?? this.phoneCheckResult,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      companyName: companyName ?? this.companyName,
      token: token ?? this.token,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
        companyId: companyId ?? this.companyId,
    );
  }
}

class AdminloginViewModel extends StateNotifier<AdminloginState> {
  final AdminloginUsecase usecase;

  var companyId;
  AdminloginViewModel(this.usecase) : super(const AdminloginState()) {
    // Initial fetch or setup can be done here if needed
    loadFromStorage();
  }
  Future<void> loadFromStorage() async {
    final name = await TokenStorage.getValue('name');
    final mobileNo = await TokenStorage.getValue('mobile_no');
    final email = await TokenStorage.getValue('email');
    final roleId = await TokenStorage.getValue('role_id');
    final companyName = await TokenStorage.getValue('company_name');
    final token = await TokenStorage.getValue('token');
    final isCheckedIn = await TokenStorage.getValue('isCheckedIn');
  final userIdStr = await TokenStorage.getValue('user_id');
  final userId = int.tryParse(userIdStr ?? '0') ?? 0;
     final companyId = await TokenStorage.getValue('company_id');
    state = state.copyWith(
          userId: userId,
      name: name,
      mobileNo: mobileNo,
      email: email,
      roleId: roleId,
      companyName: companyName,
      token: token,
      isCheckedIn: isCheckedIn,
      companyId: companyId,
      phoneCheckResult: AsyncValue.data([
        LoginInfo(
          name: name,
          mobileNo: mobileNo,
          email: email,
          roleId: roleId != null ? int.tryParse(roleId) : null,
          companyName: companyName,
          Token: token,
          isCheckedIn: isCheckedIn,
          companyId: companyId,
        ),
      ]),
    );
  }

  Future<void> addAdminDetails(AdminLogin adminLogin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addAdminDetails(adminLogin);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchAdminDetails(String mobileNo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final admindetails = await usecase.fetchAdminDetails(mobileNo);
      state = state.copyWith(
        isLoading: false,
        adminDetails: AsyncValue.data(admindetails),
        
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ✅ Check phone number is valid
  Future<void> checkPhoneNumber(String mobileNo) async {
    state = state.copyWith(phoneCheckResult: const AsyncValue.loading());
    try {
      final result = await usecase.checkPhoneNumber(mobileNo);
      state = state.copyWith(phoneCheckResult: AsyncValue.data(result));
    } catch (e, st) {
      state = state.copyWith(phoneCheckResult: AsyncValue.error(e, st));
    }
  }

  Future<void> clearLogin() async {

    await usecase.logOut();
  state = const AdminloginState(
    isLoading: false,
    error: null,
    adminDetails: AsyncValue.data([]),
    phoneCheckResult: AsyncValue.data([]),
    userId: 0,
    name: null,
    mobileNo: null,
    email: null,
    roleId: null,
    companyName: null,
    token: null,
    isCheckedIn: null,
    companyId: null,
  );

  await TokenStorage.clear();
}

 
}
