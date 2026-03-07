import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/login_viewmodel.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addEmployee.dart';
import 'package:order_booking_app/screens/admin_screen/admin_employeeDetails.dart';
import 'package:order_booking_app/screens/admin_screen/attendance_report.dart';
import 'package:order_booking_app/screens/admin_screen/widgets/admin_retry_widgets.dart';
import 'package:order_booking_app/widgets/app_search_bar.dart';

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

class AdminEmployeesPage extends ConsumerStatefulWidget {
  const AdminEmployeesPage({super.key, this.activeStatus = 0});

  final int activeStatus;

  @override
  ConsumerState<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends ConsumerState<AdminEmployeesPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  ProviderSubscription<AdminloginState>? _adminListener;
  bool _initialFetchDone = false;

  late TabController _tabController;

  // roleId: 2 = SO, 3 = ASM
  static const int _soRoleId = 2;
  static const int _asmRoleId = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _adminListener = ref.listenManual<AdminloginState>(
      adminloginViewModelProvider,
      (previous, next) {
        final companyId = next.companyId;
        if (!_initialFetchDone && companyId != null && companyId.isNotEmpty) {
          _initialFetchDone = true;
          ref
              .read(employeeloginViewModelProvider.notifier)
              .getEmployeeList(companyId);
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final companyId = ref.read(adminloginViewModelProvider).companyId;
      if (!_initialFetchDone && companyId != null && companyId.isNotEmpty) {
        _initialFetchDone = true;
        ref
            .read(employeeloginViewModelProvider.notifier)
            .getEmployeeList(companyId);
      }
    });
  }

  void _refreshEmployeeList() {
    ref
        .read(employeeloginViewModelProvider.notifier)
        .getEmployeeList(
          ref.read(adminloginViewModelProvider).companyId ?? '',
          useCacheFirst: false,
        );
  }

  Future<void> _onRefresh() async {
    final companyId = ref.read(adminloginViewModelProvider).companyId ?? '';
    if (companyId.isEmpty) return;
    await ref
        .read(employeeloginViewModelProvider.notifier)
        .getEmployeeList(companyId, useCacheFirst: false);
  }

  bool _isNetworkError(String? message) {
    if (message == null) return false;
    final msg = message.toLowerCase();
    return [
      'network',
      'internet',
      'connection',
      'socket',
      'failed host',
      'no address',
      'timeout',
      'unreachable',
    ].any(msg.contains);
  }

  Widget _buildNoInternet() => AdminNoInternetRetry(onRetry: _onRefresh);
  Widget _buildError() => AdminSomethingWentWrongRetry(onRetry: _onRefresh);

  @override
  void dispose() {
    _adminListener?.close();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Builds the employee list for a given roleId (2=SO, 3=ASM)
  List<Map<String, dynamic>> _getEmployeesByRole(
    List<dynamic> list,
    int roleId,
  ) {
    return list
        .where((e) {
          final matchesRole = e.roleId == roleId;
          if (widget.activeStatus == 0 || widget.activeStatus == 1) {
            return matchesRole && e.activeStatus == widget.activeStatus;
          }
          return matchesRole;
        })
        .map(
          (e) => {
            "id": e.empId,
            "name": e.empName ?? "",
            "mobile": e.empMobile,
            "email": e.empEmail ?? "",
            "address": e.empAddress ?? "",
            "region": e.regionName ?? "",
            "status": e.checkinStatus == 1 ? "Active" : "Inactive",
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> list) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return list;
    return list.where((e) {
      return e["name"].toLowerCase().contains(q) ||
          e["mobile"].toLowerCase().contains(q) ||
          e["email"].toLowerCase().contains(q) ||
          e["address"].toLowerCase().contains(q) ||
          e["region"].toLowerCase().contains(q) ||
          e["status"].toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeloginViewModelProvider);
    final listAsync = state.employeeList;
    final companyId = ref.read(adminloginViewModelProvider).companyId ?? '';

    return Scaffold(
      backgroundColor: MinimalTheme.backgroundGray,
      floatingActionButton: widget.activeStatus == 1
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                backgroundColor: MinimalTheme.primaryOrange,
                elevation: 2,
                onPressed: () async {
                  // Pass the roleId that matches the currently selected tab:
                  // tab 0 → SO (roleId 2), tab 1 → ASM (roleId 3)
                  final int roleId = _tabController.index == 0 ? 2 : 3;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEmployeeForm(roleId: roleId),
                    ),
                  );
                  if (result == true) _refreshEmployeeList();
                },
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: MinimalTheme.primaryOrange,
        child: listAsync.isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: CircularProgressIndicator(
                      color: MinimalTheme.primaryOrange,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              )
            : listAsync.hasError
            ? _isNetworkError(listAsync.error.toString())
                  ? _buildNoInternet()
                  : _buildError()
            : listAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (allEmployees) {
                  final soList = _applySearch(
                    _getEmployeesByRole(allEmployees, _soRoleId),
                  );
                  final asmList = _applySearch(
                    _getEmployeesByRole(allEmployees, _asmRoleId),
                  );

                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // ── Header ──────────────────────────
                            if (widget.activeStatus != 0)
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  40,
                                  16,
                                  12,
                                ),
                                decoration: BoxDecoration(
                                  color: MinimalTheme.cardWhite,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (widget.activeStatus != 0)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.arrow_back,
                                              color: MinimalTheme.textDark,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            splashRadius: 20,
                                          ),
                                        if (widget.activeStatus != 0)
                                          const SizedBox(width: 8),
                                        Text(
                                          widget.activeStatus == 0
                                              ? 'Employees'
                                              : 'Deleted Employees',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: MinimalTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget.activeStatus != 1)
                                      Row(
                                        children: [
                                          _compactStat(
                                            label: 'Active',
                                            count: (soList + asmList)
                                                .where(
                                                  (e) =>
                                                      e["status"] == "Active",
                                                )
                                                .length,
                                            color: MinimalTheme.successGreen,
                                          ),
                                          const SizedBox(width: 12),
                                          _compactStat(
                                            label: 'Inactive',
                                            count: (soList + asmList)
                                                .where(
                                                  (e) =>
                                                      e["status"] == "Inactive",
                                                )
                                                .length,
                                            color: MinimalTheme.errorRed,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                            // ── Search Bar + Attendance Button ───
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AppSearchBar(
                                      controller: _searchController,
                                      hintText: 'Search employee...',
                                      onChanged: (v) =>
                                          setState(() => _searchQuery = v),
                                    ),
                                  ),
                                  if (widget.activeStatus == 0) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AttendanceReportPage(
                                            companyId: companyId,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        height: 46,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: MinimalTheme.cardWhite,
                                          borderRadius: BorderRadius.circular(
                                            17,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF6366F1,
                                            ).withOpacity(0.25),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.bar_chart_rounded,
                                              color: Color(0xFF6366F1),
                                              size: 18,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Report',
                                              style: TextStyle(
                                                color: Color(0xFF6366F1),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ── Tab Bar ──────────────────────────
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              decoration: BoxDecoration(
                                color: MinimalTheme.cardWhite,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TabBar(
                                controller: _tabController,
                                labelColor: MinimalTheme.primaryOrange,
                                unselectedLabelColor: MinimalTheme.textGray,
                                indicatorColor: MinimalTheme.primaryOrange,
                                indicatorWeight: 2.5,
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                tabs: [
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('SO'),
                                        const SizedBox(width: 6),
                                        _tabCountBadge(
                                          active: soList
                                              .where(
                                                (e) => e["status"] == "Active",
                                              )
                                              .length,
                                          total: soList.length,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('ASM'),
                                        const SizedBox(width: 6),
                                        _tabCountBadge(
                                          active: asmList
                                              .where(
                                                (e) => e["status"] == "Active",
                                              )
                                              .length,
                                          total: asmList.length,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        // SO Tab
                        _buildEmployeeListView(soList),
                        // ASM Tab
                        _buildEmployeeListView(asmList),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// Count badge shown next to tab label — displays "active/total"
  Widget _tabCountBadge({required int active, required int total}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: MinimalTheme.primaryOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: active.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: MinimalTheme.primaryOrange,
              ),
            ),
            TextSpan(
              text: '/$total',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: MinimalTheme.primaryOrange.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeListView(List<Map<String, dynamic>> employees) {
    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: MinimalTheme.iconGray.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No employees found',
              style: TextStyle(
                fontSize: 16,
                color: MinimalTheme.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your search',
              style: TextStyle(color: MinimalTheme.textGray, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        return _employeeCard(context, employees[index]);
      },
    );
  }

  Widget _compactStat({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeCard(BuildContext context, Map<String, dynamic> employee) {
    final isActive = employee["status"] == "Active";
    final name = employee["name"].toString().trim();

    String initials = "NA";
    if (name.isNotEmpty) {
      final parts = name
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        initials = parts.map((e) => e[0]).take(2).join().toUpperCase();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: MinimalTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                builder: (_) => EmployeeDetailsPage(empId: employee["id"]),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: MinimalTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? "N/A" : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (employee["mobile"].toString().isNotEmpty) ...[
                            const Icon(
                              Icons.phone_outlined,
                              size: 13,
                              color: MinimalTheme.iconGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              employee["mobile"].toString(),
                              style: const TextStyle(
                                color: MinimalTheme.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (employee["region"].toString().isNotEmpty &&
                              employee["mobile"].toString().isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Text(
                              "•",
                              style: TextStyle(
                                color: MinimalTheme.iconGray,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (employee["region"].toString().isNotEmpty)
                            Flexible(
                              child: Text(
                                employee["region"].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: MinimalTheme.textGray,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? MinimalTheme.successGreen.withOpacity(0.1)
                        : MinimalTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? MinimalTheme.successGreen
                          : MinimalTheme.errorRed,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: MinimalTheme.iconGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
