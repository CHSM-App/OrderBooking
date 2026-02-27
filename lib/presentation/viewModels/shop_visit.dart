import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/domain/usecase/shop_visit.dart';
import '../../domain/models/visite.dart';

class EmployeeVisitState {
  final bool isLoading;
  final String? error;
  final int? visitedShops;
  final AsyncValue<List<EmployeeVisit>> visits; // non-null

  const EmployeeVisitState({
    this.isLoading = false,
    this.error,
    this.visitedShops,
    this.visits = const AsyncValue.loading(), // default loading
  });

  EmployeeVisitState copyWith({
    bool? isLoading,
    String? error,
    int? visitedShops,
    AsyncValue<List<EmployeeVisit>>? visits,
  }) {
    return EmployeeVisitState(
      visitedShops: visitedShops ?? this.visitedShops,
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

  Future<void> purgeOldSyncedVisits() async {
    await repo.purgeSyncedBeforeToday();
  }

  Future<void> getTodayVisitCount(int empId) async {
    final result = await repo.countTodayVisits(empId);

    state = state.copyWith(visitedShops: result);
  }

  //   Future<void> fetchEmployeeVisits(int empId) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //   try {
  //     final visits = await repo.getEmployeeVisits(empId);
  //     state = state.copyWith(
  //       isLoading: false,
  //       visits: AsyncValue.data(visits),
  //     );
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }

Future<void> fetchEmployeeVisits(int empId) async {
  state = state.copyWith(visits: const AsyncValue.loading(), error: null);
  try {
    final visits = await repo.getEmployeeVisits(empId);
    state = state.copyWith(visits: AsyncValue.data(visits));
  } catch (e, st) {
    state = state.copyWith(visits: AsyncValue.error(e, st));
  }
}

}

