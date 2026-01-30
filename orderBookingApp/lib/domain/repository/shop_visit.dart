import 'package:order_booking_app/domain/models/visite.dart';

abstract class VisitRepository {
  Future<void> saveVisitOffline(VisitPayload visit);
  Future<void> syncOfflineVisits();
  // Future<void> syncVisits();
}

