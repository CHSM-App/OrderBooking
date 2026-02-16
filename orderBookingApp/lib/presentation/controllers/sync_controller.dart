import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:order_booking_app/presentation/providers/connectivity_provider.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

final syncControllerProvider = Provider<void>((ref) {
  // Listen to connectivity changes
  ref.listen<AsyncValue<List<ConnectivityResult>>>(
    connectivityProvider,
    (previous, next) async {
      final wasOffline = previous?.value?.contains(ConnectivityResult.none) ?? true;
      final isOnline = next.value != null && !next.value!.contains(ConnectivityResult.none);
      
          final companyId = ref.read(adminloginViewModelProvider).companyId??"";
          final userId = ref.read(adminloginViewModelProvider).userId;
          final regionId = ref.read(adminloginViewModelProvider).regionId?? 0;
      // Trigger sync only when transitioning from offline -> online
      if (wasOffline && isOnline && companyId.isNotEmpty && userId !=null ) {
        try {
          // Call sync methods for all offline data
          await ref.read(visitViewModelProvider.notifier).sync();
          await ref.read(shopViewModelProvider.notifier).getEmpShopList(companyId, regionId);
          await ref.read(productViewModelProvider.notifier).fetchProductList(companyId);
          await ref.read(ordersViewModelProvider.notifier).getAllOrders(userId);
         // await ref.read(regionofflineViewModelProvider.notifier).fetchRegions(companyId);

        } catch (e) {

        }
      }
    },
  );
});
