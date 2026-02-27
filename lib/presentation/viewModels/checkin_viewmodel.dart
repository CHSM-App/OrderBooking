import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/usecase/checkin_usecase.dart';

class CheckinState {
  final bool isCheckedIn;
  final bool isLoading;
  final String? message;
  final String? error;
  final AsyncValue<CheckInStatusRequest?> todayStatus;
  final AsyncValue<List<CheckInStatusRequest>> attendanceList;

  const CheckinState({
    this.isCheckedIn = false,
    this.isLoading = false,
    this.message,
    this.error,
    this.todayStatus = const AsyncValue.data(null),
    this.attendanceList = const AsyncValue.data([]),
  });

  CheckinState copyWith({
    bool? isCheckedIn,
    bool? isLoading,
    String? message,
    String? error,
    AsyncValue<CheckInStatusRequest?>? todayStatus,
    AsyncValue<List<CheckInStatusRequest>>? attendanceList,
  }) {
    return CheckinState(
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      error: error,
      todayStatus: todayStatus ?? this.todayStatus,
      attendanceList: attendanceList ?? this.attendanceList,
    );
  }
}
class CheckinViewmodel extends StateNotifier<CheckinState> {
  final CheckinUsecase usecase;

  CheckinViewmodel(this.usecase) : super(const CheckinState());

  Future<void> checkIn(int empId, double lat, double long) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final response = await usecase.checkIn(empId, lat, long);
      state = state.copyWith(
          isLoading: false,
          isCheckedIn: true,
          message: response.message,
          error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkOut(int empId, double lat, double long) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final response = await usecase.checkOut(empId, lat, long);
      state = state.copyWith(
          isLoading: false,
          isCheckedIn: false,
          message: response.message,
          error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadTodayStatus(int empId) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final result = await usecase.fetchTodayStatus(empId);
      state = state.copyWith(
        isLoading: false,
        todayStatus: AsyncValue.data(result),
        isCheckedIn: result?.checkinStatus == 1,
        error: null,
        message: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        message: null,
        todayStatus: const AsyncValue.data(null),
      );
    }
  }
  Future<void> getAttendance(int empId) async {
    state = state.copyWith(isLoading: true);
    final list = await usecase.getAttendance(empId);
    state = state.copyWith(
        isLoading: false, attendanceList: AsyncValue.data(list));
  }

    void clearMessage() {
      state = state.copyWith(message: null, error: null);
    }
}
