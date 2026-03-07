
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/token_provider.dart';
import 'package:order_booking_app/presentation/controllers/sync_controller.dart';
import 'package:order_booking_app/screens/splash_screen.dart';
import 'package:order_booking_app/screens/theme.dart';
 
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();//Global navigator access
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =GlobalKey<ScaffoldMessengerState>();//Global scaffold messenger access

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(tokenProvider.notifier).loadTokens();
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


//checking changes










// on:
//   pull_request:
//     branches:
//       - main
//       - master
//   push:
//     branches:
//       - main
//       - master
//       - develop
// name: "Build & Release"
// jobs:
//   build:
//     name: Build & Release
//     runs-on: macos-latest
//     steps:
//       - uses: actions/checkout@v3
//       - uses: subosito/flutter-action@v2
//         with:
//           channel: 'stable'
//           architecture: x64

//       - run: flutter build apk --release --split-per-abi
//       - name: Push to Releases
//         uses: ncipollo/release-action@v1
//         with:
//           artifacts: "build/app/outputs/apk/release/*"
//           tag: v1.0.${{ github.run_number }}
//           token: ${{ secrets.TOKEN }}






// # push to master, main, develop
// # pull request on main master
