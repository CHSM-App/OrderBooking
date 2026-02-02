import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:order_booking_app/presentation/providers/connectivity_provider.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';


final syncControllerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<ConnectivityResult>>>(
    connectivityProvider,
    (previous, next) {
      final wasOffline =
          previous?.value?.contains(ConnectivityResult.none) ??
          true;

      final isOnline =
          next.value != null &&
          !next.value!.contains(ConnectivityResult.none);

      if (wasOffline && isOnline) {
        ref .read(visitViewModelProvider.notifier).sync();

               
        ref.read(regionofflineViewModelProvider.notifier).sync();
        ref.read(shopViewModelProvider.notifier).sync();
        ref.read(ordersViewModelProvider.notifier).syncOfflineOrders();
      }
    },
  );
});

