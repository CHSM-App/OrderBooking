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

      // Trigger sync only when transitioning from offline -> online
      if (wasOffline && isOnline) {
        try {
          // Call sync methods for all offline data
          await ref.read(visitViewModelProvider.notifier).sync();
          await ref.read(regionofflineViewModelProvider.notifier).sync();
          await ref.read(shopViewModelProvider.notifier).sync(ref.read(adminloginViewModelProvider).companyId??"");
          await ref.read(productViewModelProvider.notifier).syncProducts();
          await ref.read(ordersViewModelProvider.notifier)
              .syncOfflineOrders(ref.read(adminloginViewModelProvider).userId);

          print("✅ All offline data synced successfully");
        } catch (e, st) {
          print("⚠️ Sync failed: $e \n $st");
        }
      }
    },
  );
});
