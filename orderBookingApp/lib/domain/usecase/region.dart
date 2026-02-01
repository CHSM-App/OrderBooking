import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/repository/region.dart';

class RegionUsecaseoffline {
  final RegionRepooffline regionRepooffline;

  RegionUsecaseoffline(this.regionRepooffline);

   Future<void> saveRegionOffline(Region region) {
    return regionRepooffline.saveRegionOffline(region);
  }
  Future<void> syncOfflineRegions() {
    return regionRepooffline.syncOfflineRegions();
  }
    /// Fetch merged regions (offline + server)
  Future<List<Region>> fetchRegions() {
    return regionRepooffline.fetchRegions();
  }

}