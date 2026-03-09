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
  final int? regionId;
  final String? joiningDate;
  final bool? isSuperadmin;

  final AsyncValue<List<AdminLogin>>? adminDetails;
  final AsyncValue<List<LoginInfo>> phoneCheckResult;
  final AsyncValue<List<AdminLogin>> adminList;
  final int userId;
  const AdminloginState({
    this.joiningDate,
    this.regionId,
    this.isLoading = false,
    this.error,
    this.adminDetails = const AsyncValue.loading(),
    this.phoneCheckResult = const AsyncValue.data([]),
    this.adminList = const AsyncValue.data([]),
    this.userId = 0,
    this.name,
    this.mobileNo,
    this.email,
    this.roleId,
    this.companyName,
    this.token,
    this.isCheckedIn,
    this.companyId,
    this.isSuperadmin,
  });

  AdminloginState copyWith({
    int? regionId,
    bool? isLoading,
    String? error,
    AsyncValue<List<AdminLogin>>? adminDetails,
    AsyncValue<List<LoginInfo>>? phoneCheckResult,
    AsyncValue<List<AdminLogin>>? adminList,
    int? userId,
    String? name,
    String? mobileNo,
    String? email,
    String? roleId,
    String? companyName,
    String? token,
    String? isCheckedIn,
    String? companyId,
    String? joiningDate,
    bool? isSuperadmin,
  }) {
    return AdminloginState(
      regionId: regionId ?? this.regionId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      adminDetails: adminDetails ?? this.adminDetails,
      phoneCheckResult: phoneCheckResult ?? this.phoneCheckResult,
      adminList: adminList ?? this.adminList,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      companyName: companyName ?? this.companyName,
      token: token ?? this.token,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      companyId: companyId ?? this.companyId,
      joiningDate: joiningDate ?? this.joiningDate,
      isSuperadmin: isSuperadmin ?? this.isSuperadmin,
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
    final  roleId = await TokenStorage.getValue('role_id');
    print("RoleId: $roleId");
    final companyName = await TokenStorage.getValue('company_name');
    final token = await TokenStorage.getValue('token');
    final isCheckedIn = await TokenStorage.getValue('isCheckedIn');
    final userIdStr = await TokenStorage.getValue('user_id');
    final userId = int.tryParse(userIdStr ?? '0') ?? 0;
    final companyId = await TokenStorage.getValue('company_id');
    final regionIdStr = await TokenStorage.getValue('region_id');
    final regionId = int.tryParse(regionIdStr ?? '');
    final joiningDate = await TokenStorage.getValue('joining_date');
    final isSuperadminStr = await TokenStorage.getValue('is_superadmin');
    final isSuperadmin = isSuperadminStr?.toString() == 'true';
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
      regionId: regionId,
      joiningDate: joiningDate,
      isSuperadmin: isSuperadmin,

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

  Future<void> fetchAdminDetails(
    String mobileNo, {
    bool useCacheFirst = true,
  }) async {
    var hasCached = false;
    if (useCacheFirst) {
      final cached = state.adminDetails?.valueOrNull;
      if (cached != null && cached.isNotEmpty) {
        hasCached = true;
        state = state.copyWith(isLoading: false, error: null);
      }
    }

    state = state.copyWith(isLoading: !hasCached, error: null);
    try {
      final admindetails = await usecase.fetchAdminDetails(mobileNo);
      state = state.copyWith(
        isLoading: false,
        adminDetails: AsyncValue.data(admindetails),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: hasCached ? null : e.toString(),
        adminDetails: hasCached
            ? state.adminDetails
            : AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  // ✅ Check phone number is valid
  Future<void> checkPhoneNumber(String mobileNo) async {
    state = state.copyWith(phoneCheckResult: const AsyncValue.loading());
    try {
      final result = await usecase.checkPhoneNumber(mobileNo);
      state = state.copyWith(phoneCheckResult: AsyncValue.data(result));
      await loadFromStorage();
    } catch (e, st) {
      state = state.copyWith(phoneCheckResult: AsyncValue.error(e, st));
    }
  }

  Future<void> clearLogin(String refreshToken) async {
    await usecase.logOut(refreshToken);
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

  Future<Map<String, dynamic>> addUpdateAdmin(AdminLogin admin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await usecase.addUpdateAdmin(admin);

      state = state.copyWith(isLoading: false);

      return response; // contains success & message from SP
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());

      return {"success": 0, "message": "Something went wrong"};
    }
  }

  Future<void> fetchAdmins(String companyId) async {
    state = state.copyWith(
      isLoading: true,
      adminList: const AsyncValue.loading(),
    );
    try {
      final details = await usecase.fetchAdmins(companyId);
      state = state.copyWith(
        isLoading: false,
        adminList: AsyncValue.data(details),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        adminList: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  Future<Map<String, dynamic>> deleteAdmin(int adminId) async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final response = await usecase.deleteAdmin(adminId);

    state = state.copyWith(isLoading: false);

    return response; // contains success & message from SP
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );

    return {"success": 0, "message": "Something went wrong"};
  }
}

  
}
