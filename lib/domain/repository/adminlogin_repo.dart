import 'package:order_booking_app/domain/models/admin_login.dart';

abstract class AdminloginRepository {

  Future<dynamic> addAdminDetails(AdminLogin adminLogin);


}
