import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Design tokens — aligned with project theme
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  // Backgrounds
  static const bg      = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);

  static const green   = Color(0xFF00C853);
  static const purple  = Color(0xFF5E35B1);
  static const red     = Color(0xFFFF6B6B);
  static const amber   = Color(0xFFFFA726);

  // Attendance semantic colours
  static const present = Color(0xFF00C853);
  static const absent  = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFA726);

  // Text
  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textMuted     = Color(0xFF9E9E9E);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────────────────────────────────────
class AttendanceReportPage extends ConsumerStatefulWidget {
  final String companyId;
  const AttendanceReportPage({super.key, required this.companyId});

  @override
  ConsumerState<AttendanceReportPage> createState() =>
      _AttendanceReportPageState();
}

class _AttendanceReportPageState extends ConsumerState<AttendanceReportPage>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();

  late AnimationController _pageCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  late AnimationController _listCtrl;

  static const _monthFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();

    // Page entrance — same pattern as HomePage / AdminHomePage
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeInOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));

    // Month-change fade
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .getAttendanceReport(widget.companyId);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String get _selectedMonthKey =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';

  bool get _disableNext {
    final now = DateTime.now();
    return selectedDate.year == now.year && selectedDate.month == now.month;
  }

  void _changeMonth(int delta) {
    final newDate =
        DateTime(selectedDate.year, selectedDate.month + delta);
    final now = DateTime.now();
    if (newDate.year > now.year ||
        (newDate.year == now.year && newDate.month > now.month)) return;

    _listCtrl.reverse().then((_) {
      setState(() => selectedDate = newDate);
      _listCtrl.forward();
    });
  }

  Future<void> _exportPdf(List<AttendanceReport> employees) async {
    final filtered =
        employees.where((emp) => emp.month == _selectedMonthKey).toList();
    if (filtered.isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Attendance Report — ${_monthFull[selectedDate.month - 1]} ${selectedDate.year}',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          ...filtered.map(
            (emp) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    emp.empName ?? '—',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          'Working Days: ${emp.totalWorkingDays ?? 0}'),
                      pw.Text(
                          'Total Distance: ${emp.TotlaDistance ?? 0}'),
                      pw.Text(
                          'Total Hours: ${(emp.totalHours ?? 0.0).toStringAsFixed(1)}h'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(employeeloginViewModelProvider);

    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                // ── App-bar ──────────────────────────────────────────
                _buildAppBar(attendanceState.attendanceReport.value ?? []),

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildMonthSelector(),
                ),

                // ── List ─────────────────────────────────────────────
                Expanded(
                  child: attendanceState.attendanceReport.when(
                    loading: () => const _Loader(),
                    error:   (e, _) => _ErrorView(message: e.toString()),
                    data:    (list) => _buildList(list),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar(List<AttendanceReport> reports) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Back button — same style as project pattern
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _T.textSecondary,
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Attendance Report',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _T.textPrimary,
                ),
              ),
            ),
          ),

          // PDF export button
          InkWell(
            onTap: () => _exportPdf(reports),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _T.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.red.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 18,
                color: _T.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Month selector ───────────────────────────────────────────────────────────
  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prev
          _MonthNavBtn(
            icon: Icons.chevron_left_rounded,
            onTap: () => _changeMonth(-1),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _monthFull[selectedDate.month - 1].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _T.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _T.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Next
          _MonthNavBtn(
            icon: Icons.chevron_right_rounded,
            onTap: _disableNext ? null : () => _changeMonth(1),
            disabled: _disableNext,
          ),
        ],
      ),
    );
  }

  // ── Employee list ────────────────────────────────────────────────────────────
  Widget _buildList(List<AttendanceReport> list) {
    final filtered = list.map((emp) {
      if (emp.month == _selectedMonthKey) return emp;
      return AttendanceReport(
        companyId: emp.companyId,
        empId: emp.empId,
        empName: emp.empName,
        month: _selectedMonthKey,
        totalWorkingDays: 0,
        totalHours: 0,
      );
    }).toList();

    // Summary stats
    final totalEmployees = filtered.length;
    final avgHours = filtered.isEmpty
        ? 0.0
        : filtered.fold<double>(
                0, (s, e) => s + (e.totalHours ?? 0)) /
            filtered.length;
    final regularCount = filtered
        .where((e) =>
            ((e.totalWorkingDays ?? 0) / 26).clamp(0.0, 1.0) >= 0.75)
        .length;

    return FadeTransition(
      opacity: _listCtrl,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats overview (matches _buildStatsOverview pattern) ──
                _buildStatsRow(
                  totalEmployees: totalEmployees,
                  regularCount:   regularCount,
                  avgHours:       avgHours,
                ),
                const SizedBox(height: 24),

                // ── Section header ──────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _T.purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: _T.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Employee Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _T.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Cards ───────────────────────────────────────────────
                ...filtered.asMap().entries.map(
                  (entry) => _EmployeeCard(
                    item:  entry.value,
                    index: entry.key,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row — mirrors _buildStatsOverview layout ────────────────────────
  Widget _buildStatsRow({
    required int totalEmployees,
    required int regularCount,
    required double avgHours,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 380;
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Employees',
                value: totalEmployees.toString(),
                icon: Icons.people_rounded,
                color: _T.purple,
                isSmall: isSmall,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Regular',
                value: regularCount.toString(),
                icon: Icons.verified_rounded,
                color: _T.green,
                isSmall: isSmall,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Avg Hours',
                value: '${avgHours.toStringAsFixed(1)}h',
                icon: Icons.access_time_rounded,
                color: _T.amber,
                isSmall: isSmall,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Month nav button
// ─────────────────────────────────────────────────────────────────────────────
class _MonthNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  const _MonthNavBtn({
    required this.icon,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.transparent
              : const Color(0xFF6C63FF).withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: disabled ? _T.textMuted : const Color(0xFF6C63FF),
          size: 24,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Stat card — exact replica of the shared _StatCard in HomePage / AdminHomePage
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmall;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isSmall ? 16 : 18),
          ),
          SizedBox(height: isSmall ? 8 : 10),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: _T.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: _T.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Employee card
// ─────────────────────────────────────────────────────────────────────────────
class _EmployeeCard extends StatefulWidget {
  final AttendanceReport item;
  final int index;

  const _EmployeeCard({required this.item, required this.index});

  @override
  State<_EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<_EmployeeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 60),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(
      Duration(milliseconds: widget.index * 60),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDays  = widget.item.totalWorkingDays ?? 0;
    final totalHours = widget.item.totalHours ?? 0.0;
    final ratio      = (totalDays / 26.0).clamp(0.0, 1.0);
    final noData     = totalDays == 0;

    final Color statusColor = noData
        ? _T.textMuted
        : ratio >= 0.75
            ? _T.present
            : ratio >= 0.5
                ? _T.warning
                : _T.absent;

    final String statusLabel = noData
        ? 'No Data'
        : ratio >= 0.75
            ? 'Regular'
            : ratio >= 0.5
                ? 'Moderate'
                : 'Low';

    final name = widget.item.empName ?? '—';
    final initials = name.trim().isNotEmpty
        ? name
            .trim()
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Row 1: avatar + name + hours chip ──────────────────
                Row(
                  children: [
                    // Avatar circle with initials
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: statusColor.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + status pill
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: _T.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          // Status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Hours chip
                    Row(
  children: [
    // ── Hours chip ──────────────────────────────────────────
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _T.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.amber.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            totalHours.toStringAsFixed(1),
            style: const TextStyle(
              color: _T.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'hrs',
            style: TextStyle(
              color: _T.amber,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 8), // 👈 gap between chips

    // ── Distance chip ────────────────────────────────────────
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            (widget.item.TotlaDistance ?? 0.0).toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'km',
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  ],
),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Row 2: mini stats ────────────────────────────────────
                Row(
                  children: [
                    // Days chip
                    Expanded(
                      child: _MiniInfoChip(
                        icon: Icons.today_rounded,
                        value: '$totalDays days',
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Rate chip
                    Expanded(
                      child: _MiniInfoChip(
                        icon: Icons.show_chart_rounded,
                        value: noData
                            ? '—'
                            : '${(ratio * 100).toStringAsFixed(0)}%',
                        color: statusColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Progress bar ─────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attendance Rate',
                          style: TextStyle(
                            fontSize: 11,
                            color: _T.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          noData
                              ? '—'
                              : '${(ratio * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: noData ? 0 : ratio,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFEEEEEE),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mini info chip
// ─────────────────────────────────────────────────────────────────────────────
class _MiniInfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniInfoChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Loading state
// ─────────────────────────────────────────────────────────────────────────────
class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        backgroundColor: Color(0xFFEEEEEE),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Error state
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _T.red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _T.red,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: _T.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _T.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}