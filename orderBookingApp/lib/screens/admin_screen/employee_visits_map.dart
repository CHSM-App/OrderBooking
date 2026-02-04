import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
    final center =
        LatLng(sortedVisits.first.latitude, sortedVisits.first.longitude);
    final markers = <Marker>[];
    for (var i = 0; i < sortedVisits.length; i++) {
      markers.add(_buildMarker(sortedVisits[i], i + 1));
    }

    final routePoints = sortedVisits
        .map((v) => LatLng(v.latitude, v.longitude))
        .toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.vengurlatech.orderbooking',
        ),
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4,
                color: const Color(0xFF1976D2),
              ),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Marker _buildMarker(EmployeeVisit visit, int sequence) {
    final isStart = sequence == 1;
    final isEnd = sequence > 1 && sequence == (ref
            .read(employeeVisitViewModelProvider)
            .visits
            ?.value
            ?.length ??
        sequence);
    final color = isStart
        ? Colors.green
        : isEnd
            ? Colors.red
            : Colors.blue;

    return Marker(
      width: 44,
      height: 44,
      point: LatLng(visit.latitude, visit.longitude),
      child: GestureDetector(
        onTap: () => _showVisitDetails(visit, sequence),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              sequence.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
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
