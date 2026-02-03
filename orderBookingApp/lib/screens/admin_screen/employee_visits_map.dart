import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/employee_visit_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(employeeVisitViewModelProvider.notifier)
          .fetchEmployeeVisits(widget.empId);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeVisitViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.empName} Visits Map'),
        backgroundColor: const Color(0xFF0A3D62),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployeeVisitState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildError(state.error!);
    }

    final visits = state.visits?.value ?? <EmployeeVisit>[];
    if (visits.isEmpty) {
      return _buildEmpty();
    }

    final sortedVisits = [...visits]..sort(_compareVisitsByDateTime);
    final points = sortedVisits
        .map((v) => LatLng(v.latitude, v.longitude))
        .toList();

    final markers = _buildMarkers(sortedVisits);
    final polylines = _buildPolylines(points);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: points.first,
        zoom: 14,
      ),
      markers: markers,
      polylines: polylines,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        _fitBounds(points);
      },
    );
  }

  Set<Marker> _buildMarkers(List<EmployeeVisit> visits) {
    final markers = <Marker>{};
    for (var i = 0; i < visits.length; i++) {
      final visit = visits[i];
      final isStart = i == 0;
      final isEnd = i == visits.length - 1;
      markers.add(
        Marker(
          markerId: MarkerId('visit_${visit.locationId}_$i'),
          position: LatLng(visit.latitude, visit.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isStart
                ? BitmapDescriptor.hueGreen
                : isEnd
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: 'Visit #${i + 1}',
            snippet: '${visit.date} ${visit.time} | Shop ${visit.shopId}',
            onTap: () => _showVisitDetails(visit, i + 1),
          ),
          onTap: () => _showVisitDetails(visit, i + 1),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    if (points.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('visit_path'),
        points: points,
        color: const Color(0xFF1976D2),
        width: 5,
      ),
    };
  }

  void _fitBounds(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final p in points) {
      minLat = minLat == null ? p.latitude : min(minLat, p.latitude);
      maxLat = maxLat == null ? p.latitude : max(maxLat, p.latitude);
      minLng = minLng == null ? p.longitude : min(minLng, p.longitude);
      maxLng = maxLng == null ? p.longitude : max(maxLng, p.longitude);
    }

    if (minLat == null ||
        maxLat == null ||
        minLng == null ||
        maxLng == null) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  int _compareVisitsByDateTime(EmployeeVisit a, EmployeeVisit b) {
    final aDate = _parseVisitDateTime(a);
    final bDate = _parseVisitDateTime(b);
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  }

  DateTime? _parseVisitDateTime(EmployeeVisit visit) {
    final raw = '${visit.date}T${visit.time}';
    return DateTime.tryParse(raw);
  }

  void _showVisitDetails(EmployeeVisit visit, int sequence) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visit #$sequence',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('Date', visit.date),
              _detailRow('Time', visit.time),
              _detailRow('Shop ID', visit.shopId.toString()),
              _detailRow('Accuracy', '${visit.accuracy.toStringAsFixed(2)} m'),
              _detailRow(
                'Lat/Lng',
                '${visit.latitude.toStringAsFixed(6)}, ${visit.longitude.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No visits found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'This employee has no visit records yet.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 12),
            const Text(
              'Failed to load visits',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(employeeVisitViewModelProvider.notifier)
                    .fetchEmployeeVisits(widget.empId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A3D62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
