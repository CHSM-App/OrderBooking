import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addEmployee.dart';
import 'package:order_booking_app/screens/admin_screen/attendence.dart';
import 'package:order_booking_app/screens/admin_screen/employee_visits_map.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/screens/employee_screen/order_details.dart';
import 'package:url_launcher/url_launcher.dart';

// Minimal Theme Colors
class MinimalTheme {
  static const primaryOrange = Color(0xFFFF8C42);
  static const backgroundGray = Color(0xFFF5F5F5);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2D2D2D);
  static const textGray = Color(0xFF6B7280);
  static const iconGray = Color(0xFF9CA3AF);
  static const successGreen = Color(0xFF10B981);
  static const errorRed = Color(0xFFEF4444);
}

class EmployeeDetailsPage extends ConsumerStatefulWidget {
  final int empId;

  const EmployeeDetailsPage({super.key, required this.empId});

  @override
  ConsumerState<EmployeeDetailsPage> createState() =>
      _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends ConsumerState<EmployeeDetailsPage> {
  String orderFilter = "Today";
  DateTimeRange? orderCustomRange;
  String visitFilter = "Today";
  DateTimeRange? visitCustomRange;
  final List<String> filters = ["All", "Today", "Month", "Year", "Custom"];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(employeeloginViewModelProvider.notifier)
          .fetchEmployeeDetails(widget.empId);
      await ref
          .read(employeeloginViewModelProvider.notifier)
          .getEmployeeVisitLocation(widget.empId);
    });
  }

  Future<void> _editEmployee() async {
    final state = ref.read(employeeloginViewModelProvider);
    final List<EmployeeLogin>? list = state.employeeDetails.value;

    if (list == null || list.isEmpty) return;

    final employee = list.first;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEmployeeForm(isEdit: true, employee: employee),
      ),
    );

    if (result == true) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .fetchEmployeeDetails(widget.empId);
    }
  }

  Future<void> _deleteEmployee(int? activeStatus) async {
    final isInactive = activeStatus == 1;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalTheme.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: MinimalTheme.errorRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
              Text(
                isInactive ? 'Enable Employee?' : 'Delete Employee?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isInactive
                    ? 'This will enable the employee.'
                    : 'You can Enable this employee from profile',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: MinimalTheme.textGray,
                ),
              ),
            ],
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: MinimalTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(isInactive ? 'Enable' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref
          .read(employeeloginViewModelProvider.notifier)
          .deleteEmployee(widget.empId);

      await ref
          .read(employeeloginViewModelProvider.notifier)
          .getEmployeeList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Employee deleted successfully"),
          backgroundColor: MinimalTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: MinimalTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  /// Shows a dialog with full employee details
  void _showEmployeeDetailsDialog(EmployeeLogin employee) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: MinimalTheme.primaryOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (employee.empName?.isNotEmpty ?? false)
                            ? employee.empName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.empName ?? "N/A",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            employee.checkinStatus == 1 ? "Active" : "Inactive",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detailRow(
                      icon: Icons.phone_outlined,
                      label: "Mobile No",
                      value: employee.empMobile,
                      color: MinimalTheme.successGreen,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _detailRow(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: employee.empEmail ?? "—",
                      color: Colors.blue,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _detailRow(
                      icon: Icons.home_outlined,
                      label: "Address",
                      value: employee.empAddress ?? "—",
                      color: Colors.purple,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _detailRow(
                      icon: Icons.location_on_outlined,
                      label: "Region",
                      value: employee.regionName ?? "—",
                      color: MinimalTheme.primaryOrange,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildIdProofRow(employee),
                  ],
                ),
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MinimalTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A single row in the employee details dialog
  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: MinimalTheme.textGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: MinimalTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdProofRow(EmployeeLogin employee) {
    final idProof = (employee.idProof ?? '').trim();
    if (idProof.isEmpty || idProof.toLowerCase() == 'null') {
      return _detailRow(
        icon: Icons.badge_outlined,
        label: "ID Proof",
        value: "—",
        color: Colors.teal,
      );
    }

    final isImage = _isImagePath(idProof);
    final isPdf = _isPdfPath(idProof);
    final fileName = _extractFileName(idProof);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openIdProof(idProof),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: Colors.teal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ID Proof",
                  style: TextStyle(
                    fontSize: 11,
                    color: MinimalTheme.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MinimalTheme.cardWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isImage
                            ? Icons.image_outlined
                            : isPdf
                                ? Icons.picture_as_pdf_outlined
                                : Icons.insert_drive_file_outlined,
                        size: 18,
                        color: isPdf ? MinimalTheme.errorRed : Colors.teal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: MinimalTheme.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Tap to open",
                        style: TextStyle(
                          fontSize: 11,
                          color: MinimalTheme.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isImagePath(String path) {
    final p = path.toLowerCase();
    return p.contains('.jpg') ||
        p.contains('.jpeg') ||
        p.contains('.png') ||
        p.contains('.webp');
  }

  bool _isPdfPath(String path) {
    return path.toLowerCase().contains('.pdf');
  }

  String _extractFileName(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    final parts = path.split('/');
    return parts.isNotEmpty ? parts.last : path;
  }

  Future<void> _openIdProof(String path) async {
    if (_isImagePath(path)) {
      _showImagePreview(path);
      return;
    }

    final uri = Uri.tryParse(path);
    if (uri == null) {
      if (!mounted) return;
      _showErrorSnackBar('Invalid ID proof link');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showErrorSnackBar('Unable to open ID proof');
    }
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 280,
                    child: Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MinimalTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _passesVisitLocationFilter(EmployeeVisit visit) {
    final ts = visit.punchIn ?? visit.punchOut;
    if (ts == null) return false;

    // Compare dates only (ignore time) using a stable key.
    // API timestamps are UTC ("Z"), so compare using UTC dates.
    final dateOnly = _toUtcDateOnly(ts);
    final todayOnly = _toUtcDateOnly(DateTime.now());
    final visitKey = dateKey(dateOnly);
    final todayKey = dateKey(todayOnly);

    switch (visitFilter) {
      case "All":
        return true;
      case "Today":
        return visitKey == todayKey;
      case "Month":
        return dateOnly.year == todayOnly.year &&
            dateOnly.month == todayOnly.month;
      case "Year":
        return dateOnly.year == todayOnly.year;
      case "Custom":
        if (visitCustomRange == null) return true;
        final startKey = dateKey(_toUtcDateOnly(visitCustomRange!.start));
        final endKey = dateKey(_toUtcDateOnly(visitCustomRange!.end));
        return visitKey >= startKey && visitKey <= endKey;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeloginViewModelProvider);
    final detailsAsync = state.employeeDetails;

    if (detailsAsync.isLoading) {
      return const Scaffold(
        backgroundColor: MinimalTheme.backgroundGray,
        body: Center(
          child: CircularProgressIndicator(
            color: MinimalTheme.primaryOrange,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (detailsAsync.hasError) {
      return Scaffold(
        backgroundColor: MinimalTheme.backgroundGray,
        body: Center(child: Text(detailsAsync.error.toString())),
      );
    }

    final List<EmployeeLogin>? list = detailsAsync.value;
    if (list == null || list.isEmpty) {
      return const Scaffold(
        backgroundColor: MinimalTheme.backgroundGray,
        body: Center(child: Text("No Employee Data Found")),
      );
    }

    final EmployeeLogin employee = list.first;
    final bool isActive = employee.checkinStatus == 1;

    return Scaffold(
      backgroundColor: MinimalTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: MinimalTheme.primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Employee Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
       actions: [

  IconButton(
    icon: const Icon(Icons.edit_outlined, color: Colors.white),
    onPressed: _editEmployee,
  ),

    employee.activeStatus == 1
        ? TextButton(
            onPressed: () => _deleteEmployee(employee.activeStatus),
            child: const Text(
              "Enable",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
            ),
          ),
        )
        : IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _deleteEmployee(employee.activeStatus),
          ),

],

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Compact Header Card
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MinimalTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (employee.empName?.isNotEmpty ?? false)
                            ? employee.empName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MinimalTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.empName ?? "N/A",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MinimalTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (employee.regionName != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: MinimalTheme.iconGray,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  employee.regionName ?? '',
                                  style: const TextStyle(
                                    color: MinimalTheme.textGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? MinimalTheme.successGreen.withOpacity(0.1)
                          : MinimalTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? "Active" : "Inactive",
                      style: TextStyle(
                        color: isActive
                            ? MinimalTheme.successGreen
                            : MinimalTheme.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.event_available_outlined,
                      label: 'Attendance',
                      color: MinimalTheme.successGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttendanceCalendarPage(
                              empId: employee.empId ?? widget.empId,
                              joiningDate: employee.joiningDate,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.map_outlined,
                      label: 'View Map',
                      color: MinimalTheme.primaryOrange,
                      onTap: () {
                        final empId = employee.empId ?? widget.empId;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmployeeVisitsMapPage(
                              empId: empId,
                              empName: employee.empName ?? 'Employee',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.info_outline_rounded,
                      label: 'Details',
                      color: MinimalTheme.errorRed,
                      onTap: () => _showEmployeeDetailsDialog(employee),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Visited Shops Section
            _sectionHeader(
              title: 'Visited Shops & Orders',
              icon: Icons.store_outlined,
              filter: visitFilter,
              onFilterChanged: (value) async {
                if (value == "Custom") {
                  final now = DateTime.now();
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 1),
                    initialDateRange: visitCustomRange ??
                        DateTimeRange(start: now, end: now),
                  );
                  if (range == null) return;
                  setState(() {
                    visitFilter = value;
                    visitCustomRange = range;
                  });
                } else {
                  setState(() {
                    visitFilter = value;
                    visitCustomRange = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            _buildVisitsList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: MinimalTheme.cardWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required IconData icon,
    required String filter,
    required Function(String) onFilterChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: MinimalTheme.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MinimalTheme.textDark,
                ),
              ),
            ],
          ),
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: MinimalTheme.cardWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButton<String>(
              value: filter,
              underline: const SizedBox(),
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: MinimalTheme.primaryOrange,
              ),
              items: filters
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onFilterChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsList() {
    final visitsAsync =
        ref.watch(employeeloginViewModelProvider).employeeVisitLocation;

    return visitsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          color: MinimalTheme.primaryOrange,
          strokeWidth: 2.5,
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(e.toString(),
            style: const TextStyle(color: MinimalTheme.textGray)),
      ),
      data: (visits) {
        final filteredVisits = visits
            .where(_passesVisitLocationFilter)
            .toList()
          ..sort((a, b) {
            final aDate = a.punchIn ?? a.punchOut;
            final bDate = b.punchIn ?? b.punchOut;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

        if (filteredVisits.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No visits for this filter",
                style: TextStyle(color: MinimalTheme.textGray)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filteredVisits.length,
          itemBuilder: (_, index) {
            final v = filteredVisits[index];
            return _visitCard(v);
          },
        );
      },
    );
  }

  // ── UPDATED: Side-by-side layout — shop info (left) | orders (right) ───────
  Widget _visitCard(EmployeeVisit visit) {
    final orders = visit.orders ?? const <Order>[];
    final shopName =
        visit.shopName ?? (orders.isNotEmpty ? orders.first.shopNamep : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: MinimalTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── LEFT: Shop info ─────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shop icon + name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: MinimalTheme.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.store_outlined,
                            color: MinimalTheme.primaryOrange,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shopName ?? "Unknown Shop",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: MinimalTheme.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Punch-in / Punch-out chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _timeChip("In", visit.punchIn, MinimalTheme.successGreen),
                        _timeChip("Out", visit.punchOut, MinimalTheme.errorRed),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────────
            if (orders.isNotEmpty)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey.shade200,
                indent: 10,
                endIndent: 10,
              ),

            // ── RIGHT: Orders list (empty area when no orders) ───────────────
            Expanded(
              flex: 5,
              child: orders.isEmpty
                  ? const SizedBox() // intentionally blank
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Orders" label
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 13,
                                color: MinimalTheme.iconGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Orders (${orders.length})",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: MinimalTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Order items
                          ...orders.asMap().entries.map((entry) {
                            final index = entry.key;
                            final order = entry.value;
                            final orderNumber =
                                order.serverOrderId ?? (index + 1);
                            return _visitOrderCard(order, orderNumber);
                          }),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visitOrderCard(Order order, int orderNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE1C2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsPage(
                  orderNumber: orderNumber,
                  order: order,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAD1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: MinimalTheme.primaryOrange,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #$orderNumber",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹${order.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: MinimalTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: MinimalTheme.iconGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeChip(String label, DateTime? time, Color color) {
    String formattedTime = "--";
    if (time != null) {
      try {
        final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = time.hour >= 12 ? "PM" : "AM";
        formattedTime = "$hour:$minute $period";
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper methods ──────────────────────────────────────────────────────────

  DateTime parseSqlServerDate(String raw) {
    final dt = DateTime.parse(raw);
    return DateTime(dt.year, dt.month, dt.day);
  }

  int dateKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;


  DateTime _toUtcDateOnly(DateTime dt) {
    final utc = dt.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }
}
