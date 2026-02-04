import 'package:order_booking_app/domain/models/visite.dart';

import 'package:order_booking_app/domain/models/employee_visit.dart';

abstract class VisitRepository {
  Future<void> saveVisitOffline(VisitPayload visit);
  Future<void> syncOfflineVisits();
  Future<List<EmployeeVisit>> getEmployeeVisits(int empId);
  // Future<void> syncVisits();
}

