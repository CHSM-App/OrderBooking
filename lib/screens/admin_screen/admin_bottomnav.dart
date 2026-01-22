import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/admin_screen/admin_catalog_page.dart';
import 'package:order_booking_app/screens/admin_screen/admin_home_screen.dart';
import 'package:order_booking_app/screens/admin_screen/admin_orderdetails.dart';
import 'package:order_booking_app/screens/admin_screen/admin_profilescreen.dart';
import 'package:order_booking_app/screens/admin_screen/employeelist_screen.dart';
import 'admin_addEmployee.dart';
import 'admin_addProduct.dart';
import 'admin_employeeDetails.dart';
import 'admin_notifications.dart';

// ============================================
// SINGLE UNIFIED ADMIN DASHBOARD
// ============================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  int _ordersInitialTab = 0;

  void navigateToTab(int index, {int ordersTab = 0}) {
    setState(() {
      _selectedIndex = index;
      _ordersInitialTab = ordersTab;
    });
  }

  // Page titles
  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return "Admin Dashboard";
      case 1:
        return "Catalog";
      case 2:
        return "Orders";
      case 3:
        return "Employees";
      case 4:
        return "Profile";
      default:
        return "Admin Dashboard";
    }
  }

  // Pages
  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return AdminHomePage(onNavigate: navigateToTab);
      case 1:
        return const AdminCatalogPage();
      case 2:
        return AdminOrdersPage(initialTabIndex: _ordersInitialTab);
      case 3:
        return const AdminEmployeesPage();
      case 4:
        return const AdminProfilePage(mobileNo: '9876543210',);
      default:
        return AdminHomePage(onNavigate: navigateToTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============ APPBAR ============
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Open profile or drawer
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _currentTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminNotificationPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ============ BODY ============
      body: _currentPage,

      // ============ BOTTOM NAVIGATION ============
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => navigateToTab(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 8,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: "Catalog",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: "Employees",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}