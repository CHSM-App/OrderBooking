import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/domain/usecase/shop_visit.dart';
import '../../domain/models/visite.dart';


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

class VisitViewModel extends StateNotifier<EmployeeVisitState> {
  final VisitUseCase repo;

  VisitViewModel(this.repo) : super(const EmployeeVisitState());

  Future<void> addVisit(VisitPayload visit) async {
    try {
      await repo.saveVisitOffline(visit);
      await sync();
    } catch (e) {

    }
  }

  Future<void> sync() async {
    await repo.syncOfflineVisits();
  }

    Future<void> fetchEmployeeVisits(int empId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final visits = await repo.getEmployeeVisits(empId);
      state = state.copyWith(
        isLoading: false,
        visits: AsyncValue.data(visits),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

