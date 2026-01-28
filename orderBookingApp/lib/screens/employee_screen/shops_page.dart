import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/screens/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_shop_screen.dart';
import 'shop_visit_screen.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({Key? key}) : super(key: key);

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> with WidgetsBindingObserver {
  List<Shop> _shops = [];
  List<Shop> _filteredShops = [];
  final TextEditingController _searchController = TextEditingController();
  late final StreamSubscription _connectivitySub;
  bool _isLocationServiceEnabled = false;
  LocationPermission _locationPermission = LocationPermission.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivitySub = Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        syncOfflineVisits();
      }
    });
    _loadShops();
    _checkLocationPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permissions when app returns from background
      _checkLocationPermissions();
    }
  }

  /// Check location service and permission status
  Future<void> _checkLocationPermissions() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();

      if (mounted) {
        setState(() {
          _isLocationServiceEnabled = serviceEnabled;
          _locationPermission = permission;
        });

        // Show banner if location is not properly set up
        if (!serviceEnabled || 
            permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          _showLocationSetupBanner();
        }
      }
    } catch (e) {
      debugPrint('Error checking location permissions: $e');
    }
  }

  /// Show a persistent banner prompting user to enable location
  void _showLocationSetupBanner() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.orange.shade100,
        content: Text(
          !_isLocationServiceEnabled
              ? 'Location services are disabled. Please enable GPS to visit shops.'
              : _locationPermission == LocationPermission.deniedForever
                  ? 'Location permission permanently denied. Enable in app settings.'
                  : 'Location permission required to visit shops.',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: const Icon(Icons.location_off, color: Colors.orange),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('DISMISS'),
          ),
          TextButton(
            onPressed: _handleLocationSetup,
            child: const Text('FIX'),
          ),
        ],
      ),
    );
  }

  /// Handle location setup based on current status
  Future<void> _handleLocationSetup() async {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

    if (!_isLocationServiceEnabled) {
      // Ask user to enable location services
      await _showLocationServiceDialog();
    } else if (_locationPermission == LocationPermission.deniedForever) {
      // Direct user to app settings
      await _showOpenSettingsDialog();
    } else if (_locationPermission == LocationPermission.denied) {
      // Request permission
      await _requestLocationPermission();
    }
  }

  /// Show dialog asking user to enable location services
  Future<void> _showLocationServiceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Services'),
        content: const Text(
          'This app requires GPS to verify shop visits. Please enable location services in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Open location settings
              await Geolocator.openLocationSettings();
              // Recheck after a delay
              await Future.delayed(const Duration(seconds: 1));
              await _checkLocationPermissions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to open app settings for permanently denied permission
  Future<void> _showOpenSettingsDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
              // Recheck after a delay
              await Future.delayed(const Duration(seconds: 1));
              await _checkLocationPermissions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );
  }

  /// Request location permission
  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      
      if (mounted) {
        setState(() {
          _locationPermission = permission;
        });

        if (permission == LocationPermission.denied) {
          _showError('Location permission denied. Cannot visit shops without permission.');
        } else if (permission == LocationPermission.deniedForever) {
          _showError('Location permission permanently denied. Please enable in settings.');
          await _showOpenSettingsDialog();
        } else {
          _showSuccess('Location permission granted!');
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        }
      }
    } catch (e) {
      _showError('Failed to request location permission: ${e.toString()}');
    }
  }

  Future<void> saveVisitOffline(VisitPayload visit) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('offline_visits') ?? [];

    queue.add(jsonEncode(visit.toJson()));
    await prefs.setStringList('offline_visits', queue);
  }

  Future<void> sendVisitToServer(VisitPayload visit) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate failure if accuracy is bad
    if (visit.accuracy > 30) {
      throw Exception('GPS accuracy too low. Server rejected the visit.');
    }
  }

  Future<List<VisitPayload>> getOfflineVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('offline_visits') ?? [];

    return queue.map((e) => VisitPayload.fromJson(jsonDecode(e))).toList();
  }

  Future<void> syncOfflineVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('offline_visits') ?? [];

    if (queue.isEmpty) return;

    final remaining = <String>[];
    int synced = 0;

    for (final item in queue) {
      try {
        final visit = VisitPayload.fromJson(jsonDecode(item));
        await sendVisitToServer(visit);
        synced++;
      } catch (_) {
        remaining.add(item); // keep failed ones
      }
    }

    await prefs.setStringList('offline_visits', remaining);

    if (synced > 0 && mounted) {
      _showSuccess('$synced offline visit(s) synced successfully!');
    }
  }

  void _loadShops() {
    _shops = [
      Shop(
        id: '1',
        shopName: 'Green Juice Corner',
        address: 'Shop 12, Market Street, Andheri West, Mumbai',
        latitude: 19.0760,
        longitude: 72.8777,
        ownerName: 'Ramesh Kumar',
        phoneNumber: '9876543210',
      ),
      Shop(
        id: '2',
        shopName: 'Fresh Fruits Hub',
        address: 'Plot 45, Station Road, Dadar, Mumbai',
        latitude: 19.0896,
        longitude: 72.8656,
        ownerName: 'Suresh Patel',
        phoneNumber: '9876543211',
      ),
      Shop(
        id: '3',
        shopName: 'Health Juice Bar',
        address: 'Building 7, Gandhi Nagar, Bandra, Mumbai',
        latitude: 19.0544,
        longitude: 72.8320,
        ownerName: 'Vijay Shah',
        phoneNumber: '9876543212',
      ),
      Shop(
        id: '4',
        shopName: 'Natural Drinks Shop',
        address: 'Shop 23, Main Market, Borivali, Mumbai',
        latitude: 19.2305,
        longitude: 72.8567,
        ownerName: 'Prakash Desai',
        phoneNumber: '9876543213',
      ),
    ];
    _filteredShops = _shops;
  }

  void _filterShops(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredShops = _shops;
      } else {
        _filteredShops = _shops
            .where(
              (shop) =>
                  shop.shopName.toLowerCase().contains(query.toLowerCase()) ||
                  shop.address.toLowerCase().contains(query.toLowerCase()) ||
                  (shop.ownerName?.toLowerCase().contains(query.toLowerCase()) ?? false),
            )
            .toList();
      }
    });
  }

  /// Get user location with comprehensive error handling and validation
  Future<Position> _getUserLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS in device settings.');
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please grant permission to continue.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please enable it in app settings.');
    }

    // Get current position with timeout and accuracy settings
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
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
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      throw Exception('Failed to get location: ${e.toString()}');
    }

    // Validate GPS accuracy
    if (position.accuracy > 30) {
      throw Exception(
        'GPS accuracy too low (${position.accuracy.toStringAsFixed(1)}m). Please move to an open area with clear sky view.',
      );
    }

    // Validate coordinates are reasonable
    if (position.latitude == 0.0 && position.longitude == 0.0) {
      throw Exception('Invalid GPS coordinates received. Please try again.');
    }

    return position;
  }

  /// Select shop and initiate visit with validation
  Future<void> _selectShop(Shop shop) async {
    // Pre-check location permissions before starting
    if (!_isLocationServiceEnabled) {
      _showError('Location services are disabled. Please enable GPS first.');
      await _showLocationServiceDialog();
      return;
    }

    if (_locationPermission == LocationPermission.denied) {
      _showError('Location permission required to visit shops.');
      await _requestLocationPermission();
      return;
    }

    if (_locationPermission == LocationPermission.deniedForever) {
      _showError('Location permission permanently denied. Please enable in settings.');
      await _showOpenSettingsDialog();
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Getting your location...',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few seconds',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Get user location
      final position = await _getUserLocation();

      // Create visit payload
      final visit = VisitPayload(
        shopId: shop.id,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        capturedAt: DateTime.now(),
      );

      // Dismiss loading dialog
      if (mounted) Navigator.pop(context);

      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();

      if (connectivity == ConnectivityResult.none) {
        // Save offline
        await saveVisitOffline(visit);
        _showSuccess('Visit saved offline. Will sync when connection is available.');
      } else {
        // Try to send to server
        try {
          await sendVisitToServer(visit);
          _showSuccess('Visit recorded successfully!');
        } catch (e) {
          // If server rejects, save offline
          await saveVisitOffline(visit);
          _showWarning('Visit saved offline due to: ${e.toString()}');
        }
      }

      // Navigate to visit screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopVisitScreen(shop: shop),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      _showError(errorMessage);

      // Offer to fix if it's a permission/service issue
      if (errorMessage.contains('disabled') || errorMessage.contains('denied')) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) await _handleLocationSetup();
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterShops,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search shops by name or address...',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterShops('');
                          },
                        )
                      : null,
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.textLight, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.errorColor,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.errorColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Shops Count + Map Button Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Shops Count
                  Expanded(
                    child: Text(
                      '${_filteredShops.length} Shop${_filteredShops.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // View Map Button
                  TextButton.icon(
                    onPressed: () {
                      _showInfo('Map view coming soon!');
                    },
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text(
                      'View Map',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Shop List
            Expanded(
              child: _filteredShops.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 80,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No shops match your search'
                                : 'No shops available',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterShops('');
                              },
                              child: const Text('Clear search'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredShops.length,
                      itemBuilder: (context, index) {
                        final shop = _filteredShops[index];
                        return _ShopCard(
                          shop: shop,
                          onTap: () => _selectShop(shop),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddShopScreen()),
          );
          if (result != null && result is Shop) {
            setState(() {
              _shops.add(result);
              _filteredShops = _shops;
            });
            _showSuccess('Shop "${result.shopName}" added successfully!');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Shop'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _connectivitySub.cancel();
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    super.dispose();
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

  const _ShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              // Shop Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.shopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shop.address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (shop.ownerName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    shop.ownerName!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    shop.phoneNumber ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}