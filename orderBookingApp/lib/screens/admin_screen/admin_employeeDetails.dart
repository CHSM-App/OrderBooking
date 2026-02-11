import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addEmployee.dart';
import 'package:order_booking_app/screens/admin_screen/attendence.dart';
import 'package:order_booking_app/screens/admin_screen/employee_visits_map.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'dart:math';
import 'package:order_booking_app/screens/employee_screen/order_details.dart';

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
          .read(visitViewModelProvider.notifier)
          .fetchEmployeeVisits(widget.empId);
      await ref
          .read(employeeloginViewModelProvider.notifier)
          .getEmployeeVisit(widget.empId);
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

  Future<void> _deleteEmployee() async {
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
            const Text(
              'Delete Employee?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MinimalTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
            child: const Text('Delete'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  bool _passesOrderFilter(Order order) {
    final raw = _parseOrderDate(order.orderDate);
    if (raw == null) return false;

    final date = _toIstDateOnly(raw);
    final today = _toIstDateOnly(DateTime.now());

    final orderDate = parseSqlServerDate(order.orderDate);
    final orderKey = dateKey(orderDate);

    switch (orderFilter) {
      case "All":
        return true;
      case "Today":
        return date == today;
      case "Month":
        return date.year == today.year && date.month == today.month;
      case "Year":
        return date.year == today.year;
      case "Custom":
        if (orderCustomRange == null) return true;
        final startKey = dateKey(orderCustomRange!.start);
        final endKey = dateKey(orderCustomRange!.end);
        return orderKey >= startKey && orderKey <= endKey;
      default:
        return true;
    }
  }

  bool _passesVisitPayloadFilter(VisitPayload visit) {
    final tsString = visit.punchIn ;
    // if (tsString == null || tsString.isEmpty) return false;

    final date = _toIstDateOnly(DateTime.parse(tsString));
    final today = _toIstDateOnly(DateTime.now());

    final visitDate = parseSqlServerDate(tsString);
    final visitKey = dateKey(visitDate);

    switch (visitFilter) {
      case "All":
        return true;
      case "Today":
        return date == today;
      case "Month":
        return date.year == today.year && date.month == today.month;
      case "Year":
        return date.year == today.year;
      case "Custom":
        if (visitCustomRange == null) return true;
        final startKey = dateKey(visitCustomRange!.start);
        final endKey = dateKey(visitCustomRange!.end);
        return visitKey >= startKey && visitKey <= endKey;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeloginViewModelProvider);
    final ordersState = ref.watch(EmployeeOrderViewModelProvider(widget.empId));
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
    final bool isActive = employee.activeStatus == 1;
    final avgDistanceText = _calculateAvgDistance(
      ref.watch(visitViewModelProvider).visits?.value,
    );
    final avgShopTimeText = _calculateAvgShopTime(
      ref.watch(visitViewModelProvider).visits?.value,
    );
    final avgShopsPerDayText = _calculateAvgShopsPerDay(
      ref.watch(visitViewModelProvider).visits?.value,
    );
    final employeeOrdersForAvg = ordersState.orders?.maybeWhen(
      data: (orders) => orders,
      orElse: () => null,
    );
    final avgOrdersPerDayText = _calculateAvgOrdersPerDay(employeeOrdersForAvg);
    final ordersAsync = ordersState.orders;

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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _deleteEmployee,
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
                  const SizedBox(width: 10),
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
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Performance Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _statCard(
                    title: "Avg Time/Shop",
                    value: avgShopTimeText,
                    icon: Icons.timer_outlined,
                  ),
                  _statCard(
                    title: "Avg Distance",
                    value: avgDistanceText,
                    icon: Icons.route_outlined,
                  ),
                  _statCard(
                    title: "Shops/Day",
                    value: avgShopsPerDayText,
                    icon: Icons.store_outlined,
                  ),
                  _statCard(
                    title: "Orders/Day",
                    value: avgOrdersPerDayText,
                    icon: Icons.shopping_cart_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Recent Orders Section
            _sectionHeader(
              title: 'Recent Orders',
              icon: Icons.receipt_long_outlined,
              filter: orderFilter,
              onFilterChanged: (value) async {
                if (value == "Custom") {
                  final now = DateTime.now();
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 1),
                    initialDateRange:
                        orderCustomRange ?? DateTimeRange(start: now, end: now),
                  );
                  if (range == null) return;
                  setState(() {
                    orderFilter = value;
                    orderCustomRange = range;
                  });
                } else {
                  setState(() {
                    orderFilter = value;
                    orderCustomRange = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            _buildOrdersList(ordersAsync),

            const SizedBox(height: 12),

            // Visited Shops Section
            _sectionHeader(
              title: 'Visited Shops',
              icon: Icons.store_outlined,
              filter: visitFilter,
              onFilterChanged: (value) async {
                if (value == "Custom") {
                  final now = DateTime.now();
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 1),
                    initialDateRange:
                        visitCustomRange ?? DateTimeRange(start: now, end: now),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    // Assign colors based on title
    Color color;
    switch (title) {
      case "Avg Time/Shop":
        color = Colors.orange;
        break;
      case "Avg Distance":
        color = Colors.purple;
        break;
      case "Shops/Day":
        color = Colors.teal;
        break;
      case "Orders/Day":
        color = Colors.blue;
        break;
      default:
        color = MinimalTheme.primaryOrange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: MinimalTheme.textGray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  Widget _buildOrdersList(AsyncValue<List<Order>>? ordersAsync) {
    if (ordersAsync == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No orders found", style: TextStyle(color: MinimalTheme.textGray)),
      );
    }

    return ordersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          color: MinimalTheme.primaryOrange,
          strokeWidth: 2.5,
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(e.toString(), style: const TextStyle(color: MinimalTheme.textGray)),
      ),
      data: (orders) {
        final filteredOrders = orders.where(_passesOrderFilter).toList()
          ..sort((a, b) => _parseOrderDate(b.orderDate)!
              .compareTo(_parseOrderDate(a.orderDate)!));

        if (filteredOrders.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No orders for this filter", style: TextStyle(color: MinimalTheme.textGray)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filteredOrders.length,
          itemBuilder: (_, index) {
            final order = filteredOrders[index];
            return _orderCard(order, filteredOrders.length - index);
          },
        );
      },
    );
  }

  Widget _orderCard(Order order, int orderNumber) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: MinimalTheme.primaryOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #$orderNumber",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹${order.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: MinimalTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: MinimalTheme.iconGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitsList() {
    final visitsAsync = ref.watch(employeeloginViewModelProvider).employeeVisits;

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
        child: Text(e.toString(), style: const TextStyle(color: MinimalTheme.textGray)),
      ),
      data: (visits) {
        final filteredVisits = visits.where(_passesVisitPayloadFilter).toList()
          ..sort((a, b) {
            final aDateStr = a.punchIn;
            final bDateStr = b.punchIn ;

            return DateTime.parse(bDateStr).compareTo(DateTime.parse(aDateStr));
          });

        if (filteredVisits.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No visits for this filter", style: TextStyle(color: MinimalTheme.textGray)),
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

  Widget _visitCard(VisitPayload visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            visit.shopName ?? "Unknown Shop",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MinimalTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _timeChip("In", visit.punchIn, MinimalTheme.successGreen),
              const SizedBox(width: 8),
              _timeChip("Out", visit.punchOut, MinimalTheme.errorRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String label, String? time, Color color) {
    String formattedTime = "--";
    if (time != null && time.isNotEmpty) {
      try {
        final dt = DateTime.parse(time);
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? "PM" : "AM";
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

  // Helper methods
  DateTime parseSqlServerDate(String raw) {
    final dt = DateTime.parse(raw);
    return DateTime(dt.year, dt.month, dt.day);
  }

  int dateKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  DateTime _toIstDateOnly(DateTime dt) {
    final ist = dt.toUtc().add(const Duration(hours: 5, minutes: 30));
    return DateTime(ist.year, ist.month, ist.day);
  }

  DateTime _toIst(DateTime dt) {
    return dt.toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  DateTime? _parseOrderDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

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
      dayVisits.sort((a, b) {
        final aDate = a.punchIn ?? a.punchOut;
        final bDate = b.punchIn ?? b.punchOut;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
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

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
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
    final hours = avgDuration.inHours;
    final minutes = avgDuration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes} min';
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
    final totalShops = byDay.values.fold<int>(0, (sum, set) => sum + set.length);
    final avg = totalShops / byDay.length;
    return avg.round().toString();
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
    return avg.round().toString();
  }
}
