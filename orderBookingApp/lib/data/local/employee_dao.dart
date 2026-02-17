import 'package:order_booking_app/data/DB/app_database.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:sqflite/sqflite.dart';

class EmployeeDao {

  Future<void> insertOrReplace(EmployeeLogin employee) async {
        final db = await AppDatabase.database;
    await db.insert(
      'employee',
      employee.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<EmployeeLogin?> getEmployee() async {
        final db = await AppDatabase.database;
    final result = await db.query('employee', limit: 1);

    if (result.isNotEmpty) {
      return EmployeeLogin.fromJson(result.first);
    }
    return null;
  }

  Future<void> clearEmployee() async {
        final db = await AppDatabase.database;
    await db.delete('employee');
  }
}
