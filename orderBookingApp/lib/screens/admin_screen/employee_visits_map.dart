import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/shop_visit.dart';

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
  static const _filterToday = 'Today';
  static const _filterMonth = 'This Month';
  static const _filterYear = 'This Year';
  static const _filterCustom = 'Custom';

  String _selectedFilter = _filterToday;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(visitViewModelProvider.notifier)
          .fetchEmployeeVisits(widget.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitViewModelProvider);

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

    final visits = state.visits.value ?? <EmployeeVisit>[];
    if (visits.isEmpty) {
      return _buildEmpty();
    }

    final sortedVisits = [...visits]..sort(_compareVisitsByDateTime);
    final filteredVisits = _applyFilter(sortedVisits);
    if (filteredVisits.isEmpty) {
      return Column(
        children: [
          _buildFilterBar(),
          const Expanded(
            child: Center(
              child: Text(
                'No visits match the selected filter.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    final center =
        LatLng(filteredVisits.first.latitude, filteredVisits.first.longitude);
    final markers = <Marker>[];
    for (var i = 0; i < filteredVisits.length; i++) {
      markers.add(_buildMarker(filteredVisits[i], i + 1));
    }

    final routePoints = filteredVisits
        .map((v) => LatLng(v.latitude, v.longitude))
        .toList();

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: FlutterMap(
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
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip(_filterToday),
              _filterChip(_filterMonth),
              _filterChip(_filterYear),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _filterChip(
                  _filterCustom,
                  showRange: true,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label, {
    bool showRange = false,
    bool fullWidth = false,
  }) {
    final isSelected = _selectedFilter == label;
    final subtitle = showRange && _customRange != null
        ? _formatRange(_customRange!)
        : null;
    final subtitleColor =
        isSelected ? Colors.white : Colors.black54;
    return ChoiceChip(
      label: SizedBox(
        width: fullWidth ? 290 : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, textAlign: TextAlign.center),
            if (subtitle != null)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: subtitleColor),
              ),
          ],
        ),
      ),
      selected: isSelected,
      onSelected: (_) => _onFilterSelected(label),
      selectedColor: const Color(0xFF0A3D62),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _onFilterSelected(String label) async {
    if (label == _filterCustom) {
      final now = DateTime.now();
      final initialStart =
          _customRange?.start ?? DateTime(now.year, now.month, now.day);
      final initialEnd =
          _customRange?.end ?? DateTime(now.year, now.month, now.day);
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 1),
        initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      );
      if (range == null) return;
      setState(() {
        _selectedFilter = label;
        _customRange = range;
      });
      return;
    }

    setState(() {
      _selectedFilter = label;
    });
  }

  List<EmployeeVisit> _applyFilter(List<EmployeeVisit> visits) {
    final now = DateTime.now();
    if (_selectedFilter == _filterToday) {
      return visits.where((v) => _isSameDay(_visitDate(v), now)).toList();
    }
    if (_selectedFilter == _filterMonth) {
      return visits
          .where((v) => _isSameMonth(_visitDate(v), now))
          .toList();
    }
    if (_selectedFilter == _filterYear) {
      return visits
          .where((v) => _isSameYear(_visitDate(v), now))
          .toList();
    }
    if (_selectedFilter == _filterCustom) {
      if (_customRange == null) return visits;
      return visits.where((v) {
        final d = _visitDate(v);
        if (d == null) return false;
        final visitUtc = _toUtcDateOnly(d);
        final startUtc = _toUtcDateOnly(_customRange!.start);
        final endUtc = _toUtcDateOnly(_customRange!.end);
        return !visitUtc.isBefore(startUtc) && !visitUtc.isAfter(endUtc);
      }).toList();
    }
    return visits;
  }

  DateTime? _visitDate(EmployeeVisit visit) {
    return visit.punchIn ?? visit.punchOut;
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    final aUtc = _toUtcDateOnly(a);
    final bUtc = _toUtcDateOnly(b);
    return aUtc.year == bUtc.year &&
        aUtc.month == bUtc.month &&
        aUtc.day == bUtc.day;
  }

  bool _isSameMonth(DateTime? a, DateTime b) {
    if (a == null) return false;
    final aUtc = _toUtcDateOnly(a);
    final bUtc = _toUtcDateOnly(b);
    return aUtc.year == bUtc.year && aUtc.month == bUtc.month;
  }

  bool _isSameYear(DateTime? a, DateTime b) {
    if (a == null) return false;
    final aUtc = _toUtcDateOnly(a);
    final bUtc = _toUtcDateOnly(b);
    return aUtc.year == bUtc.year;
  }

  String _formatRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    final s =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final e =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    return '$s to $e';
  }

  DateTime _toUtcDateOnly(DateTime dt) {
    final utc = dt.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  Marker _buildMarker(EmployeeVisit visit, int sequence) {
    final isStart = sequence == 1;
    final isEnd = sequence > 1 && sequence == (ref
            .read(visitViewModelProvider)
            .visits
            .value
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
    final aDate = a.punchIn;
    final bDate = b.punchIn;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  }



void _showVisitDetails(EmployeeVisit visit, int sequence) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
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

              _detailRow(
                'Punch In at:',
                _formatDateTime(visit.punchIn),
              ),
              _detailRow(
                'Punch Out at:',
                _formatDateTime(visit.punchOut),
              ),

              if (visit.shopName != null && visit.shopName!.isNotEmpty)
                _detailRow('Shop Name:', visit.shopName!),

              if (visit.address != null && visit.address!.isNotEmpty)
                _detailRow('Address:', visit.address!),

              if (visit.ownerName != null && visit.ownerName!.isNotEmpty)
                _detailRow('Owner Name:', visit.ownerName!),

              if (visit.mobileNo != null && visit.mobileNo!.isNotEmpty)
                _detailRow('Contact No:', visit.mobileNo!),

                //  _detailRow(
                  //   'Accuracy:',
                  //   '${visit.accuracy.toStringAsFixed(2)} m',
                  // ),

                  // _detailRow(
                  //   'Latitude:',
                  //   '${visit.latitude.toStringAsFixed(6)}',
                  // ),

                  //     _detailRow(
                  //   'Longitude:',
                  //   '${visit.longitude.toStringAsFixed(6)}',
                  // ),

              const SizedBox(height: 10),
            ],
          ),
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

  String _formatDateTime(DateTime? value) {
    if (value == null) return '--';
    final local = value.toLocal();
    final date =
        '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}';
    return '$date $time';
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
                    .read(visitViewModelProvider.notifier)
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
