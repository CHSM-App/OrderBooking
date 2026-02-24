import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/domain/repository/shop_visit.dart';

class VisitUseCase {
  final VisitRepository repository;

  VisitUseCase(this.repository);

  Future<void> saveVisitOffline(VisitPayload visit) {
    return repository.saveVisitOffline(visit);
  }
  Future<void> syncOfflineVisits() {
    return repository.syncOfflineVisits();
  }

  Future<List<EmployeeVisit>> getEmployeeVisits(int empId) {
    return repository.getEmployeeVisits(empId);
  }

  Future<void> purgeSyncedBeforeToday() {
    return repository.purgeSyncedBeforeToday();
  }

  Future<int> countTodayVisits() {
    return repository.countTodayVisits();
  }
}

