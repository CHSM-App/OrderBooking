import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/login_screen.dart';
import 'package:order_booking_app/screens/employee_screen/main_navigation_screen.dart';
import 'package:order_booking_app/screens/admin_screen/admin_bottomnav.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Load from TokenStorage via AdminloginViewModel
    await ref.read(adminloginViewModelProvider.notifier).loadFromStorage();
    final state = ref.read(adminloginViewModelProvider);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final loginInfo = state.phoneCheckResult.value?.first;

    if (loginInfo != null && loginInfo.roleId != null) {
      if (loginInfo.roleId == 1) {
        // Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (loginInfo.roleId == 2) {
        // Employee
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        // Unknown role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      // Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
