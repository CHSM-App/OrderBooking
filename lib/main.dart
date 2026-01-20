import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/near_shop_screen.dart';
import 'screens/landing_Screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_catalog_screen.dart';


import 'screens/admin_dashboard_screen.dart';



import 'screens/order_history_screen.dart';
import 'screens/create_order_screen.dart';

void main() {
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const EmployeePortalApp(),
        '/otp': (context) => const OTPScreen(),
        '/home': (context) => const HomeScreen(),
        '/product-catalog': (context) => const ProductCatalogScreen(),
        '/nearby-shops': (context) => const NearbyShopsScreen(),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/create-order': (context) => const CreateOrderScreen(),

        // Admin
        '/dashboard': (context) => const AdminDashboardScreen(),
        
      },
    );
  }
}