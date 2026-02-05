import 'package:flutter/rendering.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/shop_dao.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/repository/shop_repo.dart';
import 'package:uuid/uuid.dart';

class ShopImpl implements ShopRepository {
  final ApiService apiService;
  final ShopDao local;

  ShopImpl(this.apiService, this.local);

  @override
  Future<dynamic> addShop(ShopDetails shopDetails) async {
    await local.insert(shopDetails);
  }

  @override
  Future<List<ShopDetails>> getShopList(String companyId) async{
    await syncLocalToServer();
    await syncServerToLocal(companyId);
    return local.getAll();
  }

  Future<void> syncLocalToServer() async {
    final unsynced = await local.getUnsynced();
    for (final shop in unsynced) {
      try {
        final response = await apiService.addShopDetails(shop);

        final serverId = response['shop_id'] as int;
        await local.markSynced(localId: shop.localId ?? "", serverId: serverId);
      } catch (e) {
        // retry later
        debugPrint("Failed to sync shop ${shop.localId}: $e");
      }
    }
  }

  /// ⬇️ Pull server shops
  Future<void> syncServerToLocal(String company_id) async {
    try {
      final serverShops = await apiService.getShopList(company_id);

      for (final shop in serverShops) {
        final exists = await local.existsByServerId(shop.shopId!);
        debugPrint("Shop ${shop.shopId} exists locally: $exists");
        if (!exists) {
          await local.insert(
            shop.copyWith(
              localId: const Uuid().v4(),
              isSynced: true,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error in looop $e");
    }
  }

}
