
import 'package:order_booking_app/domain/models/region.dart';

abstract class RegionRepooffline {
  /// Save region offline (SQLite) for later sync
  Future<void> saveRegionOffline(Region region);
  Future<void> pushLocalToServer();
  /// Sync all offline regions to API
  Future<void> pullServerToLocal(String companyId);
  
  Future<List<Region>> fetchRegions(String companyId);
  
}