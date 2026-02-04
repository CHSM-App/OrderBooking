import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/usecase/shop_visit.dart';
import '../../domain/models/visite.dart';

class VisitViewModel extends StateNotifier<AsyncValue<void>> {
  final VisitUseCase repo;

  VisitViewModel(this.repo) : super(const AsyncData(null));

  Future<void> addVisit(VisitPayload visit) async {
    state = const AsyncLoading();

    try {
      await repo.saveVisitOffline(visit);
      await sync();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> sync() async {
    await repo.syncOfflineVisits();
  }
}

