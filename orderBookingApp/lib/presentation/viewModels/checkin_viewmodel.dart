import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/usecase/checkin_usecase.dart';

/// STATE
class CheckinState {
  final bool isLoading;
  final String? error;
  final AsyncValue<CheckInStatusRequest?> attendance;
  

  const CheckinState({
    this.isLoading = false,
    this.error,
    this.attendance = const AsyncValue.loading(),
   
  });

  CheckinState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<CheckInStatusRequest?>? attendance,
    
  }) {
    return CheckinState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      attendance: attendance ?? this.attendance,  
    );
  }
}

/// VIEWMODEL
class CheckinViewmodel extends StateNotifier<CheckinState> {
  final CheckinUsecase usecase;

  CheckinViewmodel(this.usecase) : super(const CheckinState());

  /// LOAD TODAY STATUS
  Future<void> loadTodayStatus(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await usecase.fetchTodayStatus(empId);
      state = state.copyWith(
        isLoading: false,
        attendance: AsyncValue.data(result),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        attendance: const AsyncValue.data(null),
      );
    }
  }

  /// CHECK-IN
  Future<void> checkIn(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await usecase.checkIn(empId);
      await loadTodayStatus(empId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// CHECK-OUT
  Future<void> checkOut(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.checkOut(empId);
      await loadTodayStatus(empId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
