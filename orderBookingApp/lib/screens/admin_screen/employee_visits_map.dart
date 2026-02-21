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
                          value: activeRecord!.checkout.isNotEmpty
                              ? activeRecord!.checkout
                              : "--",
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


















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:http/http.dart' as http;

// class EmployeeVisitsMapPage extends StatefulWidget {
//   final int empId;
//   final String empName;

//   const EmployeeVisitsMapPage({
//     super.key,
//     required this.empId,
//     required this.empName,
//   });

//   @override
//   State<EmployeeVisitsMapPage> createState() =>
//       _EmployeeVisitsMapPageState();
// }

// class _EmployeeVisitsMapPageState
//     extends State<EmployeeVisitsMapPage> {

//   GoogleMapController? _mapController;
//   final Set<Polyline> _polylines = {};
//   final Set<Marker> _markers = {};

//   final String googleApiKey = "AIzaSyB7afZeIZfkBl81xghIHS-hMi_UpFLybYI";

  
//   double totalDistanceKm = 0;
//   double totalDurationMin = 0;

//   final List<LatLng> shops = [
//     const LatLng(15.9111120,73.6958640),
//     const LatLng(15.912308, 73.703390),
//     const LatLng(15.917356, 73.710947),
//     const LatLng(15.923355, 73.742168),
//     const LatLng(15.875119, 73.800771),
//     const LatLng(15.861306, 73.734298),
//     const LatLng(15.864701, 73.715939),
//     const LatLng(15.9111120,73.6958640),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadRoute();
//   }

//   Future<void> _loadRoute() async {
//     final origin =
//         "${shops.first.latitude},${shops.first.longitude}";
//     final destination =
//         "${shops.last.latitude},${shops.last.longitude}";

//     final waypoints = shops
//         .sublist(1, shops.length - 1)
//         .map((e) => "${e.latitude},${e.longitude}")
//         .join("|");

//     final url =
//         "https://maps.googleapis.com/maps/api/directions/json"
//         "?origin=$origin"
//         "&destination=$destination"
//         "&waypoints=$waypoints"
//         "&mode=driving"
//         "&key=$googleApiKey";

//     final response = await http.get(Uri.parse(url));
//     final data = json.decode(response.body);

//     final route = data["routes"][0];

//     // Distance & duration
//     for (var leg in route["legs"]) {
//       totalDistanceKm += leg["distance"]["value"] / 1000;
//       totalDurationMin += leg["duration"]["value"] / 60;
//     }

//     final encodedPolyline =
//         route["overview_polyline"]["points"];

//     _drawRoadPath(encodedPolyline);
//   }

//   void _drawRoadPath(String encodedPolyline) {
//     final polylinePoints = PolylinePoints();
//     final decodedPoints =
//         polylinePoints.decodePolyline(encodedPolyline);

//     final List<LatLng> routePoints = decodedPoints
//         .map((e) => LatLng(e.latitude, e.longitude))
//         .toList();

//     _polylines.add(
//       Polyline(
//         polylineId: const PolylineId("route"),
//         points: routePoints,
//         width: 8,
//         color: const Color.fromARGB(255, 255, 123, 0),
//         startCap: Cap.roundCap,
//         endCap: Cap.roundCap,
//         jointType: JointType.round,
//       ),
//     );

//     for (int i = 0; i < shops.length; i++) {
//       BitmapDescriptor icon;

//       if (i == 0) {
//         icon = BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueGreen);
//       } else if (i == shops.length - 1) {
//         icon = BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueBlue);
//       } else {
//         icon = BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueRed);
//       }

//       _markers.add(
//         Marker(
//           markerId: MarkerId("shop_$i"),
//           position: shops[i],
//           icon: icon,
//           infoWindow: InfoWindow(
//             title: i == 0
//                 ? "Start"
//                 : i == shops.length - 1
//                     ? "End"
//                     : "Shop $i",
//           ),
//         ),
//       );
//     }

//     setState(() {});
//     _fitCamera(routePoints);
//   }

//   void _fitCamera(List<LatLng> points) {
//     if (_mapController == null || points.isEmpty) return;

//     double minLat = points.first.latitude;
//     double maxLat = points.first.latitude;
//     double minLng = points.first.longitude;
//     double maxLng = points.first.longitude;

//     for (var p in points) {
//       if (p.latitude < minLat) minLat = p.latitude;
//       if (p.latitude > maxLat) maxLat = p.latitude;
//       if (p.longitude < minLng) minLng = p.longitude;
//       if (p.longitude > maxLng) maxLng = p.longitude;
//     }

//     _mapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: LatLng(minLat, minLng),
//           northeast: LatLng(maxLat, maxLng),
//         ),
//         80,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("${widget.empName} Route"),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: shops.first,
//               zoom: 13,
//             ),
//             onMapCreated: (controller) {
//               _mapController = controller;
//             },
//             polylines: _polylines,
//             markers: _markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             zoomControlsEnabled: true,
//           ),

//           // Bottom summary card
//           Positioned(
//             bottom: 20,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     blurRadius: 12,
//                     color: Colors.black.withOpacity(0.1),
//                   )
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Total Distance: ${totalDistanceKm.toStringAsFixed(2)} km",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "Estimated Time: ${totalDurationMin.toStringAsFixed(0)} mins",
//                   ),
//                   const SizedBox(height: 4),
//                   Text("Stops: ${shops.length - 1}"),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






























// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class EmployeeVisitsMapPage extends StatefulWidget {
//       final int empId;
//   final String empName;

//   const EmployeeVisitsMapPage({
//     super.key,
//     required this.empId,
//     required this.empName,
//   });

//   @override
//   State<EmployeeVisitsMapPage> createState() => _SimpleRouteMapPageState();
// }

// class _SimpleRouteMapPageState extends State<EmployeeVisitsMapPage> {
//   GoogleMapController? _mapController;

//   final Set<Polyline> _polylines = {};
//   final Set<Marker> _markers = {};

//   // 🔹 Hardcoded encoded polyline
//   final String encodedPolyline =
//       '''ypb`Bwvx`MaAqIh@{Hu@iBy@s@_B_@gAiABsBl@yCAaBQyCa@i@qJa@gFy@kBmCcB}Cg@iAGyBMcDi@yAiAcDY{Nh@cM`@qE{AmBwDiBm@k@q@mBm@gCU_CByDj@cEBmAi@}B}CoJsHqSaB}FO}k@dCsTQ{@kBgAeM_e@kHcXsEwRiHcYaAwAm@yC|Aw@nIiDn@KfIcDn^oO`XqKv\kNdEeCvGyG~NyNxOiOzUkUtf@qd@z`@ca@jYkY~WqX`GeGtSkSbGqF`W_JrKkEdEcBzAm@FTyB~@gDtAoDrA{P|G}KlDuG`G}[z[iEzEWW@IhBsBbHeHrPwPz@w@|AaBZTfAx@l@p@pB`D`EdFlCtFpFjN|CpDzAxBt@hCz@`DAn@i@`AkDxDaAdEqAdCqA`DOxCXnArClCZjA?zEy@pKu@fDQxBHjDfFnKnBbBlE~AbAj@X`Av@`EzAvGdCxP~@|HFlCYzCs@jC_C`FuFhJuL~RyEvI}CnIq@tH\fLMfIiCb[IvF\vCRzGYpMa@|Kz@zGT|G~AtGnBnFj@rDv@xDI\iCzB_AzAg@b@InCh@xJf@^tAKpBk@~EoApADvAb@~CdJrApCzAfCrAnLdCdLpDxVvBlHtAvCrDhKvFjGjCrB~D`IvClIlDlKr@fCBrABdD|FpPnAbN\pF@nFd@bDlCpJrAnH|@fHVxCOhDg@|DJ|Ba@zCs@d@sBf@Kr@vA`CfBpDbCjAx@j@x@hDn@`AtCfCDb@sAhBqFbFcCrAmB|AaDtCaCnDFvAtA|@`@pA]z@m@^QpBsA~AMv@BzA`Al@bC_@hAAvCxDnBb@jBJhG`ArB]`CPpBSfC@rAhA?j@kBfD_@vA{AbBcCr@AbDf@lFb@bBHhC^jDv@pJQrHkB~Pk@~CgBjFmFnKqBdHyEdMmCjGoBjKgApHaB|KQjHo@xElAvMAdCkA~EmAxBuBrBgB~DsBfDiBpCGdCRnFf@fDgARMPkFf@IgDm@}Ds@wFWmIk@}CcAcBqAqCyBoHaIuL{BaCeCyBwHyFwByAcNsEaCoAuEgD}GaGmHsH}HwEwGyFoQiK{LkJyBuD_CgGoEmEeGqBaEqAeA_BiAoHwAoE{AaCgIqKaEkGeE_Km@a@wERmBV}Ak@yImGu@o@k@kC}@cHi@aAaA}AFq@ZqACwBTeBjAkAl@_ABiBHuBlD_ERsA]sA{AuCiCiBuAc@sAWYYoB_EaBiDkB_Hg@yHmC_DeGaKaFiJgAw@iHqC_FyC{KeIq@{A]iC'''; // example polyline

//   // 🔹 Hardcoded shop coordinates
// final List<LatLng> shops = [
//   const LatLng(15.911056, 73.696065),
//   const LatLng(15.912308, 73.703390),
//   const LatLng(15.917356, 73.710947),
//   const LatLng(15.923355, 73.742168),
//   const LatLng(15.875119, 73.800771),
//   const LatLng(15.864701, 73.715939),
//   const LatLng(15.861306, 73.734298),
// ];

//   @override
//   void initState() {
//     super.initState();
//     _drawRoute();
//   }

//   void _drawRoute() {
//     final polylinePoints = PolylinePoints();
//     final decodedPoints =
//         polylinePoints.decodePolyline(encodedPolyline); 

//     final List<LatLng> routePoints = decodedPoints
//         .map((e) => LatLng(e.latitude, e.longitude))
//         .toList();

//     // Add polyline
//     _polylines.add(
//       Polyline(
//         polylineId: const PolylineId("route"),
//         points: routePoints,
//         width: 5,
//       ),
//     );

//     // Add shop markers
//     for (int i = 0; i < shops.length; i++) {
//       _markers.add(
//         Marker(
//           markerId: MarkerId("shop_$i"),
//           position: shops[i],
//           infoWindow: InfoWindow(title: "Shop ${i + 1}"),
//         ),
//       );
//     }
//   }

//   void _fitCamera() {
//     if (_mapController == null || shops.isEmpty) return;

//     _mapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: shops.reduce((a, b) =>
//               LatLng(
//                 a.latitude < b.latitude ? a.latitude : b.latitude,
//                 a.longitude < b.longitude ? a.longitude : b.longitude,
//               )),
//           northeast: shops.reduce((a, b) =>
//               LatLng(
//                 a.latitude > b.latitude ? a.latitude : b.latitude,
//                 a.longitude > b.longitude ? a.longitude : b.longitude,
//               )),
//         ),
//         60,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Simple Route Map")),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: shops.first,
//           zoom: 12,
//         ),
//         onMapCreated: (controller) {
//           _mapController = controller;
//           _fitCamera();
//         },
//         polylines: _polylines,
//         markers: _markers,
//         myLocationEnabled: false,
//         zoomControlsEnabled: true,
//       ),
//     );
//   }
// }






















// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class EmployeeVisitsMapPage extends ConsumerStatefulWidget {
//     final int empId;
//   final String empName;

//   const EmployeeVisitsMapPage({
//     super.key,
//     required this.empId,
//     required this.empName,
//   });

//   @override
//   ConsumerState<EmployeeVisitsMapPage> createState() => _EmployeeVisitsMapPageState();
// }

// class _EmployeeVisitsMapPageState extends ConsumerState<EmployeeVisitsMapPage> {
//   GoogleMapController? _mapController;

//   // Your encoded polyline from Directions API
//   static const String _encodedPolyline = 'uxhuBxrc|QPA@?@?B?B@@B@D@HDFD@B@H@JBB@DBFJ';

//   Set<Polyline> _polylines = {};
//   Set<Marker> _markers = {};
//   List<LatLng> _decodedPoints = [];

//   static const CameraPosition _initialPosition = CameraPosition(
//     target: LatLng(0, 0),
//     zoom: 14,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _decodeAndSetupPolyline();
//   }

//   void _decodeAndSetupPolyline() {
//     final PolylinePoints polylinePoints = PolylinePoints();

//     // Decode the encoded polyline string
//     final List<PointLatLng> result =
//         polylinePoints.decodePolyline(_encodedPolyline);

//     _decodedPoints =
//         result.map((point) => LatLng(point.latitude, point.longitude)).toList();

//     if (_decodedPoints.isEmpty) return;

//     final polyline = Polyline(
//       polylineId: const PolylineId('route'),
//       color: Colors.blue,
//       width: 5,
//       points: _decodedPoints,
//       startCap: Cap.roundCap,
//       endCap: Cap.roundCap,
//       jointType: JointType.round,
//     );

//     final startMarker = Marker(
//       markerId: const MarkerId('start'),
//       position: _decodedPoints.first,
//       infoWindow: const InfoWindow(title: 'Start'),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//     );

//     final endMarker = Marker(
//       markerId: const MarkerId('end'),
//       position: _decodedPoints.last,
//       infoWindow: const InfoWindow(title: 'End'),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//     );

//     setState(() {
//       _polylines = {polyline};
//       _markers = {startMarker, endMarker};
//     });
//   }

//   void _fitPolylineBounds() {
//     if (_mapController == null || _decodedPoints.isEmpty) return;

//     double minLat = _decodedPoints.first.latitude;
//     double maxLat = _decodedPoints.first.latitude;
//     double minLng = _decodedPoints.first.longitude;
//     double maxLng = _decodedPoints.first.longitude;

//     for (final point in _decodedPoints) {
//       if (point.latitude < minLat) minLat = point.latitude;
//       if (point.latitude > maxLat) maxLat = point.latitude;
//       if (point.longitude < minLng) minLng = point.longitude;
//       if (point.longitude > maxLng) maxLng = point.longitude;
//     }

//     _mapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: LatLng(minLat, minLng),
//           northeast: LatLng(maxLat, maxLng),
//         ),
//         80,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Route Map'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.fit_screen),
//             onPressed: _fitPolylineBounds,
//             tooltip: 'Fit route',
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: _initialPosition,
//             onMapCreated: (controller) {
//               _mapController = controller;
//               // Fit the route once map is ready
//               Future.delayed(
//                 const Duration(milliseconds: 300),
//                 _fitPolylineBounds,
//               );
//             },
//             polylines: _polylines,
//             markers: _markers,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: true,
//             mapToolbarEnabled: false,
//           ),
//           Positioned(
//             bottom: 20,
//             left: 16,
//             right: 16,
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.directions, color: Colors.blue, size: 28),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Text(
//                             'Your Route',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '${_decodedPoints.length} points decoded',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 13,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: _fitPolylineBounds,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text('Fit'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
// }