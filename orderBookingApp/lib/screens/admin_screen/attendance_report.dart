import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────

class _T {
  // Grey Background
  static const bg         = Color(0xFFF1F3F6);   // main grey background
  static const surface    = Color(0xFFFFFFFF);
  static const card       = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE4E7EC);

  // Accent Colors
  static const cyan       = Color(0xFF00BFA6);
  static const violet     = Color(0xFF6C63FF);
  static const rose       = Color(0xFFE5395B);
  static const amber      = Color(0xFFFFA726);

  // Text
  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted     = Color(0xFF9CA3AF);

  static const present = cyan;
  static const absent  = rose;
}




// ─────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────
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

  late AnimationController _bgCtrl;
  late AnimationController _listCtrl;
  late Animation<double> _bgAnim;

  static const _monthNames = [
    'JAN','FEB','MAR','APR','MAY','JUN',
    'JUL','AUG','SEP','OCT','NOV','DEC',
  ];
  static const _monthFull = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December',
  ];

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();

     _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .getAttendanceReport(widget.companyId);
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportPdf(List<AttendanceReport> employees) async {
    final filtered = employees
        .where((emp) => emp.month == _selectedMonthKey)
        .toList();

    if (filtered.isEmpty) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Attendance Report - ${_monthFull[selectedDate.month - 1]} ${selectedDate.year}',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            ...filtered.map((emp) {
              final totalDays = emp.totalWorkingDays ?? 0;
              final totalHours = emp.totalHours ?? 0.0;

              return pw.Container(
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
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Working Days: $totalDays'),
                        pw.Text('Total Working Hours: ${totalHours.toStringAsFixed(1)}'),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  void _changeMonth(int delta) {
    final newDate = DateTime(selectedDate.year, selectedDate.month + delta);
    final now = DateTime.now();
    if (newDate.year > now.year ||
        (newDate.year == now.year && newDate.month > now.month)) return;

    _listCtrl.reverse().then((_) {
      setState(() => selectedDate = newDate);
      _listCtrl.forward();
    });
  }

  String get _selectedMonthKey =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';

  bool get _disableNext {
    final now = DateTime.now();
    return selectedDate.year == now.year && selectedDate.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(employeeloginViewModelProvider);

    return Scaffold(
      backgroundColor: _T.bg,
      body: Stack(
        children: [
          // ── Animated mesh background ──────────────────
          _MeshBackground(animation: _bgAnim),

          // ── Content ───────────────────────────────────
          SafeArea(
            child: Column(
              children: [
               _Header(
  onBack: () => Navigator.pop(context),
  onExportPdf: () => _exportPdf(
      attendanceState.attendanceReport.value ?? [],
  ),
),
                _MonthStrip(
                  month: _monthFull[selectedDate.month - 1],
                  year: selectedDate.year,
                  shortMonth: _monthNames[selectedDate.month - 1],
                  onPrev: () => _changeMonth(-1),
                  onNext: _disableNext ? null : () => _changeMonth(1),
                ),
                Expanded(
                  child: attendanceState.attendanceReport.when(
                    loading: () => const _Loader(),
                    error: (e, _) => _ErrorView(message: e.toString()),
                    data: (list) {
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

                      // stats for header banner
                      final totalPresent = filtered
                          .fold<int>(0, (s, e) => s + (e.totalWorkingDays ?? 0));
                      final avgHours = filtered.isEmpty
                          ? 0.0
                          : filtered.fold<double>(
                                  0, (s, e) => s + (e.totalHours ?? 0)) /
                              filtered.length;

                      return FadeTransition(
                        opacity: _listCtrl,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            _StatsBanner(
                              employeeCount: filtered.length,
                              totalPresent: totalPresent,
                              avgHours: avgHours,
                            ),
                            const SizedBox(height: 20),
                            ...filtered.asMap().entries.map((entry) =>
                                _EmployeeCard(
                                  item: entry.value,
                                  index: entry.key,
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Animated mesh background
// ─────────────────────────────────────────────
class _MeshBackground extends StatelessWidget {
  final Animation<double> animation;
  const _MeshBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return CustomPaint(
          size: Size.infinite,
          painter: _MeshPainter(animation.value),
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double t;
  _MeshPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Orb 1 – cyan top-left
    final p1 = Offset(
      size.width * (0.1 + 0.15 * math.sin(t * math.pi)),
      size.height * (0.05 + 0.1 * math.cos(t * math.pi)),
    );
    canvas.drawCircle(
      p1,
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF00E5CC).withOpacity(0.10),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: p1, radius: size.width * 0.55)),
    );

    // Orb 2 – violet center-right
    final p2 = Offset(
      size.width * (0.75 + 0.1 * math.cos(t * math.pi)),
      size.height * (0.35 + 0.08 * math.sin(t * math.pi * 1.3)),
    );
    canvas.drawCircle(
      p2,
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF7C5CFC).withOpacity(0.12),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: p2, radius: size.width * 0.5)),
    );

    // Orb 3 – rose bottom
    final p3 = Offset(
      size.width * (0.3 + 0.12 * math.sin(t * math.pi * 0.7)),
      size.height * (0.75 + 0.07 * math.cos(t * math.pi * 0.9)),
    );
    canvas.drawCircle(
      p3,
      size.width * 0.45,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFF3D6B).withOpacity(0.08),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: p3, radius: size.width * 0.45)),
    );
  }

  @override
  bool shouldRepaint(_MeshPainter old) => old.t != t;
}

// ─────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onExportPdf; // Add this

  const _Header({
    required this.onBack,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _T.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _T.textSecondary,
                size: 16,
              ),
            ),
          ),
          const Spacer(),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'ATTENDANCE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _T.textPrimary,
                    letterSpacing: 3,
                  ),
                ),
                TextSpan(
                  text: ' REPORT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _T.cyan,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // PDF export button
          GestureDetector(
            onTap: onExportPdf,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _T.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.cardBorder),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: _T.rose,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────
//  Month strip
// ─────────────────────────────────────────────
class _MonthStrip extends StatelessWidget {
  final String month;
  final String shortMonth;
  final int year;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  const _MonthStrip({
    required this.month,
    required this.shortMonth,
    required this.year,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          _ArrowBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Expanded(
            child: Column(
              children: [
                Text(
                  month.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _T.textPrimary,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                ),
                Text(
                  '$year',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _T.textSecondary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _ArrowBtn(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            disabled: onNext == null,
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  const _ArrowBtn({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [_T.cyan, _T.violet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: disabled ? _T.cardBorder : null,
        ),
        child: Icon(
          icon,
          color: disabled ? _T.textMuted : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Stats banner
// ─────────────────────────────────────────────
class _StatsBanner extends StatelessWidget {
  final int employeeCount;
  final int totalPresent;
  final double avgHours;

  const _StatsBanner({
    required this.employeeCount,
    required this.totalPresent,
    required this.avgHours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _T.cyan.withOpacity(0.12),
            _T.violet.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _T.cyan.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _BannerStat(
            value: '$employeeCount',
            label: 'EMPLOYEES',
            color: _T.cyan,
          ),
          _BannerDivider(),
          // _BannerStat(
          //   value: '$totalPresent',
          //   label: 'TOTAL DAYS',
          //   color: _T.violet,
          // ),
          _BannerDivider(),
          _BannerStat(
            value: '${avgHours.toStringAsFixed(1)}h',
            label: 'AVG HOURS',
            color: _T.amber,
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _BannerStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: _T.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            _T.cyan.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Employee Card
// ─────────────────────────────────────────────
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
      duration: Duration(milliseconds: 450 + widget.index * 70),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _ctrl.forward();
    });
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
    final ratio      = (totalDays / 26).clamp(0.0, 1.0);
    final noData     = totalDays == 0;

    final statusColor = noData
        ? _T.textMuted
        : ratio >= 0.75
            ? _T.present
            : _T.absent;

    final name = widget.item.empName ?? '—';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _T.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _T.cardBorder),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(noData ? 0 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Subtle left accent bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: noData
                            ? [_T.textMuted, _T.textMuted]
                            : [statusColor, statusColor.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  child: Column(
                    children: [
                      // ── Row 1: Avatar + Name + Hours chip ──
                      Row(
                        children: [
                          // Gradient avatar
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: noData
                                    ? [_T.textMuted, _T.cardBorder]
                                    : [_T.cyan, _T.violet],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name + badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: _T.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                _StatusPill(
                                  label: noData
                                      ? 'No Data'
                                      : ratio >= 0.75
                                          ? 'Regular'
                                          : 'Low Attendance',
                                  color: statusColor,
                                ),
                              ],
                            ),
                          ),

                          // Hours chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _T.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _T.amber.withOpacity(0.25)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  totalHours.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: _T.amber,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'HRS',
                                  style: TextStyle(
                                    color: _T.amber,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Row 2: Stats ──
                      Row(
                        children: [
                          _MiniStat(
                            icon: Icons.calendar_today_rounded,
                            value: '$totalDays',
                            label: 'DAYS',
                            color: _T.cyan,
                          ),
                          const SizedBox(width: 8),
                          _MiniStat(
                            icon: Icons.show_chart_rounded,
                            value: noData
                                ? '—'
                                : '${(ratio * 100).toStringAsFixed(0)}%',
                            label: 'RATE',
                            color: statusColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Progress bar ──
                      _GlowProgressBar(ratio: noData ? 0 : ratio,
                          color: statusColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//  Status pill
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mini stat
// ─────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: _T.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Glow progress bar
// ─────────────────────────────────────────────
class _GlowProgressBar extends StatelessWidget {
  final double ratio;
  final Color color;
  const _GlowProgressBar({required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendance Rate',
              style: TextStyle(
                color: _T.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            // Track
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: _T.cardBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Fill with glow
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: ratio >= 0.75
                        ? [_T.cyan, _T.cyan.withOpacity(0.6)]
                        : [_T.rose, _T.rose.withOpacity(0.6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 6,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Loading state
// ─────────────────────────────────────────────
class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation(_T.cyan),
              backgroundColor: _T.cardBorder,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'LOADING DATA',
            style: TextStyle(
              color: _T.textSecondary,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


//  Error state

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
                shape: BoxShape.circle,
                color: _T.rose.withOpacity(0.1),
                border: Border.all(color: _T.rose.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _T.rose,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SOMETHING WENT WRONG',
              style: TextStyle(
                color: _T.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _T.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}