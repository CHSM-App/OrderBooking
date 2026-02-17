import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'dart:ui';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
class _AppColors {
  static const bg = Color(0xFFF4F6FB);          // soft off-white
  static const surface = Color(0xFFFFFFFF);     // pure white
  static const card = Color(0xFFFFFFFF);        // white cards
  static const cardBorder = Color(0xFFE4E9F2);  // subtle grey border

  static const accentA = Color(0xFF3B7EF6);     // vivid blue
  static const accentB = Color(0xFF6C4FEE);     // violet
  static const accentC = Color(0xFF00B894);     // teal-green

  static const textPrimary = Color(0xFF1A2340);   // deep navy
  static const textSecondary = Color(0xFF6B7A99); // muted slate
  static const textTertiary = Color(0xFFB0BAD0);  // light hint

  static const present = Color(0xFF00B894);
  static const absent = Color(0xFFFF4D6D);
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

  late AnimationController _headerCtrl;
  late AnimationController _listCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  static const _monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _headerCtrl.forward();
    _listCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .getAttendanceReport(widget.companyId);
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    _listCtrl.reverse().then((_) {
      setState(() {
        selectedDate =
            DateTime(selectedDate.year, selectedDate.month + delta);
      });
      _listCtrl.forward();
    });
  }

  String get _selectedMonthKey =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';

  String get _monthYearLabel =>
      '${_monthNames[selectedDate.month - 1]}  ${selectedDate.year}';

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(employeeloginViewModelProvider);

    return Scaffold(
      backgroundColor: _AppColors.bg,
      // ── AppBar ─────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _GlassAppBar(title: 'Attendance'),
      ),
      body: Column(
        children: [
          // ── Month navigator ───────────────────────────
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: _MonthNavigator(
                label: _monthYearLabel,
                onPrevious: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
              ),
            ),
          ),

          // ── Divider ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: _AppColors.cardBorder, height: 1),
          ),
          const SizedBox(height: 8),

          // ── List ──────────────────────────────────────
          Expanded(
            child: attendanceState.attendanceReport.when(
              loading: () => const _LoadingState(),
              error: (err, _) => _ErrorState(message: err.toString()),
              data: (attendanceList) {
                final filtered = attendanceList
                    .where((i) => i.month == _selectedMonthKey)
                    .toList();

                if (filtered.isEmpty) {
                  return const _EmptyState();
                }

                return FadeTransition(
                  opacity: _listCtrl,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final item = filtered[index];
                      return _AttendanceCard(
                        item: item,
                        index: index,
                      );
                    },
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

// ─────────────────────────────────────────────
//  Glass AppBar
// ─────────────────────────────────────────────
class _GlassAppBar extends StatelessWidget {
  final String title;
  const _GlassAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _AppColors.surface.withOpacity(0.92),
            border: Border(
              bottom: BorderSide(color: _AppColors.cardBorder, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B7EF6).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _AppColors.cardBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: _AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  // Placeholder for symmetry
                  const SizedBox(width: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Month navigator
// ─────────────────────────────────────────────
class _MonthNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B7EF6).withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
            Expanded(
              child: Column(
                children: [
                  Text(
                    label.split('  ')[0], // month name
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label.split('  ').length > 1
                        ? label.split('  ')[1]
                        : '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: _AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_AppColors.accentA, _AppColors.accentB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Attendance Card
// ─────────────────────────────────────────────
class _AttendanceCard extends StatefulWidget {
  final dynamic item;
  final int index;
  const _AttendanceCard({required this.item, required this.index});

  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<_AttendanceCard>
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
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
    final item = widget.item;
    final totalDays = item.totalWorkingDays ?? 0;
    final totalHours = item.totalHours ?? 0.0;
    // Compute a simple attendance ratio (assuming 26 working days/month)
    final ratio = (totalDays / 26).clamp(0.0, 1.0);

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: _AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B7EF6).withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Top row ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      // Avatar
                      _Avatar(name: item.empName ?? '?'),
                      const SizedBox(width: 14),
                      // Name + badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.empName ?? '—',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _AppColors.textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _AttendanceBadge(ratio: ratio),
                          ],
                        ),
                      ),
                      // Hours chip
                      _HoursChip(hours: totalHours),
                    ],
                  ),
                ),

                // ── Divider ──────────────────────────────
                Divider(
                  color: _AppColors.cardBorder,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                // ── Stats row ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: [
                      _StatItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'Working Days',
                        value: '$totalDays',
                        color: _AppColors.accentA,
                      ),
                      _VerticalDivider(),
                      _StatItem(
                        icon: Icons.access_time_rounded,
                        label: 'Total Hours',
                        value:
                            '${totalHours.toStringAsFixed(2)}h',
                        color: _AppColors.accentC,
                      ),
                      _VerticalDivider(),
                      _StatItem(
                        icon: Icons.trending_up_rounded,
                        label: 'Attendance',
                        value:
                            '${(ratio * 100).toStringAsFixed(0)}%',
                        color: _AppColors.accentB,
                      ),
                    ],
                  ),
                ),

                // ── Progress bar ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _ProgressBar(ratio: ratio),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Supporting widgets
// ─────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : '?';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_AppColors.accentA, _AppColors.accentB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  final double ratio;
  const _AttendanceBadge({required this.ratio});

  @override
  Widget build(BuildContext context) {
    final isGood = ratio >= 0.75;
    final color = isGood ? _AppColors.present : _AppColors.absent;
    final label = isGood ? 'Regular' : 'Low Attendance';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursChip extends StatelessWidget {
  final double hours;
  const _HoursChip({required this.hours});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _AppColors.accentC.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AppColors.accentC.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            hours.toStringAsFixed(2),
            style: const TextStyle(
              color: _AppColors.accentC,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'hrs',
            style: TextStyle(
              color: _AppColors.accentC,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
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
            _AppColors.cardBorder.withOpacity(0.2),
            _AppColors.cardBorder,
            _AppColors.cardBorder.withOpacity(0.2),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double ratio;
  const _ProgressBar({required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attendance rate',
              style: TextStyle(
                color: _AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: _AppColors.bg,
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: ratio >= 0.75
                          ? [_AppColors.accentC, _AppColors.accentA]
                          : [_AppColors.absent, _AppColors.absent.withOpacity(0.6)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Loading / Error / Empty states
// ─────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation(_AppColors.accentA),
              backgroundColor: _AppColors.cardBorder,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading attendance…',
            style: TextStyle(color: _AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

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
                color: _AppColors.absent.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _AppColors.absent.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _AppColors.absent,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _AppColors.accentA.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _AppColors.accentA.withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: _AppColors.accentA,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No data for this month',
            style: TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try navigating to a different month.',
            style: TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}