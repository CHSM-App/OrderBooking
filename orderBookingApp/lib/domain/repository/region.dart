
import 'package:order_booking_app/domain/models/region.dart';

abstract class RegionRepooffline {
  /// Save region offline (SQLite) for later sync
  Future<void> saveRegionOffline(Region region);

  /// Sync all offline regions to API
  Future<void> syncOfflineRegions();
  Future<List<Region>> fetchRegions();
  
}