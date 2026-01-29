import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/visite.dart';

abstract class ShopRepository {
  Future<void> addShop(ShopDetails shopDetails);
  Future<List<ShopDetails>> getShopList();
  Future<dynamic> addVisit(VisitPayload visitPayload);
}






