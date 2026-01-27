import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addEmployee.dart';
import 'package:order_booking_app/screens/admin_screen/admin_employeeDetails.dart';

class AdminEmployeesPage extends ConsumerStatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  ConsumerState<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends ConsumerState<AdminEmployeesPage> {
  @override
  void initState() {
    super.initState();
    // 🔥 API CALL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeloginViewModelProvider.notifier).getEmployeeList();
    });
  }

  void _refreshEmployeeList() {
    ref.read(employeeloginViewModelProvider.notifier).getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeloginViewModelProvider);

    /// 🔍 API DATA → UI MAP (DESIGN SAME)
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
    );

    final activeCount = employees?.where((e) => e["status"] == "Active").length;

    final inactiveCount = employees
        ?.where((e) => e["status"] == "Inactive")
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEmployeeForm()),
          );
          
          // Refresh list if employee was added
          if (result == true) {
            _refreshEmployeeList();
          }
        },
        backgroundColor: const Color(0xFFF57C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text(state.error!))
          : Column(
              children: [
                /// 🔵 OVERVIEW CARD (UNCHANGED)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A3D62), Color(0xFF0A3D62)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _overviewItem(
                              title: "Active",
                              count: activeCount ?? 0,
                              icon: Icons.check_circle_rounded,
                              textColor: const Color(
                                0xFF1A1A1A,
                              ).withOpacity(0.4),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 42,
                          ),
                          Expanded(
                            child: _overviewItem(
                              title: "Inactive",
                              count: inactiveCount ?? 0,
                              icon: Icons.cancel_rounded,
                              textColor: const Color.fromARGB(255, 37, 18, 7),
                            ),
                          ),
                          Container(
                            color: const Color(0xFF1A1A1A).withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🔹 EMPLOYEE LIST (UNCHANGED UI)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: employees?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmployeeDetailsPage(
                                empId: state.employeeList!.value![index].empId!,
                              ),
                            ),
                          );
                        },
                        child: _employeeCard(context, employees![index], index),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // 🔹 OVERVIEW ITEM
  Widget _overviewItem({
    required String title,
    required int count,
    required IconData icon,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 EMPLOYEE CARD (STATUS BOTTOM-RIGHT)
  Widget _employeeCard(
    BuildContext context,
    Map<String, dynamic> employee,
    int index,
  ) {
    final isActive = employee["status"] == "Active";

    final avatarColors = [
      const Color.fromARGB(255, 233, 184, 80),
    ];

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
      child: Stack(
        children: [
          // ✏️ EDIT ICON (TOP RIGHT)
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF0A3D62),
                size: 20,
              ),
              onPressed: () async {
                // Navigate to AddEmployeeForm in edit mode with prefilled data
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEmployeeForm(
                      // empId: employee["id"],
                      // initialName: employee["name"],
                      // initialMobile: employee["mobile"],
                      // initialEmail: employee["email"],
                      // initialAddress: employee["address"],
                      // initialRegion: employee["region"],
                    ),
                  ),
                );

                // Refresh list if employee was updated or deleted
                if (result == true) {
                  _refreshEmployeeList();
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        avatarColors[index % avatarColors.length],
                        avatarColors[index % avatarColors.length].withOpacity(
                          0.7,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      employee["name"]!.split(" ").map((e) => e[0]).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name + Region
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee["name"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee["region"]!,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF1A1A1A).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔵 STATUS (BOTTOM RIGHT)
          Positioned(
            bottom: 12,
            right: 16,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  employee["status"]!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green : Colors.redAccent,
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