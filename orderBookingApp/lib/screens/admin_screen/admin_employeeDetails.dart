import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addEmployee.dart';
import 'package:order_booking_app/screens/admin_screen/employee_visits_map.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'dart:math';
import 'package:order_booking_app/screens/employee_screen/order_details.dart';

class EmployeeDetailsPage extends ConsumerStatefulWidget {
  final int empId;

  const EmployeeDetailsPage({
    super.key,
    required this.empId,
    required Map<String, dynamic> companyId,
  });


  @override
  ConsumerState<EmployeeDetailsPage> createState() =>
      _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends ConsumerState<EmployeeDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedFilter = "Day";
  final List<String> filters = ["Day", "Month", "Year"];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .fetchEmployeeDetails(widget.empId);
      ref
          .read(visitViewModelProvider.notifier)
          .fetchEmployeeVisits(widget.empId);
      ref
          .read(ordersViewModelProvider.notifier)
          .getEmployeeOrders(widget.empId);
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _editEmployee() async {
    final state = ref.read(employeeloginViewModelProvider);
    final List<EmployeeLogin>? list = state.employeeDetails?.value;

    if (list == null || list.isEmpty) return;

    final employee = list.first;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEmployeeForm(isEdit: true, employee: employee),
      ),
    );

    // Refresh employee details if updated
    if (result == true) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .fetchEmployeeDetails(widget.empId);
    }
  }

  Future<void> _deleteEmployee() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Delete Employee'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this employee? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      debugPrint("Deleting employee id: ${widget.empId}");

      await ref
          .read(employeeloginViewModelProvider.notifier)
          .deleteEmployee(widget.empId);

      // ✅ AWAIT the refresh so the list updates BEFORE popping
      await ref.read(employeeloginViewModelProvider.notifier).getEmployeeList(ref.read(adminloginViewModelProvider).companyId?? '');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Employee deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Small delay so the snackbar is visible before navigating
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  String formatJoiningDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "N/A";

    final date = DateTime.parse(isoDate).toLocal();
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeloginViewModelProvider);

    final ordersState = ref.watch(EmployeeOrderViewModelProvider(widget.empId));

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Scaffold(body: Center(child: Text(state.error!)));
    }

    final List<EmployeeLogin>? list = state.employeeDetails?.value;
    if (list == null || list.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No Employee Data Found")),
      );
    }

    final EmployeeLogin employee = list.first;
    final bool isActive = employee.activeStatus == 0;
    final avgDistanceText = _calculateAvgDistance(
      ref.watch(visitViewModelProvider).visits?.value,
    );
    final avgShopTimeText = _calculateAvgShopTime(
      ref.watch(visitViewModelProvider).visits?.value,
    );
    final avgShopsPerDayText = _calculateAvgShopsPerDay(
      ref.watch(visitViewModelProvider).visits?.value,
    );
    final avgOrdersPerDayText = _calculateAvgOrdersPerDay(
      ref.watch(ordersViewModelProvider).orders?.value,
    );

    final ordersAsync = ordersState.orders; // AsyncValue<List<Order>>
    List<Order> employeeOrders = [];

    ordersAsync?.whenData((orders) {
      employeeOrders = orders
        ..sort((a, b) => b.orderDate.compareTo(a.orderDate)); // latest first
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Employee Details",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF57C00),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        titleSpacing: 0,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 👤 HEADER CARD WITH DELETE ICON
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A3D62), Color(0xFF0A3D62)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A3D62).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // EDIT AND DELETE ICONS - TOP RIGHT CORNER
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Row(
                          children: [
                            // EDIT ICON
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: _editEmployee,
                                tooltip: 'Edit Employee',
                              ),
                            ),
                            const SizedBox(width: 8),
                            // DELETE ICON
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: _deleteEmployee,
                                tooltip: 'Delete Employee',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // MAIN CONTENT
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white,
                            child: Text(
                              (employee.empName?.isNotEmpty ?? false)
                                  ? employee.empName![0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.empName ?? "N/A",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        employee.empAddress ?? "N/A",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green
                                        : Colors.redAccent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isActive ? "Active" : "Inactive",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 🧾 BASIC INFO
                _sectionTitle("Basic Information", Icons.info_outline),
                _infoCard([
                  _infoRow(
                    Icons.phone,
                    "Mobile No.",
                    employee.empMobile ?? "N/A",
                  ),
                  _infoRow(Icons.email, "Email", employee.empEmail ?? "N/A"),
                  _infoRow(Icons.home, "Address", employee.empAddress ?? "N/A"),
                  // _infoRow(Icons.calendar_today, "Joining Date", employee.joiningDate ?? "N/A"),
                  _infoRow(
                    Icons.calendar_today,
                    "Joining Date",
                    formatJoiningDate(employee.joiningDate),
                  ),
                
                ]),

                const SizedBox(height: 24),

                // 🗺️ EMPLOYEE VISITS MAP
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A3D62).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            color: Color(0xFF0A3D62),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'View Employee Visits Map',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A3D62),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Open Map'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 📊 PERFORMANCE SUMMARY
                _sectionTitle("Performance Summary", Icons.bar_chart_rounded),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      _AnimatedStatCard(
                        title: "Avg Time / Shop",
                        value: avgShopTimeText,
                        icon: Icons.timer_outlined,
                        color: Colors.orange,
                        delay: 0,
                      ),
                      _AnimatedStatCard(
                        title: "Avg Distance / Day",
                        value: avgDistanceText,
                        icon: Icons.route_outlined,
                        color: Colors.purple,
                        delay: 100,
                      ),
                      _AnimatedStatCard(
                        title: "Avg Shops / Day",
                        value: avgShopsPerDayText,
                        icon: Icons.store_outlined,
                        color: Colors.teal,
                        delay: 200,
                      ),
                      _AnimatedStatCard(
                        title: "Avg Orders / Day",
                        value: avgOrdersPerDayText,
                        icon: Icons.shopping_cart_outlined,
                        color: Colors.blue,
                        delay: 300,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 📦 RECENT ORDERS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF2196F3),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Recent Orders",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: selectedFilter,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2196F3),
                          ),
                          items: filters
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(f),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedFilter = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // recent orders list
                ordersAsync == null || employeeOrders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No orders found for this employee"),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: employeeOrders.length,
                        itemBuilder: (_, index) {
                          final order = employeeOrders[index];
                          return _AnimatedOrderCard(
                            order: order,
                            orderNumber:
                                employeeOrders.length - index, // latest = top
                            amount: order.totalPrice.toInt(),
                            filter: selectedFilter,
                            delay: index * 100,
                          );
                        },
                      ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _sectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF2196F3)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _infoCard(List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _calculateAvgDistance(List<EmployeeVisit>? visits) {
    if (visits == null || visits.isEmpty) return "0 km";

    final byDay = <String, List<EmployeeVisit>>{};
    for (final v in visits) {
      final ts = v.punchIn ?? v.punchOut;
      if (ts == null) continue;
      final ist = _toIst(ts);
      final key =
          '${ist.year.toString().padLeft(4, '0')}-${ist.month.toString().padLeft(2, '0')}-${ist.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(key, () => []).add(v);
    }

    if (byDay.isEmpty) return "0 km";

    double totalKm = 0.0;
    for (final dayVisits in byDay.values) {
      dayVisits.sort(_compareVisitsByPunchIn);
      for (var i = 1; i < dayVisits.length; i++) {
        final prev = dayVisits[i - 1];
        final curr = dayVisits[i];
        totalKm += _haversineKm(
          prev.latitude,
          prev.longitude,
          curr.latitude,
          curr.longitude,
        );
      }
    }

    final avg = totalKm / byDay.length;
    return _formatDistance(avg);
  }

  int _compareVisitsByPunchIn(EmployeeVisit a, EmployeeVisit b) {
    final aDate = a.punchIn ?? a.punchOut;
    final bDate = b.punchIn ?? b.punchOut;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  }

  DateTime _toIst(DateTime dt) {
    return dt.toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

  String _formatDistance(double km) {
    if (km < 1) {
      final meters = (km * 1000).round();
      return '${meters} m';
    }
    return '${km.toStringAsFixed(2)} km';
  }

  String _calculateAvgShopTime(List<EmployeeVisit>? visits) {
    if (visits == null || visits.isEmpty) return "0 min";

    final durations = <Duration>[];
    for (final v in visits) {
      if (v.punchIn != null && v.punchOut != null) {
        final start = _toIst(v.punchIn!);
        final end = _toIst(v.punchOut!);
        if (end.isAfter(start)) {
          durations.add(end.difference(start));
        }
      }
    }

    if (durations.isEmpty) return "0 min";

    final totalSeconds = durations.fold<int>(0, (sum, d) => sum + d.inSeconds);
    final avgSeconds = totalSeconds ~/ durations.length;
    final avgDuration = Duration(seconds: avgSeconds);
    return _formatDuration(avgDuration);
  }

  String _calculateAvgShopsPerDay(List<EmployeeVisit>? visits) {
    if (visits == null || visits.isEmpty) return "0";

    final byDay = <String, Set<int>>{};
    for (final v in visits) {
      final ts = v.punchIn ?? v.punchOut;
      if (ts == null) continue;
      final ist = _toIst(ts);
      final key =
          '${ist.year.toString().padLeft(4, '0')}-${ist.month.toString().padLeft(2, '0')}-${ist.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(key, () => <int>{}).add(v.shopId);
    }

    if (byDay.isEmpty) return "0";

    final totalShops = byDay.values.fold<int>(
      0,
      (sum, set) => sum + set.length,
    );
    final avg = totalShops / byDay.length;
    return avg.toStringAsFixed(1);
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes} min';
  }

  String _calculateAvgOrdersPerDay(List<Order>? orders) {
    if (orders == null || orders.isEmpty) return "0";

    final byDay = <String, int>{};
    for (final o in orders) {
      final ts = _parseOrderDate(o.orderDate);
      if (ts == null) continue;
      final ist = _toIst(ts);
      final key =
          '${ist.year.toString().padLeft(4, '0')}-${ist.month.toString().padLeft(2, '0')}-${ist.day.toString().padLeft(2, '0')}';
      byDay[key] = (byDay[key] ?? 0) + 1;
    }

    if (byDay.isEmpty) return "0";

    final totalOrders = byDay.values.fold<int>(0, (sum, count) => sum + count);
    final avg = totalOrders / byDay.length;
    return avg.toStringAsFixed(1);
  }

  DateTime? _parseOrderDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

// ============================================
// 🎯 Animated Stat Card
// ============================================
class _AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _AnimatedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const Spacer(),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// 🎯 Animated Order Card
// ============================================
class _AnimatedOrderCard extends StatefulWidget {
  final int orderNumber;
  final int amount;
  final String filter;
  final int delay;
  final Order order;

  const _AnimatedOrderCard({
    required this.order,
    required this.orderNumber,
    required this.amount,
    required this.filter,
    required this.delay,
  });

  @override
  State<_AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<_AnimatedOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsPage(
                      orderNumber: widget.orderNumber,
                      order: widget.order,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                     
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order#${widget.orderNumber}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.filter,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2196F3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "₹${widget.amount}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
