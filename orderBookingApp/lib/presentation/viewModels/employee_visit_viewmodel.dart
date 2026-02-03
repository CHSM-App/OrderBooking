import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/domain/usecase/shop_visit.dart';

class EmployeeVisitState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<EmployeeVisit>>? visits;

  const EmployeeVisitState({
    this.isLoading = false,
    this.error,
    this.visits = const AsyncValue.loading(),
  });

  EmployeeVisitState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<List<EmployeeVisit>>? visits,
  }) {
    return EmployeeVisitState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      visits: visits ?? this.visits,
    );
  }
}

class EmployeeVisitViewModel extends StateNotifier<EmployeeVisitState> {
  final VisitUseCase useCase;
  EmployeeVisitViewModel(this.useCase) : super(const EmployeeVisitState());

  Future<void> fetchEmployeeVisits(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final visits = await useCase.getEmployeeVisits(empId);
      state = state.copyWith(
        isLoading: false,
        visits: AsyncValue.data(visits),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
