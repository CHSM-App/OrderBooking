import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/storage/token_storage.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/usecase/login_usecase.dart';

class AdminloginState {
  final bool isLoading;
  final String? error;
     final AsyncValue<List<AdminLogin>>? adminDetails;
   final AsyncValue<List<LoginInfo>> phoneCheckResult;
   final int userId;
  const AdminloginState({
   
    this.isLoading = false,
    this.error,
       this.adminDetails = const AsyncValue.loading(),
         this.phoneCheckResult = const AsyncValue.data([]),
          this.userId = 0,
   
  });

  AdminloginState copyWith({
    bool? isLoading,
    String? error,
        AsyncValue<List<AdminLogin>>? adminDetails,
     AsyncValue<List<LoginInfo>>? phoneCheckResult,
    int? userId,
  }) {
    return AdminloginState(
     
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
       adminDetails: adminDetails??this.adminDetails,
        phoneCheckResult: phoneCheckResult ?? this.phoneCheckResult,
        userId: userId ?? this.userId,
    );
  }
}
class AdminloginViewModel extends StateNotifier<AdminloginState> {
  final AdminloginUsecase usecase;
  AdminloginViewModel(this.usecase) : super(const AdminloginState());

  Future<void> loadFromStorage() async {
    final name = await TokenStorage.getValue('name');
    final mobileNo = await TokenStorage.getValue('mobile_no');
    final email = await TokenStorage.getValue('email');
    final roleId = await TokenStorage.getValue('role_id');
    final companyName = await TokenStorage.getValue('company_name');
    final token = await TokenStorage.getValue('token');
    final isCheckedIn = await TokenStorage.getValue('isCheckedIn');

    state = state.copyWith(userId: int.tryParse(await TokenStorage.getValue('user_id') ?? '0') ?? 0);
    
    state = state.copyWith(
      phoneCheckResult: AsyncValue.data([
        LoginInfo(
          name: name,
          mobileNo: mobileNo,
          email: email,
          roleId: roleId != null ? int.tryParse(roleId) : null,
          companyName: companyName,
          Token: token,
          isCheckedIn: isCheckedIn,
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
  
 Future<void>fetchAdminDetails(String mobileNo)async{
  state=state.copyWith(isLoading: true,error:null);
  try{
    final admindetails=await usecase.fetchAdminDetails(mobileNo);
    state=state.copyWith(isLoading: false,adminDetails:  AsyncValue.data(admindetails));
  }
  catch(e){
    state=state.copyWith(isLoading: false,error: e.toString());
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
  
} 


