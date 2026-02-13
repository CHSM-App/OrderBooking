// import 'package:order_booking_app/domain/models/region.dart';
// import 'package:order_booking_app/domain/repository/region.dart';

// class RegionUsecaseoffline {
//  final RegionRepooffline regionRepooffline;

//   RegionUsecaseoffline(this.regionRepooffline);

//    Future<void> saveRegionOffline(Region region) {
//     return regionRepooffline.saveRegionOffline(region);
//   }
//     /// Fetch merged regions (offline + server)
//   Future<List<Region>> fetchRegions(String companyId) {
//     return regionRepooffline.fetchRegions(companyId);
//   }

// }
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/repository/region.dart';


class RegionUsecaseoffline {
 final RegionRepooffline regionRepooffline;

  RegionUsecaseoffline(this.regionRepooffline);

  Future<dynamic> addRegion(Region region) {
    return regionRepooffline.addRegion(region);
  }

  Future<List<Region>> fetchRegionList(String companyId) {
    return regionRepooffline.fetchRegionList(companyId);
  }
   Future<Map<String, dynamic>> deleteRegion(int regionId, String companyId) {
    return regionRepooffline.deleteRegion(regionId, companyId);
  }

}