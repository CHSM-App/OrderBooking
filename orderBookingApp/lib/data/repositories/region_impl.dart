// import 'dart:convert';
// import 'package:order_booking_app/domain/repository/region.dart';
// import '../../domain/models/region.dart';
// import '../local/offline_region_dao.dart';
// import 'package:order_booking_app/data/api/api_service.dart';

// class RegionImplOffline implements RegionRepooffline {
//   final OfflineRegionDao local;
//   final ApiService apiService;

//   RegionImplOffline({required this.local, required this.apiService});
  

//   /// Save region offline for later sync
// @override
// Future<void> saveRegionOffline(Region region) async {
//   await local.insertPending(region);
// }

// Future<List<Region>> fetchRegions(String companyId) async {

// try {
//     await pushLocalToServer();
//   await pullServerToLocal(companyId);
// } catch (e) {
  
// }

//   final rows = await local.fetchAll();

//   return rows.map((row) {
//     final payload = jsonDecode(row['payload']);
//     return Region.fromLocalJson(payload);

//   }).toList();
// }

// Future<void> pushLocalToServer() async {
//   final pending = await local.fetchPending();

//   for (final row in pending) {
//     final id = row['local_id'];

//     try {
//       await local.markSyncing(id);

//       final region = Region.fromLocalJson(
//         jsonDecode(row['payload']),
//         localId: row['local_id'],
//       );

//       final response = await apiService.addRegion(region);

//       if (response['success'] == true) {
//         await local.markSynced(id, response['region_id']);
//       } else {
//         await local.incrementRetry(id);
//       }

//     } catch (e) {
//       await local.incrementRetry(id);
//     }
//   }
// }



// Future<void> pullServerToLocal(String companyId) async {
//   final serverRegions = await apiService.fetchRegionList(companyId);

//   for (final region in serverRegions) {
//     await local.upsertFromServer(region);
//   }
// }


// }

import 'package:order_booking_app/data/api/api_service.dart';

import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/repository/region.dart';



 class RegionImplOffline implements RegionRepooffline {
  final ApiService apiService;

  RegionImplOffline(this.apiService);

  @override
  Future<dynamic> addRegion(Region region) {
    return apiService.addRegion(region);
  }
 
  @override
  Future<List<Region>> fetchRegionList(String companyId) {
    return apiService.fetchRegionList(companyId);
  }

//  @override
//   Future<void> deleteRegion(int regionId, String companyId) {
//     return apiService.deleteRegion(regionId, companyId);
//   }
  
  @override
Future<Map<String, dynamic>> deleteRegion(int regionId, String companyId) async {
  final response = await apiService.deleteRegion(regionId, companyId);
  return response as Map<String, dynamic>;
}

 }
