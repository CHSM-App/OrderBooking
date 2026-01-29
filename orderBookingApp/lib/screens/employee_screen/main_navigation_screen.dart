import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/theme.dart';
import 'home_page.dart';
import 'shops_page.dart';
import 'orders_page.dart';
import 'catalog_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isCheckedIn = false;
  bool _isLoading = true;

  static const String _checkInKey = "is_checked_in";

  final List<Widget> _pages = const [
    HomePage(),
    ShopsPage(),
    OrdersPage(),
    CatalogPage(),
    ProfilePage(mobileNo: '8416113132'),
  ];

  final String _employeeName = "Ramesh Kumar";
  final int _notificationCount = 3;

  @override
  void initState() {
    super.initState();
    _restoreCheckInState();
  }

  /// RESTORE CHECK-IN STATE
  Future<void> _restoreCheckInState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCheckedIn = prefs.getBool(_checkInKey) ?? false;
      _isLoading = false;
    });
  }

  /// SAVE CHECK-IN STATE
  Future<void> _persistCheckInState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_checkInKey, value);
  }







void _toggleCheckIn() async {
  final empId = ref.read(adminloginViewModelProvider).userId;
  final vm = ref.read(checkInViewModelProvider.notifier);

  // 🚫 prevent double tap while loading
  if (ref.read(checkInViewModelProvider).isLoading) return;

  final wasCheckedIn = _isCheckedIn;

  // ✅ IMMEDIATELY UPDATE UI
  setState(() {
    _isCheckedIn = !wasCheckedIn;
    _currentIndex = 0;
  });

  await _persistCheckInState(!wasCheckedIn);

  try {
    if (wasCheckedIn) {
      await vm.checkOut(empId);
    } else {
      await vm.checkIn(empId);
    }
  } catch (e) {
    // 🔁 rollback UI if API fails
    setState(() {
      _isCheckedIn = wasCheckedIn;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

  /// TOGGLE CHECK-IN / CHECK-OUT
 
  // void _toggleCheckIn() async {
  //   final newValue = !_isCheckedIn;
  //   setState(() {
  //     _isCheckedIn = newValue;
  //     _currentIndex = 0;
  //   });
  //   ref.read(checkInViewModelProvider.notifier).checkIn(  ref.read(adminloginViewModelProvider).userId,);
  //   // ref.read(checkInViewModelProvider.notifier).checkOut(  ref.read(adminloginViewModelProvider).userId,);
  //   await _persistCheckInState(newValue);

  //   // 🔥 Later:
  //   // ref.read(attendanceViewModelProvider.notifier).checkIn();
  //   // ref.read(attendanceViewModelProvider.notifier).checkOut();
  // }

  void _onTabTapped(int index) {
    if (!_isCheckedIn) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Hello,",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Text(
                      _employeeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                  onTap: _toggleCheckIn,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          _isCheckedIn ? Colors.redAccent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCheckedIn
                              ? Icons.logout
                              : Icons.login,
                          size: 14,
                          color: _isCheckedIn
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isCheckedIn ? "Check Out" : "Check In",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isCheckedIn
                                ? Colors.white
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// NOTIFICATION ICON
              if (_isCheckedIn)
                Stack(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.notifications_outlined),
                      color: Colors.white,
                      iconSize: 26,
                      onPressed: () {},
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
            ignoring: !_isCheckedIn,
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          if (!_isCheckedIn)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 50,
                      color: Colors.white,
                    ),
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
        onTap: _isCheckedIn ? _onTabTapped : null,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store_rounded), label: 'Shops'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Catalog'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }
}
