import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

enum AttendanceStatus { present, absent }

class AttendanceCalendarPage extends ConsumerStatefulWidget {
  final int empId;
  final String? joiningDate;

  const AttendanceCalendarPage({
    super.key,
    required this.empId,
    this.joiningDate,
  });

  @override
  ConsumerState<AttendanceCalendarPage> createState() =>
      _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState
    extends ConsumerState<AttendanceCalendarPage> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _joiningDateNormalized;

  @override
  void initState() {
    super.initState();

    if (widget.joiningDate != null) {
      try {
        final parsed = DateTime.parse(widget.joiningDate!);
        _joiningDateNormalized = DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
        );
      } catch (e) {
        print('Error parsing joining date: $e');
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkInViewModelProvider.notifier).getAttendance(widget.empId);
    });
  }

  // ---------- Helpers ----------
  bool _isFutureDate(DateTime date) => date.isAfter(DateTime.now());

  bool _isBeforeJoining(DateTime date) =>
      _joiningDateNormalized != null && date.isBefore(_joiningDateNormalized!);

  bool _isBlockedDate(DateTime date) =>
      _isFutureDate(date) || _isBeforeJoining(date);

  AttendanceStatus _mapToStatus(CheckInStatusRequest item) {
    if (item.checkinStatus == 1) return AttendanceStatus.present;
    if (item.inTime != null) return AttendanceStatus.present;
    return AttendanceStatus.absent;
  }

  Map<DateTime, AttendanceStatus> _buildAttendanceMap(
    List<CheckInStatusRequest> list,
  ) {
    final map = <DateTime, AttendanceStatus>{};

    for (final item in list) {
      if (item.inDate == null) continue;
      final parsed = DateTime.parse(item.inDate!);
      final dayKey = DateTime(parsed.year, parsed.month, parsed.day);
      map[dayKey] = _mapToStatus(item);
    }

    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      if (!_isBlockedDate(date) && !map.containsKey(date)) {
        map[date] = AttendanceStatus.absent;
      }
    }

    return map;
  }

  void _onDateTap(DateTime date, List<CheckInStatusRequest> list) {
    if (_isBlockedDate(date)) return;

    final recordsForDay = list.where((e) {
      if (e.inDate == null) return false;
      final d = DateTime.parse(e.inDate!);
      return DateTime(d.year, d.month, d.day) ==
          DateTime(date.year, date.month, date.day);
    }).toList();

    _showDayDetails(date, recordsForDay);
  }

  void _showDayDetails(DateTime date, List<CheckInStatusRequest> records) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(date),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (records.isEmpty)
              const Text("No attendance records")
            else
              ...records.map((r) {
                final inTime = r.inTime != null
                    ? DateFormat('hh:mm a').format(DateTime.parse(r.inTime!))
                    : '--';
                final outTime = r.outTime != null
                    ? DateFormat('hh:mm a').format(DateTime.parse(r.outTime!))
                    : '--';
                return ListTile(
                  title: Text("Check-in: $inTime, Check-out: $outTime"),
                  leading: Icon(
                    r.checkinStatus == 1
                        ? Icons.check_circle
                        : Icons.check_circle,
                    color: r.checkinStatus == 1 ? Colors.green : Colors.green,
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // ---------- Month/Year Dropdown with Arrows ----------
  Widget _monthYearSelector() {
    final months = List.generate(12, (i) => i + 1);
    final currentYear = DateTime.now().year;
    final years = List.generate(30, (i) => currentYear - i);

    void _changeMonth(int offset) {
      setState(() {
        _focusedMonth = DateTime(
          _focusedMonth.year,
          _focusedMonth.month + offset,
        );
      });
      ref.read(checkInViewModelProvider.notifier).getAttendance(widget.empId);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Backward Arrow
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
        ),

        // Month Dropdown
        DropdownButton<int>(
          value: _focusedMonth.month,
          items: months
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(DateFormat('MMMM').format(DateTime(0, m))),
                ),
              )
              .toList(),
          onChanged: (m) {
            if (m != null) {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, m);
              });
              ref
                  .read(checkInViewModelProvider.notifier)
                  .getAttendance(widget.empId);
            }
          },
        ),
        const SizedBox(width: 8),

        // Year Dropdown
        DropdownButton<int>(
          value: _focusedMonth.year,
          items: years
              .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
              .toList(),
          onChanged: (y) {
            if (y != null) {
              setState(() {
                _focusedMonth = DateTime(y, _focusedMonth.month);
              });
              ref
                  .read(checkInViewModelProvider.notifier)
                  .getAttendance(widget.empId);
            }
          },
        ),

        // Forward Arrow
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  // ---------- Weekday Header ----------
  Widget _weekdayHeader() {
    const weekdays = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(checkInViewModelProvider).attendanceList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Calendar"),
        centerTitle: true,
      ),
      body: attendanceAsync.when(
        data: (data) {
          final list = data;
          final attendanceData = _buildAttendanceMap(list);

          final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
          final daysInMonth = DateUtils.getDaysInMonth(
            _focusedMonth.year,
            _focusedMonth.month,
          );
          final startWeekday = firstDay.weekday % 7;

          return Column(
            children: [
              const SizedBox(height: 16),
              _monthYearSelector(), // <-- Month/Year with arrows
              const SizedBox(height: 16),
              _weekdayHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: daysInMonth + startWeekday,
                  itemBuilder: (context, index) {
                    if (index < startWeekday) return const SizedBox();
                    final day = index - startWeekday + 1;
                    final date = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month,
                      day,
                    );
                    final status = attendanceData[date];
                    final isBlocked = _isBlockedDate(date);

                    return GestureDetector(
                      onTap: () => _onDateTap(date, list),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isBlocked
                              ? Colors.grey[200]
                              : status == AttendanceStatus.present
                              ? Colors.green[100]
                              : Colors.red[100],
                          border: Border.all(
                            color: status == AttendanceStatus.present
                                ? Colors.green
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$day'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
