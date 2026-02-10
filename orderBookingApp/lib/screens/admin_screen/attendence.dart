import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AttendanceStatus { present, absent, leave }

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({super.key});

  @override
  State<AttendanceCalendarPage> createState() =>
      _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  DateTime _focusedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;

  final Map<DateTime, AttendanceStatus> attendanceData = {
    DateTime(2026, 1, 1): AttendanceStatus.present,
    DateTime(2026, 1, 2): AttendanceStatus.leave,
    DateTime(2026, 1, 3): AttendanceStatus.present,
    DateTime(2026, 1, 7): AttendanceStatus.absent,
    DateTime(2026, 1, 8): AttendanceStatus.absent,
    DateTime(2026, 1, 9): AttendanceStatus.absent,
    DateTime(2026, 1, 10): AttendanceStatus.present,
    DateTime(2026, 1, 12): AttendanceStatus.present,
  };

  // ---------- Helpers ----------
  Color _statusColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF16A34A);
      case AttendanceStatus.leave:
        return const Color(0xFFF59E0B);
      case AttendanceStatus.absent:
        return const Color(0xFFDC2626);
      default:
        return Colors.transparent;
    }
  }

  String _statusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.leave:
        return 'LEAVE';
      case AttendanceStatus.absent:
        return 'ABSENT';
    }
  }

  int _countStatus(AttendanceStatus status) {
    return attendanceData.entries.where((e) =>
        e.key.year == _focusedMonth.year &&
        e.key.month == _focusedMonth.month &&
        e.value == status).length;
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + offset);
      _selectedYear = _focusedMonth.year;
    });
  }

  // ---------- Bottom Sheet ----------
  void _showDetails(DateTime date) {
    final status = attendanceData[date];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(date),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _statusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  status == null ? 'NO DATA' : _statusText(status),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Check-in : 09:30 AM'),
            const SizedBox(height: 4),
            const Text('Check-out: 06:15 PM'),
          ],
        ),
      ),
    );
  }

  // ---------- Summary Item ----------
  Widget _summaryItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstDay =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final startWeekday = firstDay.weekday % 7;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Attendance Calendar',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2563EB)),
      ),
      body: Column(
        children: [
          // ---------- Month Header ----------
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy').format(_focusedMonth),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime.now();
                      _selectedYear = DateTime.now().year;
                    });
                  },
                  child: const Text('Today'),
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  underline: const SizedBox(),
                  items: List.generate(
                    10,
                    (i) {
                      final year = DateTime.now().year - 5 + i;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    },
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                      _focusedMonth =
                          DateTime(_selectedYear, _focusedMonth.month);
                    });
                  },
                ),
              ],
            ),
          ),

          // ---------- Summary ----------
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryItem(
                  color: const Color(0xFF16A34A),
                  label: 'Present',
                  count: _countStatus(AttendanceStatus.present),
                ),
                _summaryItem(
                  color: const Color(0xFFDC2626),
                  label: 'Absent',
                  count: _countStatus(AttendanceStatus.absent),
                ),
                _summaryItem(
                  color: const Color(0xFFF59E0B),
                  label: 'Leave',
                  count: _countStatus(AttendanceStatus.leave),
                ),
              ],
            ),
          ),
           const SizedBox(height: 15),
          // ---------- Weekdays ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map(
                    (e) => Expanded(
                      child: Center(
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // ---------- Calendar Grid ----------
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: daysInMonth + startWeekday,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.95,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox();

                final day = index - startWeekday + 1;
                final date = DateTime(
                    _focusedMonth.year, _focusedMonth.month, day);
                final status = attendanceData[date];

                return GestureDetector(
                  onTap: () => _showDetails(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: status == null
                            ? const Color(0xFFE5E7EB)
                            : _statusColor(status),
                        width: 1.2,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '$day',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
