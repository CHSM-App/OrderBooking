import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/repository/region_repo.dart';

class AddRegionUsecase {
  final RegionRepository regionRepository;

  AddRegionUsecase(this.regionRepository);

  Future<dynamic> addRegion(Region region) {
    return regionRepository.addRegion(region);
  }

  Future<List<Region>> getRegionList() {
    return regionRepository.getRegionList();
  }

}