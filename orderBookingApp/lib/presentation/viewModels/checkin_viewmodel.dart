import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/usecase/checkin_usecase.dart';

/// STATE
class CheckinState {
  final bool isLoading;
  final String? error;
  final String? message; // ✅ Added message state
  final AsyncValue<CheckInStatusRequest?> attendance;
  final bool isCheckedIn;

  const CheckinState({
    this.isCheckedIn = false,
    this.isLoading = false,
    this.error,
    this.message,
    this.attendance = const AsyncValue.loading(),
  });

  CheckinState copyWith({
    bool? isCheckedIn,
    bool? isLoading,
    String? error,
    String? message,
    AsyncValue<CheckInStatusRequest?>? attendance,
  }) {
    return CheckinState(
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
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
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final result = await usecase.fetchTodayStatus(empId);
      state = state.copyWith(
        isLoading: false,
        attendance: AsyncValue.data(result),
        isCheckedIn: result?.checkinStatus == 1,
        error: null,
        message: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        message: null,
        attendance: const AsyncValue.data(null),
      );
    }
  }

  /// CHECK-IN
  Future<void> checkIn(int empId) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      // ✅ Get response from usecase
      final response = await usecase.checkIn(empId);

      // ✅ Extract message from response
      final message = response.message ?? 'Checked in successfully!';
      // ✅ Update state with message
      state = state.copyWith(
        isLoading: false,
        isCheckedIn: true,
        message: message,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        message: null,
      );
      rethrow;
    }
  }

  /// CHECK-OUT
  Future<void> checkOut(int empId) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      // ✅ Get response from usecase
      final response = await usecase.checkOut(empId);
      // ✅ Extract message from response
      final message = response.message ?? 'Checked out successfully!';

      // ✅ Update state with message
      state = state.copyWith(
        isLoading: false,
        isCheckedIn: false,
        message: message,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        message: null,
      );
      rethrow;
    }
  }

  Future<void> getAttendance(int empId) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final attendanceList = await usecase.getAttendance(empId);
      // You can handle the attendance list as needed, e.g., store it in state
      state = state.copyWith(
        isLoading: false,
        attendance: AsyncValue.data(attendanceList.isNotEmpty ? attendanceList.first : null ),
        error: null,
        message: 'Attendance fetched successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        message: null,
      );
    }
  }


  /// Clear message (call after showing snackbar)
  void clearMessage() {
    state = state.copyWith(message: null, error: null);
  }
}
