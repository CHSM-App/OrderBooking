import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/domain/models/employeeMap.dart';

class EmployeeVisitsMapPage extends ConsumerStatefulWidget {
  final int empId;
  final String empName;

  const EmployeeVisitsMapPage({
    super.key,
    required this.empId,
    required this.empName,
  });

  @override
  ConsumerState<EmployeeVisitsMapPage> createState() =>
      _EmployeeVisitsMapPageState();
}

class _EmployeeVisitsMapPageState extends ConsumerState<EmployeeVisitsMapPage> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .getEmployeeVisit(widget.empId);
    });
  }

  /// Filter records matching selected date
  List<EmployeeMap> _getFilteredRecords(List<EmployeeMap> allData) {
    return allData.where((e) {
      final d = e.checkInDate;
      return d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day;
    }).toList();
  }

  /// Pick the best record for the day:
  /// Prefer the one with the most shops; fallback to first.
  EmployeeMap? _getBestRecord(List<EmployeeMap> filtered) {
    if (filtered.isEmpty) return null;
    filtered.sort((a, b) => b.shops.length.compareTo(a.shops.length));
    return filtered.first;
  }

  void _buildMapOverlays(EmployeeMap record) {
    _polylines.clear();
    _markers.clear();

    // --- Decode polyline ---
    if (record.polyline.isNotEmpty) {
      final polylinePoints = PolylinePoints();
      final decoded = polylinePoints.decodePolyline(record.polyline);
      final routePoints = decoded
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      if (routePoints.isNotEmpty) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: routePoints,
            width: 8,
            color: const Color.fromARGB(255, 255, 123, 0),
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitCamera(routePoints);
        });
      }
    }

    // --- checkIn marker (GREEN) ---
    final checkInCoords = record.checkInLatLng;
    if (checkInCoords.length == 2) {
      _markers.add(
        Marker(
          markerId: const MarkerId("checkIn"),
          position: LatLng(checkInCoords[0], checkInCoords[1]),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: "Check In",
            snippet: DateFormat('hh:mm a').format(record.checkInDate),
          ),
        ),
      );
    }

    // --- checkOut marker (BLUE) ---
    final checkOutCoords = record.checkOutLatLng;
    if (checkOutCoords.length == 2) {
      _markers.add(
        Marker(
          markerId: const MarkerId("checkOut"),
          position: LatLng(checkOutCoords[0], checkOutCoords[1]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: "Check Out"),
        ),
      );
    }
// --- Shop markers (RED) ---
// --- Shop markers (RED) ---
for (int i = 0; i < record.shops.length; i++) {
  final shop = record.shops[i];

  final punchIn  = _formatPunchTime(shop.punchIn);
  final punchOut = _formatPunchTime(shop.punchOut);

  _markers.add(
    Marker(
      markerId: MarkerId("shop_$i"),
      position: LatLng(shop.latitude, shop.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed),
infoWindow: InfoWindow(
  title: "${shop.shopName} (${shop.ownerName})",
  snippet: "${shop.mobileNo}  |  In: $punchIn  •  Out: $punchOut",
),
    ),
  );
}
  }

  // Helper function — add this inside _EmployeeVisitsMapPageState
String _formatPunchTime(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '--';
  try {
    final dt = DateTime.parse(isoString);
    return DateFormat('hh:mm a').format(dt);
  } catch (_) {
    return '--';
  }
}

  void _fitCamera(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF7B00),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _polylines.clear();
        _markers.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeloginViewModelProvider);
    final mapDataAsync = state.employeeMapData;

    // Resolve the best record for the selected date (when data is available)
    EmployeeMap? activeRecord;
    List<EmployeeMap> filteredRecords = [];

    mapDataAsync.whenData((allData) {
      filteredRecords = _getFilteredRecords(allData);
      activeRecord = _getBestRecord(filteredRecords);
      if (activeRecord != null) {
        _buildMapOverlays(activeRecord!);
      }
    });

    final initialTarget = activeRecord != null
        ? LatLng(activeRecord!.checkInLatLng[0], activeRecord!.checkInLatLng[1])
        : const LatLng(15.9111120, 73.6958640);

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.empName}'s Route"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Stack(
        children: [
          // ── MAP ──────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (activeRecord != null) {
                final decoded = PolylinePoints()
                    .decodePolyline(activeRecord!.polyline)
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList();
                if (decoded.isNotEmpty) _fitCamera(decoded);
              }
            },
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),

          // ── DATE SELECTOR (TOP) ──────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Color(0xFFFF7B00),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // ── LOADING OVERLAY ──────────────────────────────────
          if (state.isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7B00)),
              ),
            ),

          // ── ERROR STATE ──────────────────────────────────────
          if (mapDataAsync is AsyncError)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  "Failed to load route data.",
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ── NO DATA FOR DATE ─────────────────────────────────
          if (mapDataAsync is AsyncData && activeRecord == null)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  "No visits recorded for ${DateFormat('dd MMM yyyy').format(_selectedDate)}",
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ── BOTTOM SUMMARY CARD ──────────────────────────────
          if (activeRecord != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row
                    Row(
                      children: [
                        const Icon(
                          Icons.route,
                          color: Color(0xFFFF7B00),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Route Summary",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7B00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${activeRecord!.shops.length} Shops",
                            style: const TextStyle(
                              color: Color(0xFFFF7B00),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Check-in / Check-out row
                    Row(
                      children: [
                        _SummaryTile(
                          icon: Icons.login,
                          iconColor: Colors.green,
                          label: "Check In",
                          value: DateFormat(
                            'hh:mm a',
                          ).format(activeRecord!.checkInDate),
                        ),
                        const Spacer(),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.grey.shade200,
                        ),
                        const Spacer(),
                        _SummaryTile(
                          icon: Icons.logout,
                          iconColor: Colors.blue,
                          label: "Check Out",
                          value: DateFormat(
                            'hh:mm a',
                          ).format(activeRecord!.checkOutDate),
                        ),
                      ],
                    ),
                    // In the bottom summary card, add a distance row below the check-in/out row:
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.straighten,
                          size: 16,
                          color: Color(0xFFFF7B00),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Total Distance: ${activeRecord!.total_distance_km.toStringAsFixed(2)} km",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Helper widget ──────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}


