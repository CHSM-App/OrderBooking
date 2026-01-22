import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/admin_login.dart';
import 'package:order_booking_app/domain/usecase/adminlogin_usecase.dart';



class AdminloginState {
  final bool isLoading;
  final String? error;
 
  const AdminloginState({
   
    this.isLoading = false,
    this.error,
   
  });

  AdminloginState copyWith({
    bool? isLoading,
    String? error,
 
  }) {
    return AdminloginState(
     
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    
    );
  }
}
class AdminloginViewModel extends StateNotifier<AdminloginState> {
  final AdminloginUsecase usecase;
  AdminloginViewModel(this.usecase) : super(const AdminloginState());

  Future<void> addAdminDetails(AdminLogin adminLogin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addAdminDetails(adminLogin);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
} 


