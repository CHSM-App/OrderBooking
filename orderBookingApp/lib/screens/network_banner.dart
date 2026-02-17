// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

// class NetworkBanner extends ConsumerStatefulWidget {
//   const NetworkBanner({super.key});

//   @override
//   ConsumerState<NetworkBanner> createState() => _NetworkBannerState();
// }

// class _NetworkBannerState extends ConsumerState<NetworkBanner> {
//   bool _isDismissed = false;
//   bool _showOnlineBanner = false;

//   @override
//   Widget build(BuildContext context) {
//     final networkStatus = ref.watch(networkStatusProvider);

//     // Listen for connection changes
//     ref.listen<AsyncValue<bool>>(networkStatusProvider, (previous, next) {
//       next.whenData((isConnected) {
//         final previousValue = previous?.value;
        
//         // Check if connection changed from false to true
//         if (previousValue == false && isConnected == true) {
//           setState(() {
//             _isDismissed = false;
//             _showOnlineBanner = true;
//           });

//           // Auto-hide online banner after 3 seconds
//           Future.delayed(const Duration(seconds: 3), () {
//             if (mounted) {
//               setState(() => _showOnlineBanner = false);
//             }
//           });
//         } else if (previousValue == true && isConnected == false) {
//           // Connection lost
//           setState(() {
//             _showOnlineBanner = false;
//             _isDismissed = false;
//           });
//         }
//       });
//     });

//     return networkStatus.when(
//       data: (isConnected) {
//         // Show "Back Online" banner
//         if (_showOnlineBanner && isConnected) {
//           return Material(
//             color: Colors.transparent,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.green.shade400, Colors.green.shade600],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: const SafeArea(
//                 top: false,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.wifi_rounded,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       "Back Online",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.2,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Icon(
//                       Icons.check_circle,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }

//         // Show "No Internet" banner
//         if (!isConnected && !_isDismissed) {
//           return Material(
//             color: Colors.transparent,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.red.shade400, Colors.red.shade600],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 top: false,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.wifi_off_rounded,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     const Expanded(
//                       child: Text(
//                         "No Internet Connection",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     InkWell(
//                       onTap: () {
//                         setState(() => _isDismissed = true);
//                       },
//                       borderRadius: BorderRadius.circular(20),
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }

//         return const SizedBox.shrink();
//       },
//       loading: () => const SizedBox.shrink(),
//       error: (_, __) => const SizedBox.shrink(),
//     );
//   }
// }