import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/controllers/sync_controller.dart';
import 'package:order_booking_app/screens/employee_screen/login_screen.dart';
import 'package:order_booking_app/screens/theme.dart';
 
 
void main() {
   runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          ref.read(syncControllerProvider); // 👈 activate
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
     
      theme: AppTheme.lightTheme,
      //darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      
      home: const LoginScreen(),
    );
  }
}
 