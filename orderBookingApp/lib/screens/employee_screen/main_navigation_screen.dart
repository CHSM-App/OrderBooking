import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/screens/employee_screen/orders_page.dart';

import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/notification_page.dart';
import 'package:order_booking_app/screens/theme.dart';

import 'home_page.dart';
import 'shops_page.dart';
import 'catalog_page.dart';
import 'profile_page.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;
  // bool _hasRequestedCheckinStatus = false;

  final List<Widget> _pages = const [
    HomePage(),
    ShopListPage(),
    OrdersListPage(),
    CatalogPage(),
    ProfilePage(),
  ];

  final int _notificationCount = 3;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // ✅ Load login data from storage then fetch today's check-in status
    Future.microtask(() async {
      await ref.read(adminloginViewModelProvider.notifier).loadFromStorage();
      final userId = ref.read(adminloginViewModelProvider).userId;
      if (userId != 0) {
        await ref.read(checkInViewModelProvider.notifier).loadTodayStatus(userId);
      }
    });
  }

  void _toggleCheckIn() async {
    final loginState = ref.read(adminloginViewModelProvider);
    final checkInState = ref.read(checkInViewModelProvider);
    final userId = loginState.userId;

    try {
      if (checkInState.isCheckedIn) {
        // CHECK OUT
        await ref.read(checkInViewModelProvider.notifier).checkOut(userId);
      } else {
        // CHECK IN
        await ref.read(checkInViewModelProvider.notifier).checkIn(userId);
      }

      // ✅ Show message from ViewModel state
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
          // Clear message after showing
          ref.read(checkInViewModelProvider.notifier).clearMessage();
        }
      }
    } catch (e) {
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

    return Scaffold(
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
                // CircleAvatar(
                //   radius: 20,
                //   backgroundColor: Colors.white,
                //   child: Icon(
                //     Icons.person,
                //     color: AppTheme.accentColor,
                //     size: 26,
                //   ),
                // ),
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
                  onTap: checkInState.isLoading ? null : _toggleCheckIn,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCheckedIn ? const Color.fromARGB(255, 235, 13, 13) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        if (checkInState.isLoading)
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

              /// NOTIFICATIONS
              if (isCheckedIn)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: Colors.white,
                      iconSize: 26,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _notificationCount > 9
                                ? '9+'
                                : '$_notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: isCheckedIn ? _onTabTapped : null,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_rounded),
            label: 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
