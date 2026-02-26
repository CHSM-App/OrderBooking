import 'dart:async';

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
  static const int _profileIndex = 4;

  final List<Widget> _pages = const [
    HomePage(),
    ShopListPage(),
    OrdersListPage(),
    CatalogPage(),
    ProfilePage(),
  ];

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
      label: 'Products',
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
      final isConnected =
          await ref.read(networkServiceProvider).checkRealInternet();
      if (!isConnected) {
        if (mounted) {
          final actionText =
              checkInState.isCheckedIn ? 'check out' : 'check in';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'You are offline. Please go online to $actionText.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

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
              content:
                  Text('Location permission is required to check in.'),
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
                        style:
                            TextStyle(color: Colors.white, fontSize: 15),
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

              actions: [
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
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),

        /// ================= BODY =================
        body: Stack(
          children: [
            IgnorePointer(
              ignoring: !isCheckedIn && _currentIndex != _profileIndex,
              child:
                  IndexedStack(index: _currentIndex, children: _pages),
            ),
            if (!isCheckedIn && _currentIndex != _profileIndex)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 50, color: Colors.white),
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
          isEnabled: true,
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
// Enum: what the banner is currently showing
// ─────────────────────────────────────────────
enum _BannerMode { hidden, offline, online }

// ─────────────────────────────────────────────
// Custom Pill Bottom Navigation Bar
// Now with an integrated network status banner
// ─────────────────────────────────────────────
class _PillBottomNavBar extends ConsumerStatefulWidget {
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
  ConsumerState<_PillBottomNavBar> createState() =>
      _PillBottomNavBarState();
}

class _PillBottomNavBarState extends ConsumerState<_PillBottomNavBar>
    with SingleTickerProviderStateMixin {
  _BannerMode _bannerMode = _BannerMode.hidden;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _handleNetworkChange(bool? previous, bool current) {
    if (previous == false && current == true) {
      // Just came back online → show green "Back Online" briefly
      _hideTimer?.cancel();
      setState(() => _bannerMode = _BannerMode.online);
      _animController.forward(from: 0);

      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) _hideBanner();
      });
    } else if (previous == true && current == false) {
      // Just went offline → show grey "No Internet" persistently
      _hideTimer?.cancel();
      setState(() => _bannerMode = _BannerMode.offline);
      _animController.forward(from: 0);
    } else if (previous == null && current == false) {
      // Initial load and already offline
      setState(() => _bannerMode = _BannerMode.offline);
      _animController.forward(from: 0);
    }
  }

  void _hideBanner() {
    _animController.reverse().then((_) {
      if (mounted) setState(() => _bannerMode = _BannerMode.hidden);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to network status changes
    ref.listen<AsyncValue<bool>>(networkStatusProvider, (previous, next) {
      next.whenData((isConnected) {
        _handleNetworkChange(previous?.value, isConnected);
      });
    });

    // Also react on first load if already offline
    final networkStatus = ref.watch(networkStatusProvider);
    networkStatus.whenData((isConnected) {
      if (!isConnected &&
          _bannerMode == _BannerMode.hidden &&
          _animController.isDismissed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _bannerMode = _BannerMode.offline);
            _animController.forward(from: 0);
          }
        });
      }
    });

    final Color pillBg = widget.activeColor.withValues(alpha: 0.12);
    final Color inactiveColor = Colors.grey.shade500;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Nav icons row ──
          Padding(
            padding: EdgeInsets.only(
              top: 14,
              bottom: _bannerMode != _BannerMode.hidden ? 8 : 14,
              left: 8,
              right: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final bool isActive = widget.currentIndex == index;

                return GestureDetector(
                  onTap:
                      widget.isEnabled ? () => widget.onTap(index) : null,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: isActive
                        ? const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10)
                        : const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
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
                          color: isActive
                              ? widget.activeColor
                              : inactiveColor,
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
                                        color: widget.activeColor,
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
          ),

          // ── Network banner — AnimatedSize grows the nav bar upward ──
          // so the entire bottom bar shifts up smoothly when banner appears
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: _bannerMode != _BannerMode.hidden
                ? FadeTransition(
                    opacity: _fadeAnim,
                    child: _NetworkBannerStrip(
                      mode: _bannerMode,
                      bottomPadding: bottomPadding,
                    ),
                  )
                : SizedBox(
                    // Preserve safe-area padding even when banner is hidden
                    // so the nav icons don't shift down when it disappears
                    width: double.infinity,
                    height: bottomPadding,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// The thin strip that shows inside the nav bar
// ─────────────────────────────────────────────
class _NetworkBannerStrip extends StatelessWidget {
  final _BannerMode mode;
  final double bottomPadding;

  const _NetworkBannerStrip({
    required this.mode,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOffline = mode == _BannerMode.offline;

    final Color bgColor = isOffline
        ? const Color(0xFFEEEEEE)
        : const Color.fromARGB(255, 0, 163, 14);

    final Color textColor = isOffline
        ? const Color(0xFF757575)
        : const Color.fromARGB(255, 255, 255, 255);

    final IconData icon =
        isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded;

    final String message =
        isOffline ? 'No internet connection' : 'Back online';

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: EdgeInsets.only(
        top: 5,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            message,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
