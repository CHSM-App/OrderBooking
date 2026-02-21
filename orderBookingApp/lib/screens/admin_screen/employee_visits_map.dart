import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmployeeVisitsMapPage extends ConsumerStatefulWidget {
    final int empId;
  final String empName;

  const EmployeeVisitsMapPage({
    super.key,
    required this.empId,
    required this.empName,
  });

  @override
  ConsumerState<EmployeeVisitsMapPage> createState() => _EmployeeVisitsMapPageState();
}

class _EmployeeVisitsMapPageState extends ConsumerState<EmployeeVisitsMapPage> {
  GoogleMapController? _mapController;

  // Your encoded polyline from Directions API
  static const String _encodedPolyline = 'uxhuBxrc|QPA@?@?B?B@@B@D@HDFD@B@H@JBB@DBFJ';

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> _decodedPoints = [];

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _decodeAndSetupPolyline();
  }

  void _decodeAndSetupPolyline() {
    final PolylinePoints polylinePoints = PolylinePoints();

    // Decode the encoded polyline string
    final List<PointLatLng> result =
        polylinePoints.decodePolyline(_encodedPolyline);

    _decodedPoints =
        result.map((point) => LatLng(point.latitude, point.longitude)).toList();

    if (_decodedPoints.isEmpty) return;

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 5,
      points: _decodedPoints,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );

    final startMarker = Marker(
      markerId: const MarkerId('start'),
      position: _decodedPoints.first,
      infoWindow: const InfoWindow(title: 'Start'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    final endMarker = Marker(
      markerId: const MarkerId('end'),
      position: _decodedPoints.last,
      infoWindow: const InfoWindow(title: 'End'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _polylines = {polyline};
      _markers = {startMarker, endMarker};
    });
  }

  void _fitPolylineBounds() {
    if (_mapController == null || _decodedPoints.isEmpty) return;

    double minLat = _decodedPoints.first.latitude;
    double maxLat = _decodedPoints.first.latitude;
    double minLng = _decodedPoints.first.longitude;
    double maxLng = _decodedPoints.first.longitude;

    for (final point in _decodedPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Map'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _fitPolylineBounds,
            tooltip: 'Fit route',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              _mapController = controller;
              // Fit the route once map is ready
              Future.delayed(
                const Duration(milliseconds: 300),
                _fitPolylineBounds,
              );
            },
            polylines: _polylines,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.directions, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Your Route',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_decodedPoints.length} points decoded',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _fitPolylineBounds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Fit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}