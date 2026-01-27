import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/repository/shop_repo.dart';


class ShopImpl implements ShopRepository {
  final ApiService apiService;

  ShopImpl(this.apiService);

  @override
  Future<dynamic> addShop(ShopDetails shopDetails) {
    return apiService.addShopDetails(shopDetails);
  }

  @override
  Future<List<Shop>> getShopList() {
    return apiService.getShopList();
  }
}