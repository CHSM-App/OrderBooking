import 'package:order_booking_app/domain/models/region.dart';


abstract class RegionRepository {

  Future<dynamic> addRegion(Region region);
  Future<List<Region>>getRegionList();

}