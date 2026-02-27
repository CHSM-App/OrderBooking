import 'package:order_booking_app/domain/models/shop_details.dart';

import 'package:order_booking_app/domain/repository/shop_repo.dart';

class ShopUsecase {
  final ShopRepository shoprepository;

  ShopUsecase(this.shoprepository);

  Future<void> addShop(ShopDetails shopDetails) {
    return shoprepository.addShop(shopDetails);
  }
  Future<void> updateShop(ShopDetails shopDetails) {
    return shoprepository.updateShop(shopDetails);
  }
  Future<void> deleteShop(ShopDetails shopDetails) {
    return shoprepository.deleteShop(shopDetails);
  }

     Future<List<ShopDetails>> getEmpShopList(String companyId, int regionID) {
    return shoprepository.getEmpShopList(companyId, regionID );
  }
     Future<List<ShopDetails>> getShopList(String companyId) {
    return shoprepository.getShopList(companyId );
  }


}