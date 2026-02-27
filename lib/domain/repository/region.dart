// import 'package:order_booking_app/domain/models/region.dart';

// abstract class RegionRepooffline {
//   /// Save region offline (SQLite) for later sync
//   Future<void> saveRegionOffline(Region region);
//   Future<void> pushLocalToServer();
//   /// Sync all offline regions to API
//

//   Future<List<Region>> fetchRegions(String companyId);

// }
import 'package:order_booking_app/domain/models/region.dart';

abstract class RegionRepooffline {
  Future<void> pullServerToLocal(String companyId);
  Future<dynamic> addRegion(Region region);
  Future<List<Region>> fetchRegionList(String companyId);
  Future<Map<String, dynamic>> deleteRegion(int regionId, String companyId);
}
