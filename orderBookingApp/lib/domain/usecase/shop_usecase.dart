import 'package:order_booking_app/domain/models/shop_details.dart';

import 'package:order_booking_app/domain/repository/shop_repo.dart';

class ShopUsecase {
  final ShopRepository shoprepository;

  ShopUsecase(this.shoprepository);

  Future<void> addShop(ShopDetails shopDetails) {
    return shoprepository.addShop(shopDetails);
  }

     Future<List<ShopDetails>> getShopList( ) {
    return shoprepository.getShopList( );
  }

  Future<void> sync(String company_id){
    return shoprepository.sync(company_id);
  }
}