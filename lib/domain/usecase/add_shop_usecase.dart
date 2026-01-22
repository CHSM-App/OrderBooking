import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/repository/add_shop_repo.dart';

class AddShopUsecase {
  final ShopRepository repository;

  AddShopUsecase(this.repository);

  Future<void> execute(ShopDetails shopDetails) {
    return repository.addShop(shopDetails);
  }

     Future<List<Shop>> getShopList() {
    return repository.getShopList();
  }

  }

