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

  /// Fetch merged offline + server regions
  Future<void> fetchRegions(String companyID) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final regions = await repo.fetchRegions(companyID);
      state = state.copyWith(
        isLoading: false,
        regionList: AsyncValue.data(regions),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add region offline + sync
  Future<void> addRegion(Region region) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await repo.saveRegionOffline(region);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Manual sync trigger
  Future<void> sync(String companyID) async {
    fetchRegions(companyID);
  }
}
