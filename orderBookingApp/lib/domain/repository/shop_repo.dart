import 'package:order_booking_app/domain/models/shop_details.dart';

abstract class ShopRepository {
  Future<void> addShop(ShopDetails shopDetails);
  Future<List<ShopDetails>> getEmpShopList(String companyId, int regionID);
  Future<List<ShopDetails>> getShopList(String companyId);
  
}






