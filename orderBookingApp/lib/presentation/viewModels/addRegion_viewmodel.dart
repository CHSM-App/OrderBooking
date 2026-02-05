import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/usecase/add_region_usecase.dart';

/// STATE (INSIDE SAME FILE)
// class RegionState {
//   final bool isLoading;
//   final String? error;
//   final AsyncValue<List<Region>>? regionList;

//   const RegionState({
//     this.isLoading = false,
//     this.error,
//     this.regionList = const AsyncValue.loading(),
//   });

//   RegionState copyWith({
//     bool? isLoading,
//     String? error,
//     AsyncValue<List<Region>>? regionList,
//   }) {
//     return RegionState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       regionList: regionList ?? this.regionList,
//     );
//   }
// }

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


/// VIEWMODEL
class RegionViewModel extends StateNotifier<RegionState> {
  final AddRegionUsecase usecase;

  RegionViewModel(this.usecase) : super(RegionState());

  /// ADD REGION
  Future<void> addRegion(Region region) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await usecase.addRegion(region);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  //GET REGION LIST
  Future<void> getRegionList(String companyId) async {
    state = state.copyWith(isLoading: true, error: null, regionList: const AsyncValue.loading(),) ;
    try {
      final regions = await usecase.getRegionList(companyId);
      state = state.copyWith(
        isLoading: false,
        regionList: AsyncValue.data(regions),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}


