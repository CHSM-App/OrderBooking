import 'dart:convert';
import 'package:order_booking_app/domain/repository/region.dart';
import '../../domain/models/region.dart';
import '../local/offline_region_dao.dart';
import 'package:order_booking_app/data/api/api_service.dart';

class RegionImplOffline implements RegionRepooffline {
  final OfflineRegionDao local;
  final ApiService apiService;

  bool _isSyncing = false;
  RegionImplOffline({required this.local, required this.apiService});

  /// Save region offline for later sync
@override
Future<void> saveRegionOffline(Region region) async {
  await local.insertPending(region);
}

@override
Future<void> syncOfflineRegions(String companyId) async {
  if (_isSyncing) return;
  _isSyncing = true;

  try {

    /// PUSH LOCAL → SERVER
    final pending = await local.fetchPending();

    for (final row in pending) {
      final id = row['id'] as int;

      try {
        await local.markSyncing(id);

        final region = Region.fromLocalJson(
          jsonDecode(row['payload']),
          localId: row['local_id'],
        );

        final response = await apiService.addRegion(region);

        if (response['success'] == true) {
          await local.markSynced(id, response['server_id']);
        }

      } catch (e) {
        await local.incrementRetry(id);
      }
    }

    /// PULL SERVER → LOCAL CACHE
    final serverRegions = await apiService.fetchRegionList(companyId);

    for (final region in serverRegions) {
      await local.upsertFromServer(region);
    }

  } finally {
    _isSyncing = false;
  }
}

//FETCH LIST
Future<List<Region>> fetchRegions(String companyId) async {
  /// Background sync
  await syncOfflineRegions(companyId);

  final rows = await local.fetchAll();

  return rows.map((row) {
    final payload = jsonDecode(row['payload']);
    return Region.fromLocalJson(payload);

  }).toList();
}

}


