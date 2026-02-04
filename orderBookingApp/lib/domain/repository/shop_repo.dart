import 'package:order_booking_app/domain/models/shop_details.dart';

abstract class ShopRepository {
  Future<void> addShop(ShopDetails shopDetails);
  Future<List<ShopDetails>> getShopList();
  Future<void> sync(String company_id);
  
}






