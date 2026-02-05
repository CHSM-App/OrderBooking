import 'package:order_booking_app/data/api/api_service.dart';

import 'package:order_booking_app/domain/models/region.dart';

import 'package:order_booking_app/domain/repository/region_repo.dart';

class RegionImpl implements RegionRepository {
  final ApiService apiService;

  RegionImpl(this.apiService);

  @override
  Future<dynamic> addRegion(Region region) {
    return apiService.addRegion(region);
  }
 
  @override
  Future<List<Region>> getRegionList(String companyId) {
    return apiService.fetchRegionList(companyId);
  }
}