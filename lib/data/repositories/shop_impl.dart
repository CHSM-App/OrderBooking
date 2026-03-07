import 'dart:io';
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
  // Future<void> updateShop(ShopDetails shop) async {

  //   final updated = shop.copyWith(
  //     isSynced: false,
  //     syncAction: 'update',
  //   );

  //   await local.insertOrUpdate(updated);
  // }

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
          final response = await apiService.addShopDetails(
            shop.shopId,
            shop.shopName,
            shop.ownerName,
            shop.address,
            shop.mobileNo,
            shop.email,
            shop.regionId,
            shop.createdBy,
            shop.companyId,
            shop.latitude,
            shop.longitude,
            shop.type,
            _fileFromPath(shop.shopSelfie),
          );

          final serverId = response['shop_id'] as int;

          await _deleteLocalSelfieIfAny(shop);
          await local.clearSelfie(shop.localId!);
          await local.markSynced(shop.localId!, serverId);
        } else if (shop.syncAction == 'update') {
          await apiService.addShopDetails(
            shop.shopId,
            shop.shopName,
            shop.ownerName,
            shop.address,
            shop.mobileNo,
            shop.email,
            shop.regionId,
            shop.createdBy,
            shop.companyId,
            shop.latitude,
            shop.longitude,
            shop.type,
            _fileFromPath(shop.shopSelfie),
          );

          await _deleteLocalSelfieIfAny(shop);
          await local.clearSelfie(shop.localId!);
          await local.markSynced(shop.localId!, shop.shopId!);
        } else if (shop.syncAction == 'delete') {
          await _deleteLocalSelfieIfAny(shop);
          await apiService.deleteShop(shop.shopId!);

          await local.markDeletedSynced(shop.localId!);
        }
      } catch (e) {
        debugPrint("Shop sync failed: $e");
      }
    }
  }

  Future<void> _deleteLocalSelfieIfAny(ShopDetails shop) async {
    final path = shop.shopSelfie;
    if (path == null || path.isEmpty) return;

    try {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore delete failures to avoid blocking sync.
    }
  }

  File? _fileFromPath(String? path) {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  // 🔹 Sync Server → Local
  Future<void> syncServerToLocal(String companyId, int regionId,int type) async {
    try {
      final serverShops = await apiService.getEmpShopList(companyId, regionId,type);

      for (final shop in serverShops) {
        final exists = await local.existsByServerId(shop.shopId!);

        if (!exists) {
          final selfiePath = shop.shopSelfie;
          final selfieExists =
              selfiePath != null && File(selfiePath).existsSync();

          await local.insertOrUpdate(
            shop.copyWith(
              localId: const Uuid().v4(),
              isSynced: true,
              syncAction: null,
              shopSelfie: selfieExists ? selfiePath : null,
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
    int type
  ) async {
    await syncLocalToServer();
    await syncServerToLocal(companyId, regionId,type);

    return await local.getAll();
  }

  Future<List<ShopDetails>> getShopList(String companyId) async {
    return await apiService.getShopList(companyId);
  }
}
