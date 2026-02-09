  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';

  import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
  import 'package:order_booking_app/screens/admin_screen/admin_catalog_page.dart';
  import 'package:order_booking_app/screens/admin_screen/admin_home_screen.dart';
  import 'package:order_booking_app/screens/admin_screen/admin_orderdetails.dart';
  import 'package:order_booking_app/screens/admin_screen/admin_profilescreen.dart';
  import 'package:order_booking_app/screens/admin_screen/employeelist_screen.dart';
  import 'admin_notifications.dart';

  // ============================================
  // SINGLE UNIFIED ADMIN DASHBOARD
  // ============================================

  class AdminDashboardScreen extends ConsumerStatefulWidget {
    const AdminDashboardScreen({Key? key}) : super(key: key);

    @override
    ConsumerState<AdminDashboardScreen> createState() =>
        _AdminDashboardScreenState();
  }

  class _AdminDashboardScreenState
      extends ConsumerState<AdminDashboardScreen> {
    int _selectedIndex = 0;

    // @override
    // void initState() {
    //   super.initState();

    //   /// Load admin data from local storage
    //   Future.microtask(() {
    //     ref.read(adminloginViewModelProvider.notifier).loadFromStorage();
    //   });

    //   Future.microtask(() {
    //     ref.watch(adminloginViewModelProvider.notifier).fetchAdminDetails(ref.read(adminloginViewModelProvider).mobileNo?? '');
    //   });


    // }


    @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final notifier =
          ref.read(adminloginViewModelProvider.notifier);

      await notifier.loadFromStorage();

      final mobileNo =
          ref.read(adminloginViewModelProvider).mobileNo;

      if (mobileNo != null && mobileNo.isNotEmpty) {
        await notifier.fetchAdminDetails(mobileNo);
      }
    });


   
      ref
          .read(employeeloginViewModelProvider.notifier).getEmployeeList(ref.read(adminloginViewModelProvider).companyId ?? '',);
  

    
      final adminId = ref.read(adminloginViewModelProvider).userId;

    
        ref.read(ordersViewModelProvider.notifier).getOrderList(ref.read(adminloginViewModelProvider).companyId ?? '',);
      

      if (adminId != 0) {
        ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).companyId??"");
      }
    
  }

    // ✅ FIXED CALLBACK SIGNATURE
    void navigateToTab(int index, {int ordersTab = 0}) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedIndex = index;
      });
    }

    // ================= CURRENT PAGE =================
    Widget get _currentPage {
      switch (_selectedIndex) {
        case 0:
          return AdminHomePage(onNavigate: navigateToTab);

        case 1:
          return const AdminCatalogPage();

      case 2:
    return OrdersListPage();

        case 3:
          return const AdminEmployeesPage();
        
        case 4:
          return AdminProfilePage(mobileNo: ref.read(adminloginViewModelProvider).mobileNo ?? '',);

        default:
          return AdminHomePage(onNavigate: navigateToTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(adminloginViewModelProvider);

    final adminName = loginState.adminDetails?.maybeWhen(
      data: (list) => list.isNotEmpty ? list.first.adminName : '',
      orElse: () => '',
    );

    return Scaffold(
      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF57C00),
        elevation: 0,
        automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color(0xFFF57C00),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $adminName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
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
          ],
        ),

        // ================= BODY =================
        body: _currentPage,

        // ================= BOTTOM NAV =================
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => navigateToTab(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFF57C00),
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
