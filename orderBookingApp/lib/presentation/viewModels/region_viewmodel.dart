import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/usecase/region.dart';

class RegionState {
  final bool isLoading;
  final String? error;
  final AsyncValue<List<Region>> regionList;

  RegionState({
    this.isLoading = false,
    this.error,
    this.regionList = const AsyncValue.loading(),
  });

  RegionState copyWith({
    bool? isLoading,
    String? error,
    AsyncValue<List<Region>>? regionList,
  }) {
    return RegionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      regionList: regionList ?? this.regionList,
    );
  }
}

class RegionofflineViewModel extends StateNotifier<RegionState> {
  final RegionUsecaseoffline repo;

  RegionofflineViewModel(this.repo) : super(RegionState());

  // /// Fetch merged offline + server regions
  // Future<void> fetchRegions(String companyID) async {
  //   try {
  //     state = state.copyWith(isLoading: true, error: null);
  //     final regions = await repo.fetchRegions(companyID);
  //     state = state.copyWith(
  //       isLoading: false,
  //       regionList: AsyncValue.data(regions),
  //     );
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }

  // /// Add region offline + sync
  // Future<void> addRegion(Region region) async {
  //   try {
  //     state = state.copyWith(isLoading: true, error: null);
  //     await repo.saveRegionOffline(region);
  //     state = state.copyWith(isLoading: false);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }

Future<Map<String, dynamic>> addRegion(Region region) async {
  try {
    final response = await repo.addRegion(region);
    // Convert dynamic to Map
    final result = Map<String, dynamic>.from(response);
    // Access values
    final success = result['success'];
    final regionId = result['region_id'];
    final message = result['message'];

    print("Success: $success, Region ID: $regionId, Message: $message");

    return result;
  } catch (e) {
    print("Error in addRegion: $e");
    rethrow;
  }
}


  Future<void> fetchRegionList(String companyId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final regions = await repo.fetchRegionList(companyId);
      state = state.copyWith(
        isLoading: false,
        regionList: AsyncValue.data(regions),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  

  Future<Map<String, dynamic>> deleteRegion(int regionId, String companyId) async {
    try {
      final response = await repo.deleteRegion(regionId, companyId);
      final result = Map<String, dynamic>.from(response); // ensure Map
      print("Delete API returned: $result"); // debug log
      return result;
    } catch (e) {
      print("Delete error: $e");
      return {'status': 0, 'message': 'Something went wrong'};
    }
  }

}
