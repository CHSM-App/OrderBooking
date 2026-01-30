import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/usecase/region.dart';

class RegionofflineViewModel extends StateNotifier<AsyncValue<List<Region>>> {
  final RegionUsecaseoffline repo;

  RegionofflineViewModel(this.repo) : super(const AsyncValue.loading()) {
    fetchRegions();
  }

  /// Fetch merged offline + server regions
  Future<void> fetchRegions() async {
    try {
      state = const AsyncValue.loading();
      final regions = await repo.fetchRegions();
      state = AsyncValue.data(regions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add region offline + sync
  Future<void> addRegion(Region region) async {
    try {
      state = AsyncValue.loading();
      await repo.saveRegionOffline(region);
      await repo.syncOfflineRegions();
      await fetchRegions(); // refresh UI after sync
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Manual sync trigger
  Future<void> sync() async {
    try {
      await repo.syncOfflineRegions();
      await fetchRegions(); // refresh after sync
    } catch (_) {}
  }
}
