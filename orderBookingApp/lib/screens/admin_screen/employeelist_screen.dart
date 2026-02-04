import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addEmployee.dart';
import 'package:order_booking_app/screens/admin_screen/admin_employeeDetails.dart';

class AdminEmployeesPage extends ConsumerStatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  ConsumerState<AdminEmployeesPage> createState() =>
      _AdminEmployeesPageState();
}

class _AdminEmployeesPageState
    extends ConsumerState<AdminEmployeesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  /// ✅ AVATAR COLORS
  final List<Color> avatarColors = [
    const Color(0xFF0A3D62),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  void _refreshEmployeeList() {
    ref.read(employeeloginViewModelProvider.notifier)
    .getEmployeeList(ref.read(adminloginViewModelProvider).companyId?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeloginViewModelProvider);

    /// API → UI MAP
    final employees = state.employeeList?.when(
          data: (list) => list
              .map(
                (e) => {
                  "id": e.empId,
                  "name": e.empName ?? "",
                  "mobile": e.empMobile ?? "",
                  "email": e.empEmail ?? "",
                  "address": e.empAddress ?? "",
                  "region": e.empAddress ?? "",
                  "status":
                      e.activeStatus == 1 ? "Active" : "Inactive",
                },
              )
              .toList(),
          loading: () => <Map<String, dynamic>>[],
          error: (_, __) => <Map<String, dynamic>>[],
        ) ??
        [];

    /// 🔍 SEARCH FILTER
    final filteredEmployees = employees.where((e) {
      final q = _searchQuery.toLowerCase();
      return e["name"].toLowerCase().contains(q) ||
          e["mobile"].toLowerCase().contains(q) ||
          e["email"].toLowerCase().contains(q) ||
          e["address"].toLowerCase().contains(q) ||
          e["region"].toLowerCase().contains(q) ||
          e["status"].toLowerCase().contains(q);
    }).toList();

    final activeCount =
        filteredEmployees.where((e) => e["status"] == "Active").length;
    final inactiveCount =
        filteredEmployees.where((e) => e["status"] == "Inactive").length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF57C00),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEmployeeForm()),
          );
          if (result == true) _refreshEmployeeList();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : Column(
                  children: [
                    /// 🔍 SEARCH BAR
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: "Search name, mobile",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    /// 🔵 ACTIVE / INACTIVE CARDS
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: _overviewCard(
                              title: "Active",
                              count: activeCount,
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _overviewCard(
                              title: "Inactive",
                              count: inactiveCount,
                              icon: Icons.cancel_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 👨‍💼 EMPLOYEE LIST
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = filteredEmployees[index];
                          return InkWell(
                            borderRadius:
                                BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EmployeeDetailsPage(
                                    empId: emp["id"], companyId: {},
                                  ),
                                ),
                              );
                            },
                            child:
                                _employeeCard(context, emp, index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  /// 🔹 OVERVIEW CARD
  Widget _overviewCard({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A3D62),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 EMPLOYEE CARD
  Widget _employeeCard(
    BuildContext context,
    Map<String, dynamic> employee,
    int index,
  ) {
    final isActive = employee["status"] == "Active";
    String initials = _getInitials(employee["name"]?.toString() ?? "");

    /// ✅ SAFE INITIALS (NO RANGE ERROR)
    initials = "NA";
    final name = employee["name"].toString().trim();

    if (name.isNotEmpty) {
      final parts = name
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();

      if (parts.isNotEmpty) {
        initials = parts
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// AVATAR
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    avatarColors[index % avatarColors.length],
                    avatarColors[index % avatarColors.length]
                        .withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            /// DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? "N/A" : name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee["region"].toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// STATUS
            Column(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color:
                      isActive ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(height: 4),
                Text(
                  employee["status"],
                  style: TextStyle(
                    color: isActive
                        ? Colors.green
                        : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final initials = parts.map((p) => p[0]).take(2).join();
    return initials.isEmpty ? '?' : initials;
  }
}

