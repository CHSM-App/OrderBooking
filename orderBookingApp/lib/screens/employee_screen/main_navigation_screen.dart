import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:order_booking_app/screens/employee_screen/orders_page.dart';

import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/theme.dart';

import 'home_page.dart';
import 'shops_page.dart';
import 'catalog_page.dart';
import 'profile_page.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({Key? key, this.initialIndex = 0})
    : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;
  bool _isLocating = false;

  final List<Widget> _pages = const [
    HomePage(),
    ShopListPage(),
    OrdersListPage(),
    CatalogPage(),
    ProfilePage(),
  ];

  // Nav items: icon + label
  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.store_outlined,
      activeIcon: Icons.store_rounded,
      label: 'Shops',
    ),
    _NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Orders',
    ),
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Catalog',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    Future.microtask(() async {
      await ref.read(adminloginViewModelProvider.notifier).loadFromStorage();
      final userId = ref.read(adminloginViewModelProvider).userId;
      if (userId != 0) {
        await ref
            .read(checkInViewModelProvider.notifier)
            .loadTodayStatus(userId);
      }

      await ref
          .read(visitViewModelProvider.notifier)
          .fetchEmployeeVisits(userId);
    });
  }

  void _toggleCheckIn() async {
    final loginState = ref.read(adminloginViewModelProvider);
    final checkInState = ref.read(checkInViewModelProvider);
    final userId = loginState.userId;

    try {
      if (mounted) {
        setState(() => _isLocating = true);
      }
      final position = await _getCurrentLocation();
      if (mounted) {
        setState(() => _isLocating = false);
      }
      if (position == null) return;
      if (checkInState.isCheckedIn) {
        await ref
            .read(checkInViewModelProvider.notifier)
            .checkOut(userId, position.latitude, position.longitude);
      } else {
        await ref
            .read(checkInViewModelProvider.notifier)
            .checkIn(userId, position.latitude, position.longitude);
      }

      if (mounted) {
        final updatedState = ref.read(checkInViewModelProvider);
        if (updatedState.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(updatedState.message!),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          ref.read(checkInViewModelProvider.notifier).clearMessage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
      }
      if (mounted) {
        final errorState = ref.read(checkInViewModelProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorState.error ?? 'An error occurred'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services to check in.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        await Geolocator.openLocationSettings();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required to check in.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  void _onTabTapped(int index) {
    if (!ref.read(checkInViewModelProvider).isCheckedIn) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(adminloginViewModelProvider);
    final checkInState = ref.watch(checkInViewModelProvider);

    final employeeName = loginState.name ?? "Employee";
    final isCheckedIn = checkInState.isCheckedIn;

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,

        /// ================= APP BAR =================
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 12,

              /// PROFILE + NAME
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      employeeName.isNotEmpty
                          ? employeeName[0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Hello,",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        employeeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// ACTIONS
              actions: [
                /// CHECK IN / OUT BUTTON
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: (checkInState.isLoading || _isLocating)
                        ? null
                        : _toggleCheckIn,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isCheckedIn
                            ? const Color.fromARGB(255, 235, 13, 13)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          if (checkInState.isLoading || _isLocating)
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCheckedIn
                                      ? Colors.white
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            )
                          else
                            Icon(
                              isCheckedIn ? Icons.logout : Icons.login,
                              size: 14,
                              color: isCheckedIn
                                  ? Colors.white
                                  : AppTheme.primaryColor,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            isCheckedIn ? "Check Out" : "Check In",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isCheckedIn
                                  ? Colors.white
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // /// NOTIFICATIONS
                // if (isCheckedIn)
                //   Stack(
                //     children: [
                //       IconButton(
                //         icon: const Icon(Icons.notifications_outlined),
                //         color: Colors.white,
                //         iconSize: 26,
                //         onPressed: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (_) => const NotificationPage(),
                //             ),
                //           );
                //         },
                //       ),
                //       if (_notificationCount > 0)
                //         Positioned(
                //           right: 6,
                //           top: 6,
                //           child: Container(
                //             padding: const EdgeInsets.all(3),
                //             decoration: const BoxDecoration(
                //               color: Colors.red,
                //               shape: BoxShape.circle,
                //             ),
                //             constraints: const BoxConstraints(
                //               minWidth: 16,
                //               minHeight: 16,
                //             ),
                //             child: Text(
                //               _notificationCount > 9
                //                   ? '9+'
                //                   : '$_notificationCount',
                //               style: const TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 9,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //           ),
                //         ),
                //     ],
                //   ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),

        /// ================= BODY =================
        body: Stack(
          children: [
            IgnorePointer(
              ignoring: !isCheckedIn,
              child: IndexedStack(index: _currentIndex, children: _pages),
            ),
            if (!isCheckedIn)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Please Check In to Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        /// ================= CUSTOM PILL BOTTOM NAV =================
        bottomNavigationBar: _PillBottomNavBar(
          currentIndex: _currentIndex,
          isEnabled: isCheckedIn,
          items: _navItems,
          onTap: _onTabTapped,
          activeColor: AppTheme.primaryColor,
        ),
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
  final bool isEnabled;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final Color activeColor;

  const _PillBottomNavBar({
    required this.currentIndex,
    required this.isEnabled,
    required this.items,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Derive a soft background color from activeColor (low opacity)
    final Color pillBg = activeColor.withOpacity(0.12);
    final Color inactiveColor = Colors.grey.shade500;

    return Container(
      // Outer container: white background with top border shadow
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
      // Add bottom safe-area padding
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
            onTap: isEnabled ? () => onTap(index) : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              // Pill stretches to fit icon + label when active, shrinks to icon-only when inactive
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
                  // Animate label in/out
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
