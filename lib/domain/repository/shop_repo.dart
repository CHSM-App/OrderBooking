import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';

abstract class ShopRepository {
  Future<void> addShop(ShopDetails shopDetails);
  Future<List<Shop>> getShopList();
}






