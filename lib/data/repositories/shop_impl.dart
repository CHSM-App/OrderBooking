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

  // 🔹 CREATE
  @override
  Future<void> addShop(ShopDetails shop) async {

    final newShop = shop.copyWith(
      localId: shop.localId ?? const Uuid().v4(),
      isSynced: false,
      syncAction: 'create',
      isDeleted: false,
    );

    await local.insertOrUpdate(newShop);
  }

  // 🔹 UPDATE
  Future<void> updateShop(ShopDetails shop) async {

    final updated = shop.copyWith(
      isSynced: false,
      syncAction: 'update',
    );

    await local.insertOrUpdate(updated);
  }

  // 🔹 DELETE (Soft delete)
  Future<void> deleteShop(ShopDetails shop) async {

    final deleted = shop.copyWith(
      isSynced: false,
      isDeleted: true,
      syncAction: 'delete',
    );

    await local.insertOrUpdate(deleted);
  }

  // 🔹 Sync Local → Server
  Future<void> syncLocalToServer() async {

    final unsynced = await local.getUnsynced();

    for (final shop in unsynced) {

      try {

        if (shop.syncAction == 'create') {

          final response = await apiService.addShopDetails(shop);

          final serverId = response['shop_id'] as int;

          await local.markSynced(shop.localId!, serverId);
        }

        else if (shop.syncAction == 'update') {

          await apiService.addShopDetails(shop);

          await local.markSynced(shop.localId!, shop.shopId!);
        }

        else if (shop.syncAction == 'delete') {

          await apiService.deleteShop(shop.shopId!);

          await local.markDeletedSynced(shop.localId!);
        }

      } catch (e) {
        debugPrint("Shop sync failed: $e");
      }
    }
  }

  // 🔹 Sync Server → Local
  Future<void> syncServerToLocal(String companyId, int regionId) async {

    try {

      final serverShops =
          await apiService.getEmpShopList(companyId, regionId);

      for (final shop in serverShops) {

        final exists =
            await local.existsByServerId(shop.shopId!);

        if (!exists) {

          await local.insertOrUpdate(
            shop.copyWith(
              localId: const Uuid().v4(),
              isSynced: true,
              syncAction: null,
              isDeleted: false,
            ),
          );
        }
      }

    } catch (e) {
      debugPrint("Server → Local shop sync failed");
    }
  }

  @override
  Future<List<ShopDetails>> getEmpShopList(
      String companyId,
      int regionId,
      ) async {

    await syncLocalToServer();
    await syncServerToLocal(companyId, regionId);

    return await local.getAll();
  }


  Future<List<ShopDetails>> getShopList(String companyId) async {
    return  await apiService.getShopList(companyId);
  }


}

