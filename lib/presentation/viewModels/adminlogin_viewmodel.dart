import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/admin_login.dart';
import 'package:order_booking_app/domain/usecase/adminlogin_usecase.dart';



class AdminloginState {
  final bool isLoading;
  final String? error;
     final AsyncValue<List<AdminLogin>>? adminDetails;
 
  const AdminloginState({
   
    this.isLoading = false,
    this.error,
       this.adminDetails = const AsyncValue.loading(),
   
  });

  AdminloginState copyWith({
    bool? isLoading,
    String? error,
        AsyncValue<List<AdminLogin>>? adminDetails,
 
  }) {
    return AdminloginState(
     
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
       adminDetails: adminDetails??this.adminDetails,
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
  
} 


