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

  /// ✅ AVATAR COLORS (FIXED)
  final List<Color> avatarColors = [
    const Color(0xFF0A3D62),
    const Color(0xFF1E3799),
    const Color(0xFF38ADA9),
    const Color(0xFFF79F1F),
    const Color(0xFFB71540),
    const Color(0xFF6A89CC),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeloginViewModelProvider.notifier).getEmployeeList();
    });
  }

  void _refreshEmployeeList() {
    ref.read(employeeloginViewModelProvider.notifier).getEmployeeList();
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
              "name": e.empName ?? "N/A",
              "mobile": e.empMobile ?? "N/A",
              "email": e.empEmail ?? "N/A",
              "address": e.empAddress ?? "N/A",
              "region": e.empAddress ?? "N/A",
              "status": e.activeStatus == 0 ? "Active" : "Inactive",
            },
          )
          .toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    ) ?? [];

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
                          hintText:
                              "Search name, mobile, region or status",
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
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
                                    empId: emp["id"],
                                  ),
                                ),
                              );
                            },
                            child: _employeeCard(
                                context, emp, index), // ✅ FIXED
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
    int index, // ✅ FIXED
  ) {
    final isActive = employee["status"] == "Active";

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
                  employee["name"]
                      .split(" ")
                      .map((e) => e[0])
                      .join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                    employee["name"],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee["region"],
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
}
