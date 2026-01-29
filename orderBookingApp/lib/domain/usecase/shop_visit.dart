import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/domain/repository/shop_visit.dart';

class VisitUseCase {
  final VisitRepository repository;

  VisitUseCase(this.repository);

  // Future<void> recordVisit(VisitPayload visit) async {
  //   await repository.saveVisitOffline(visit);
  // }

  // Future<void> syncVisits() async {
  //   await repository.syncOfflineVisits();
  // }

  Future<void> saveVisitOffline(VisitPayload visit) {
    return repository.saveVisitOffline(visit);
  }
  Future<void> syncOfflineVisits() {
    return repository.syncOfflineVisits();
  }
}