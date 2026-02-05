import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/shop_viewmodel.dart';
import 'package:order_booking_app/screens/employee_screen/add_shop_screen.dart';
import 'package:order_booking_app/screens/employee_screen/shop_visit_screen.dart';
import 'package:order_booking_app/screens/theme.dart';
import 'package:uuid/uuid.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'dart:math' as math;

class ShopListPage extends ConsumerStatefulWidget {
  const ShopListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends ConsumerState<ShopListPage> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerSlideAnimation = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _headerAnimationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopViewModelProvider.notifier).getShopList(
        ref.read(adminloginViewModelProvider).companyId ?? ""
      );
    });
    
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase().trim();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  List<ShopDetails> _filterShops(List<ShopDetails> shops) {
    if (_searchQuery.isEmpty) return shops;

    return shops.where((shop) {
      final shopName = shop.shopName?.toLowerCase() ?? '';
      final ownerName = shop.ownerName?.toLowerCase() ?? '';
      final address = shop.address?.toLowerCase() ?? '';
      final phone = shop.mobileNo?.toLowerCase() ?? '';
      final email = shop.email?.toLowerCase() ?? '';

      return shopName.contains(_searchQuery) ||
          ownerName.contains(_searchQuery) ||
          address.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          email.contains(_searchQuery);
    }).toList();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        final shouldOpenSettings = await _showLocationServiceDialog();
        if (shouldOpenSettings) {
          await Geolocator.openLocationSettings();
          await Future.delayed(const Duration(seconds: 1));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) return null;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showPermissionDeniedDialog();
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        final shouldOpenSettings = await _showPermissionPermanentlyDeniedDialog();
        if (shouldOpenSettings) {
          await Geolocator.openAppSettings();
        }
      }
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Location request timed out. Please try again.');
        },
      );
      return position;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('timeout')
                  ? 'Location request timed out. Please try again.'
                  : 'Failed to get location: ${e.toString()}',
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  Future<bool> _showLocationServiceDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                contentPadding: const EdgeInsets.all(32),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.warningColor.withOpacity(0.2),
                            AppTheme.warningColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_off_rounded, 
                        color: AppTheme.warningColor, 
                        size: 48
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Location Service Disabled',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: const Text(
                  'Please enable location services to mark your visit to this shop.',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actionsPadding: const EdgeInsets.only(bottom: 8),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Enable',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ) ?? false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                contentPadding: const EdgeInsets.all(32),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.errorColor.withOpacity(0.2),
                            AppTheme.errorColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_disabled_rounded, 
                        color: AppTheme.errorColor, 
                        size: 48
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Permission Denied',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: const Text(
                  'Location permission is required to mark your shop visits. Please grant permission to continue.',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: const EdgeInsets.only(bottom: 8),
                actions: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showPermissionPermanentlyDeniedDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                contentPadding: const EdgeInsets.all(32),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.errorColor.withOpacity(0.2),
                            AppTheme.errorColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.block_rounded, 
                        color: AppTheme.errorColor, 
                        size: 48
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Permission Required',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: const Text(
                  'Location permission was permanently denied. Please enable it from app settings to mark shop visits.',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actionsPadding: const EdgeInsets.only(bottom: 8),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ) ?? false;
  }

  Future<void> _onShopTap(ShopDetails shop) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Getting your location...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        letterSpacing: -0.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait a moment',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    try {
      final position = await _getCurrentLocation();
      if (mounted) Navigator.pop(context);
      if (position == null) return;

      final visit = VisitPayload(
        localId: const Uuid().v4(),
        shopId: shop.shopId ?? 0,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        capturedAt: DateTime.now(),
        punchIn: DateTime.now().toLocal().toIso8601String(),
        employeeId: ref.read(adminloginViewModelProvider).userId,
      );
      
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ShopVisitScreen(shop: shop, visit: visit),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: ${e.toString()}',
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern Header with Stats
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _headerAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _headerSlideAnimation.value),
                      child: Opacity(
                        opacity: _headerFadeAnimation.value,
                      //  child: _buildModernHeader(shopState),
                      ),
                    );
                  },
                ),
              ),

              // Search Bar
            SliverToBoxAdapter(
  child: Column(
    children: [
      const SizedBox(height: 12), // <-- small space above
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: _buildModernSearchBar(),
      ),
    ],
  ),
),

              // Shop List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildSliverBody(shopState),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ],
      ),
      
      floatingActionButton: _buildModernFAB(shopState),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernSearchBar() {
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, owner, location...',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.4),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFAB(ShopState shopState) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddShopScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
              
              if (result == true && mounted) {
                ref.read(shopViewModelProvider.notifier).getShopList(
                  ref.read(adminloginViewModelProvider).companyId ?? ""
                );
              }
            },
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverBody(ShopState shopState) {
    if (shopState.isLoading && shopState.shopList == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Loading shops...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (shopState.error != null) {
      return SliverFillRemaining(
        child: _buildErrorState(shopState.error!),
      );
    }

    return shopState.shopList?.when(
          data: (shops) {
            _fabAnimationController.forward();
            final filteredShops = _filterShops(shops);
            
            if (filteredShops.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final shop = filteredShops[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: UltraModernShopCard(
                      shop: shop,
                      onTap: () => _onShopTap(shop),
                      searchQuery: _searchQuery,
                      index: index,
                    ),
                  );
                },
                childCount: filteredShops.length,
              ),
            );
          },
          loading: () => SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            ),
          ),
          error: (error, stack) => SliverFillRemaining(
            child: _buildErrorState(error.toString()),
          ),
        ) ??
        const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.accentColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    _searchQuery.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.store_mall_directory_rounded,
                    size: 100,
                    color: AppTheme.accentColor.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            _searchQuery.isNotEmpty ? 'No shops found' : 'No shops yet',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              letterSpacing: -1,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : 'Start by adding your first shop',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontFamily: 'Poppins',
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.clear_rounded, size: 22),
                label: const Text(
                  'Clear Search',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorColor.withOpacity(0.1),
                  AppTheme.errorColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(shopViewModelProvider.notifier).getShopList(
                  ref.read(adminloginViewModelProvider).companyId ?? ""
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 22),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================
// ULTRA MODERN SHOP CARD WIDGET
// ================================
class UltraModernShopCard extends StatefulWidget {
  final ShopDetails shop;
  final VoidCallback onTap;
  final String? searchQuery;
  final int index;

  const UltraModernShopCard({
    Key? key,
    required this.shop,
    required this.onTap,
    this.searchQuery,
    required this.index,
  }) : super(key: key);

  @override
  State<UltraModernShopCard> createState() => _UltraModernShopCardState();
}

class _UltraModernShopCardState extends State<UltraModernShopCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Generate gradient colors based on index for visual variety
   final List<Color> gradientColors = [
    const Color(0xFF667eea),
    const Color(0xFF764ba2),
  ];

  @override
  Widget build(BuildContext context) {
    //final gradientColors = _getGradientColors();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _isPressed
                      ? gradientColors[1].withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: _isPressed ? 16 : 20,
                  offset: Offset(0, _isPressed ? 4 : 8),
                  spreadRadius: _isPressed ? -2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Decorative gradient accent
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                      ),
                    ),
                  ),
                  
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Gradient Icon Container
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: gradientColors[1].withOpacity(0.4),
                            //     blurRadius: 12,
                            //     offset: const Offset(0, 6),
                            //   ),
                            // ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Subtle pattern overlay
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: DotPatternPainter(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.storefront_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // Shop Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Shop Name with badge
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.shop.shopName ?? 'Unknown Shop',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                        fontFamily: 'Poppins',
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                               
                                ],
                              ),
                              const SizedBox(height: 10),
                              
                              // Owner Name
                              if (widget.shop.ownerName != null)
                                _buildDetailRow(
                                  Icons.person_rounded,
                                  widget.shop.ownerName!,
                                  gradientColors[0],
                                ),
                              
                              // Phone Number
                              if (widget.shop.mobileNo != null) ...[
                                const SizedBox(height: 6),
                                _buildDetailRow(
                                  Icons.phone_rounded,
                                  widget.shop.mobileNo!,
                                  gradientColors[1],
                                ),
                              ],
                              
                              // Address
                              if (widget.shop.address != null) ...[
                                const SizedBox(height: 6),
                                _buildDetailRow(
                                  Icons.location_on_rounded,
                                  widget.shop.address!,
                                  AppTheme.textSecondary,
                                  isAddress: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Arrow with gradient background
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradientColors[0].withOpacity(0.15),
                                gradientColors[1].withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: gradientColors[1],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text,
    Color color, {
    bool isAddress = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isAddress ? 12 : 14,
              color: isAddress
                  ? AppTheme.textSecondary.withOpacity(0.7)
                  : AppTheme.textSecondary,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Custom painter for dot pattern
class DotPatternPainter extends CustomPainter {
  final Color color;

  DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 8.0;
    const dotSize = 2.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}