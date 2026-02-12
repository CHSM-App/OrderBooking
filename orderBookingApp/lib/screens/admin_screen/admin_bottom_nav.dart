import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_catalog_page.dart';
import 'package:order_booking_app/screens/admin_screen/admin_home_screen.dart';
import 'package:order_booking_app/screens/admin_screen/admin_orderList.dart';
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

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Nav items with icons + labels
  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Catalog'),
    _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded, label: 'Orders'),
    _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Employees'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final notifier = ref.read(adminloginViewModelProvider.notifier);
      await notifier.loadFromStorage();

      final mobileNo = ref.read(adminloginViewModelProvider).mobileNo;
      if (mobileNo != null && mobileNo.isNotEmpty) {
        await notifier.fetchAdminDetails(mobileNo);
      }
    });

    ref.read(employeeloginViewModelProvider.notifier).getEmployeeList(
          ref.read(adminloginViewModelProvider).companyId ?? '',
        );

    ref.read(ordersViewModelProvider.notifier).getOrderList(
          ref.read(adminloginViewModelProvider).companyId ?? '',
        );

    final adminId = ref.read(adminloginViewModelProvider).userId;
    if (adminId != 0) {
      ref.read(productViewModelProvider.notifier).fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    }
  }

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
        return AdminProfilePage(
          mobileNo: ref.read(adminloginViewModelProvider).mobileNo ?? '',
        );
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

    // Admin brand color
    const Color adminColor = Color(0xFFF57C00);

    return Scaffold(
      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: adminColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                adminName != null && adminName.isNotEmpty
                    ? adminName[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: adminColor,
                ),
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

      // ================= CUSTOM PILL BOTTOM NAV =================
      bottomNavigationBar: _PillBottomNavBar(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: navigateToTab,
        activeColor: adminColor,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Data class for nav items
// ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─────────────────────────────────────────────
// Custom Pill Bottom Navigation Bar
// ─────────────────────────────────────────────
class _PillBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final Color activeColor;

  const _PillBottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color pillBg = activeColor.withOpacity(0.12);
    final Color inactiveColor = Colors.grey.shade500;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isActive = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: isActive
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? pillBg : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: 26,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: isActive
                        ? Row(
                            children: [
                              const SizedBox(width: 6),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: activeColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
