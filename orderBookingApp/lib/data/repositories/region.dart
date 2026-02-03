import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    debugPrint('Saving region offline: ${region.toJson()}');
    await local.insert(region);
  }

  /// Sync all pending offline regions
  @override
  Future<void> syncOfflineRegions() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final rows = await local.fetchPending();
      for (final row in rows) {
        final id = row['id'] as int;
        final retryCount = row['retry_count'] as int? ?? 0;
        if (retryCount >= 5) continue;
        try {
          // Mark as syncing
          await local.markSyncing(id);
          // Decode offline payload
          final region = Region.fromLocalJson(
            jsonDecode(row['payload']),
            localId: row['id'].toString(),
          );
          // Send to API
          final response = await apiService.addRegion(region);
          debugPrint('Sync response for region id $id: ${response['success']}');
          if (response['success'] != true) {
            throw Exception('Failed to sync region with id $id');
          }
          // Delete from offline after successful sync
          await local.delete(id);
        } catch (e) {
          debugPrint(
            'Error syncing region with id $id, incrementing retry count: $e',
          );
          await local.incrementRetry(id);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

//FETCH LIST

  Future<List<Region>> fetchRegions() async {
    // 1️⃣ Sync offline first
    await syncOfflineRegions();
    List<Region> mergedList = [];
    // 2️⃣ Fetch server regions
    try {
      final serverData = await apiService.fetchRegionList();
      List<Region> serverRegions;
      // ServerData type check
      if (serverData.isNotEmpty) {
        serverRegions = serverData.cast<Region>();
      } else {
        serverRegions = (serverData as List)
            .map((e) => Region.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      mergedList.addAll(serverRegions);
    } catch (e) {
      debugPrint('Failed to fetch server regions: $e');
    }
    // 3️⃣ Fetch offline pending
    final offlineRows = await local.fetchPending();
    final offlineRegions = offlineRows.map((row) {
      final payload = jsonDecode(row['payload']);
      return Region.fromLocalJson(payload, localId: row['id'].toString());
    }).toList();

    // 4️⃣ Merge offline first
    mergedList = [...offlineRegions, ...mergedList];

    return mergedList;
  }
}
