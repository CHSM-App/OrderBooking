import 'package:order_booking_app/data/DB/app_database.dart';

class LogoutDao {
  Future<void> logout() async {
    await AppDatabase.clearAllTables();
  }
}
