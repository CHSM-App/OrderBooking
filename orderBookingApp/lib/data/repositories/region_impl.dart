
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/local/offline_region_dao.dart';

import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/repository/region.dart';

class RegionImplOffline implements RegionRepooffline {
  final ApiService apiService;
  final OfflineRegionDao local;

  RegionImplOffline(this.apiService, this.local);

  @override
  Future<dynamic> addRegion(Region region) {
    return apiService.addRegion(region);
  }

  Future<void> pullServerToLocal(String companyId) async {
    final serverRegions = await apiService.fetchRegionList(companyId);

    if (serverRegions.isEmpty) {
      await local.deleteRegionsNotIn([]);
      return;
    }

    final serverIds = serverRegions
        .map((r) => r.regionId)
        .whereType<int>()
        .toList();

    // 1️⃣ Upsert
    await local.upsertFromServer(serverRegions);

    // 2️⃣ Delete stale
    await local.deleteRegionsNotIn(serverIds);
  }

  @override
  Future<List<Region>> fetchRegionList(String companyId) async {
    await pullServerToLocal(companyId);
    final rows = await local.fetchAll();

    return rows.map((row) {
      return Region(
        localId: row['local_id'] as String?,
        regionId: row['server_id'] as int?,
        regionName: row['region_name'] as String?,
        pincode: row['pincode'] as String?,
        district: row['district'] as String?,
        state: row['state'] as String?,
        companyId: row['company_id'] as String?,
        createdBy: row['created_by'] as int?,
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> deleteRegion(
    int regionId,
    String companyId,
  ) async {
    final response = await apiService.deleteRegion(regionId, companyId);
    return response as Map<String, dynamic>;
  }
}
