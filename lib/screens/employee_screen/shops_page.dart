import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/shop_viewmodel.dart';
import 'package:order_booking_app/screens/employee_screen/add_shop_screen.dart';
import 'package:order_booking_app/screens/employee_screen/shop_visit_screen.dart';
import 'package:safe_device/safe_device.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/visite.dart';

// ── Brand tokens (match your orange/amber theme) ─────────────────────────────
const _kPrimary = Color(0xFFE8720C); // warm orange
const _kPrimaryLight = Color(0xFFFFF3E8); // soft orange tint
const _kSurface = Color(0xFFFFFFFF);
const _kBackground = Color(0xFFF5F5F5);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider = Color(0xFFEEEEEE);

class ShopListPage extends ConsumerStatefulWidget {
  const ShopListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends ConsumerState<ShopListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopViewModelProvider.notifier)
          .getEmpShopList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
            ref.read(adminloginViewModelProvider).regionId ?? 0,
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

  Future<void> _onRefresh() async {
    await ref
        .read(shopViewModelProvider.notifier)
        .getEmpShopList(
          ref.read(adminloginViewModelProvider).companyId ?? '',
          ref.read(adminloginViewModelProvider).regionId ?? 0,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShopDetails> _filterShops(List<ShopDetails> shops) {
    if (_searchQuery.isEmpty) return shops;
    return shops.where((shop) {
      final name = shop.shopName?.toLowerCase() ?? '';
      final owner = shop.ownerName?.toLowerCase() ?? '';
      final address = shop.address?.toLowerCase() ?? '';
      final phone = shop.mobileNo?.toLowerCase() ?? '';
      return name.contains(_searchQuery) ||
          owner.contains(_searchQuery) ||
          address.contains(_searchQuery) ||
          phone.contains(_searchQuery);
    }).toList();
  }

  // ── Location helpers (unchanged logic, removed heavy UI) ─────────────────
  Future<Position?> _getCurrentLocation() async {
    try {
      // 1️⃣ Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final open = await _simpleDialog(
          icon: Icons.location_off_outlined,
          iconColor: _kPrimary,
          title: 'Location Disabled',
          body: 'Please enable location services to continue.',
          confirmLabel: 'Enable',
        );

        if (open) {
          await Geolocator.openLocationSettings();
          await Future.delayed(const Duration(seconds: 2));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) return null;
        } else {
          return null;
        }
      }

      // 2️⃣ Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _simpleDialog(
            icon: Icons.location_disabled_outlined,
            iconColor: Colors.red,
            title: 'Permission Denied',
            body: 'Location permission is required.',
            confirmLabel: 'OK',
            cancelLabel: null,
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final open = await _simpleDialog(
          icon: Icons.block_outlined,
          iconColor: Colors.red,
          title: 'Permission Required',
          body:
              'Location permission permanently denied. Please enable it from app settings.',
          confirmLabel: 'Settings',
        );

        if (open) {
          await Geolocator.openAppSettings();
        }
        return null;
      }

      // 3️⃣ Detect rooted / developer mode
      // bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      // bool developerMode = await FlutterJailbreakDetection.developerMode;
      bool isSecure = await _validateDeviceSecurity();
      if (!isSecure) {
        throw Exception(
          'Security policy violation. Disable developer mode or root access.',
        );
      }
      // if (jailbroken || developerMode) {
      //   throw Exception(
      //       'Security policy violation. Disable developer mode or root access.');
      // }

      // 4️⃣ Force fresh GPS location (NO lastKnownPosition)
      Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
            ),
          ).timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('GPS timeout. Move to open area and try again.');
            },
          );

      // 5️⃣ Detect mock location
      if (position.isMocked) {
        throw Exception('Fake GPS detected. Disable mock location apps.');
      }

      // 6️⃣ Validate accuracy
      if (position.accuracy <= 0 || position.accuracy > 150) {
        throw Exception('Low GPS accuracy. Move to open area and try again.');
      }

      return position;
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString(), isError: true);
      }
      return null;
    }
  }

  Future<bool> _validateDeviceSecurity() async {
    bool isJailBroken = await SafeDevice.isJailBroken;
    bool isRealDevice = await SafeDevice.isRealDevice;
    bool isMockLocation = await SafeDevice.isMockLocation;

    if (isJailBroken) {
      _showSnack("Rooted device detected. Punch in blocked.", isError: true);
      return false;
    }

    if (!isRealDevice) {
      _showSnack("Emulator detected. Punch in blocked.", isError: true);
      return false;
    }

    if (isMockLocation) {
      _showSnack("Mock location detected. Disable fake GPS.", isError: true);
      return false;
    }

    return true;
  }

  Future<bool> _simpleDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String confirmLabel,
    String? cancelLabel = 'Cancel',
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            title: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                color: _kTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              if (cancelLabel != null)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(color: _kTextSecondary),
                  ),
                ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? const Color(0xFFD32F2F) : _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _confirmPunchIn(ShopDetails shop) async {
    return _simpleDialog(
      icon: Icons.check_circle_outline,
      iconColor: _kPrimary,
      title: 'Punch In?',
      body:
          'Do you want to punch in for "${shop.shopName ?? 'this shop'}" now?',
      confirmLabel: 'Yes, Punch In',
      cancelLabel: 'Cancel',
    );
  }

  Future<void> _onShopTap(ShopDetails shop) async {
    final proceed = await _confirmPunchIn(shop);
    if (!proceed) return;

    // Show compact loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (_) => Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
              SizedBox(height: 14),
              Text(
                'Locating…',
                style: TextStyle(
                  fontSize: 12,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final position = await _getCurrentLocation();
      if (mounted) Navigator.pop(context);
      if (position == null) return;

      final shopLat = shop.latitude;
      final shopLng = shop.longitude;
      if (shopLat == null || shopLng == null) {
        _showSnack(
          'Shop location not available. Please update shop location.',
          isError: true,
        );
        return;
      }

      final isNear = await _isWithinShopRange(
        userPosition: position,
        shopLat: shopLat,
        shopLng: shopLng,
      );
      if (!isNear) return;

      final visit = VisitPayload(
        localId: const Uuid().v4(),
        shopId: shop.shopId ?? 0,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        capturedAt: DateTime.now(),
        punchIn: DateTime.now().toLocal().toIso8601String(),
        // punchIn: VisitPayload.formatForApi(DateTime.now().toLocal()),
        employeeId: ref.read(adminloginViewModelProvider).userId,
      );

      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ShopVisitScreen(shop: shop, visit: visit),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(anim),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) _showSnack('Error: ${e.toString()}', isError: true);
    }
  }

  Future<bool> _isWithinShopRange({
    required Position userPosition,
    required double shopLat,
    required double shopLng,
  }) async {
    final distanceInMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      shopLat,
      shopLng,
    );

    const allowedRadius = 100; // meters

    if (distanceInMeters > allowedRadius) {
      _showSnack(
        "You are not at the shop (${distanceInMeters.toStringAsFixed(0)}m away).",
        isError: true,
      );
      return false;
    }

    return true;
  }

  // Future<void> _onEditShop(ShopDetails shop) async {
  //   final result = await Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //       pageBuilder: (_, __, ___) => AddShopScreen(initialShop: shop),
  //       transitionsBuilder: (_, anim, __, child) => SlideTransition(
  //         position: Tween(
  //           begin: const Offset(0, 1),
  //           end: Offset.zero,
  //         ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(anim),
  //         child: child,
  //       ),
  //       transitionDuration: const Duration(milliseconds: 350),
  //     ),
  //   );
  //
  //   if (result == true && mounted) {
  //     ref
  //         .read(shopViewModelProvider.notifier)
  //         .getEmpShopList(
  //           ref.read(adminloginViewModelProvider).companyId ?? '',
  //           ref.read(adminloginViewModelProvider).regionId ?? 0,
  //         );
  //   }
  // }

  Future<void> _onDeleteShop(ShopDetails shop) async {
    final confirm = await _simpleDialog(
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFDC2626),
      title: 'Delete Shop?',
      body:
          'Are you sure you want to delete "${shop.shopName ?? 'this shop'}"?',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
    );
    if (!confirm) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black38,
        builder: (_) => Center(
          child: Container(
            width: 140,
            height: 120,
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
                SizedBox(height: 12),
                Text(
                  'Deleting...',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      await ref.read(shopViewModelProvider.notifier).deleteShop(shop);
      await ref
          .read(shopViewModelProvider.notifier)
          .getEmpShopList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
            ref.read(adminloginViewModelProvider).regionId ?? 0,
          );
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) _showSnack('Shop deleted');
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) _showSnack('Failed to delete: $e', isError: true);
    }
  }

  void _showShopDetails(ShopDetails shop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                shop.shopName ?? 'Shop Details',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('Owner', shop.ownerName ?? '-'),
              _detailRow('Mobile', shop.mobileNo ?? '-'),
              _detailRow('Address', shop.address ?? '-'),
              _detailRow(
                'Location',
                (shop.latitude != null && shop.longitude != null)
                    ? '${shop.latitude}, ${shop.longitude}'
                    : 'Not available',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openInMaps(shop),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _kTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: _kTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps(ShopDetails shop) async {
    final lat = shop.latitude;
    final lng = shop.longitude;
    if (lat == null || lng == null) {
      _showSnack('Shop location not available.', isError: true);
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened) {
      _showSnack('Unable to open Google Maps.', isError: true);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopViewModelProvider);

    return Scaffold(
      backgroundColor: _kBackground,
      body: RefreshIndicator(
        color: _kPrimary,
        backgroundColor: _kSurface,
        displacement: 60,
        strokeWidth: 2.5,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Sticky search bar ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Body ─────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildBody(shopState),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: _buildFAB(shopState),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kDivider, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search shops, owners…',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: _kTextSecondary,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: _kTextSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: _kTextSecondary,
                    ),
                    onPressed: () => _searchController.clear(),
                    splashRadius: 16,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 14,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildFAB(ShopState shopState) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AddShopScreen(),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(anim),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
        if (result == true && mounted) {
          ref
              .read(shopViewModelProvider.notifier)
              .getEmpShopList(
                ref.read(adminloginViewModelProvider).companyId ?? '',
                ref.read(adminloginViewModelProvider).regionId ?? 0,
              );
        }
      },
      backgroundColor: _kPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text(
        'Add Shop',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  // ── Body sliver ───────────────────────────────────────────────────────────
  Widget _buildBody(ShopState shopState) {
    // Loading (initial)
    if (shopState.isLoading && shopState.shopList == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: _kPrimary,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading shops…',
                style: TextStyle(
                  fontSize: 14,
                  color: _kTextSecondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error
    if (shopState.error != null) {
      return SliverFillRemaining(child: _buildErrorState(shopState.error!));
    }

    return shopState.shopList?.when(
          data: (shops) {
            final filtered = _filterShops(shops);
            if (filtered.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState());
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _MinimalShopCard(
                  shop: filtered[i],
                  onTap: () => _onShopTap(filtered[i]),
                  // onEdit: () => _onEditShop(filtered[i]),
                  onDetails: () => _showShopDetails(filtered[i]),
                  onDelete: () => _onDeleteShop(filtered[i]),
                  index: i,
                ),
                childCount: filtered.length,
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _kPrimary)),
          ),
          error: (e, _) =>
              SliverFillRemaining(child: _buildErrorState(e.toString())),
        ) ??
        const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 36,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No shops found' : 'No shops yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search'
                : 'Tap + Add Shop to get started',
            style: const TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _searchController.clear(),
              child: const Text(
                'Clear search',
                style: TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _kTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(shopViewModelProvider.notifier)
                  .getEmpShopList(
                    ref.read(adminloginViewModelProvider).companyId ?? '',
                    ref.read(adminloginViewModelProvider).regionId ?? 0,
                  ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Minimal Shop Card  — matches the "Order card" style from the screenshot
// ══════════════════════════════════════════════════════════════════════════════
class _MinimalShopCard extends StatefulWidget {
  final ShopDetails shop;
  final VoidCallback onTap;
  final VoidCallback onDetails;
  final VoidCallback onDelete;
  final int index;

  const _MinimalShopCard({
    required this.shop,
    required this.onTap,
    required this.onDetails,
    required this.onDelete,
    required this.index,
  });

  @override
  State<_MinimalShopCard> createState() => _MinimalShopCardState();
}

class _MinimalShopCardState extends State<_MinimalShopCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kDivider, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kPrimaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 22,
                      color: _kPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // ── Details ─────────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop name
                        Text(
                          widget.shop.shopName ?? 'Unknown Shop',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (widget.shop.ownerName != null ||
                            widget.shop.mobileNo != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (widget.shop.ownerName != null) ...[
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 12,
                                  color: _kTextSecondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.shop.ownerName!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _kTextSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              if (widget.shop.ownerName != null &&
                                  widget.shop.mobileNo != null)
                                const SizedBox(width: 12),
                              if (widget.shop.mobileNo != null)
                                _Chip(
                                  icon: Icons.phone_outlined,
                                  label: widget.shop.mobileNo!,
                                ),
                            ],
                          ),
                        ],

                        if (widget.shop.address != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: _kTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.shop.address!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kTextSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  // ── Arrow ────────────────────────────────────────────────
                  Column(
                    children: [
                      InkWell(
                        onTap: widget.onDetails,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _kPrimaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: widget.onDelete,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Small inline chip (phone / address)
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool shrink;

  const _Chip({required this.icon, required this.label, this.shrink = false});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _kTextSecondary),
        const SizedBox(width: 3),
        shrink
            ? Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 11, color: _kTextSecondary),
              ),
      ],
    );
    return content;
  }
}
