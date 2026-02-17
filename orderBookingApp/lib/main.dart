

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/controllers/sync_controller.dart';
import 'package:order_booking_app/screens/splash_screen.dart';
import 'package:order_booking_app/screens/theme.dart';
 
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();//Global navigator access
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =GlobalKey<ScaffoldMessengerState>();//Global scaffold messenger access

void main() {
  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          ref.read(syncControllerProvider);
          return const EmployeePortalApp();
        },
      ),
    ),
  );
}

class EmployeePortalApp extends StatelessWidget {
  const EmployeePortalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Portal',
      debugShowCheckedModeBanner: false,
          builder: (context, child) {
      return Stack(
        children: [
          child!,
          Padding(
            padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
            child: const Align(
              alignment: Alignment.bottomCenter,
              // child: NetworkBanner(),
            ),
          ),
        ],
      );
    },
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(), // ✅ Auto-login logic
    );
  }
}
