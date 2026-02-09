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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  /// ✨ MODERN GRADIENT COLORS FOR AVATARS
  final List<List<Color>> avatarGradients = [
    [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeloginViewModelProvider.notifier).getEmployeeList(
          ref.read(adminloginViewModelProvider).companyId ?? '');
    });
  }

  void _refreshEmployeeList() {
    ref
        .read(employeeloginViewModelProvider.notifier)
        .getEmployeeList(ref.read(adminloginViewModelProvider).companyId ?? '');
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
                  "region": e.regionName ?? "",
                  "status": e.activeStatus == 1 ? "Active" : "Inactive",
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
      backgroundColor: const Color(0xFFF8FAFC),

      /// ✨ MODERN FAB WITH GRADIENT
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEmployeeForm()),
            );
            if (result == true) _refreshEmployeeList();
          },
          icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
          label: const Text(
            'Add Employee',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),

      body: state.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFF667eea),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading employees...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
               Padding(
  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white, // ✅ solid white
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.withOpacity(0.2), // subtle border for clarity
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05), // subtle shadow only
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        hintText: "Search by name, mobile, email...",
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Colors.grey,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = "");
                },
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  ),
),


                    /// ✨ MODERN STATS CARDS WITH GRADIENT
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _modernStatsCard(
                              title: "Active",
                              count: activeCount,
                              icon: Icons.check_circle_rounded,
                              gradient: [
                                const Color(0xFF11998e),
                                const Color(0xFF38ef7d)
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _modernStatsCard(
                              title: "Inactive",
                              count: inactiveCount,
                              icon: Icons.pause_circle_rounded,
                              gradient: [
                                const Color(0xFFff6b6b),
                                const Color(0xFFffa372)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 👥 EMPLOYEE LIST HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.people_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'All Employees',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF667eea).withOpacity(0.15),
                                  const Color(0xFF764ba2).withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '${filteredEmployees.length} / ${employees.length}',
                              style: const TextStyle(
                                color: Color(0xFF667eea),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 👨‍💼 MODERN EMPLOYEE LIST
                    Expanded(
                      child: filteredEmployees.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.people_outline_rounded,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No employees found',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your search filters',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: filteredEmployees.length,
                              itemBuilder: (context, index) {
                                final emp = filteredEmployees[index];
                                return _modernEmployeeCard(
                                  context,
                                  emp,
                                  index,
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
Widget _modernStatsCard({
  required String title,
  required int count,
  required IconData icon,
  required List<Color> gradient,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // ⬇️ height reduced
    decoration: BoxDecoration(
      color: Colors.white, // ✅ white background
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: gradient.first.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(
        color: gradient.first.withOpacity(0.25),
        width: 1.2,
      ),
    ),
    child: Row(
      children: [
        /// Icon container with gradient
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),

        const SizedBox(width: 14),

        /// Text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 26, // ⬇️ smaller than before
                fontWeight: FontWeight.bold,
                color: gradient.first,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  /// ✨ MODERN EMPLOYEE CARD WITH ENHANCED AVATAR
  Widget _modernEmployeeCard(
    BuildContext context,
    Map<String, dynamic> employee,
    int index,
  ) {
    final isActive = employee["status"] == "Active";
    final name = employee["name"].toString().trim();

    /// Generate initials
    String initials = "NA";
    if (name.isNotEmpty) {
      final parts =
          name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        initials = parts.map((e) => e[0]).take(2).join().toUpperCase();
      }
    }

    final gradientColors = avatarGradients[index % avatarGradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // ✅ White background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployeeDetailsPage(empId: employee["id"]),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                /// ✨ GRADIENT AVATAR - SAME BACKGROUND AS NAME INITIALS
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors, // ✅ Same gradient for all
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                /// DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? "N/A" : name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              employee["region"].toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (employee["mobile"].toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              employee["mobile"].toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                /// ✨ MODERN STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              const Color(0xFF10B981).withOpacity(0.15),
                              const Color(0xFF10B981).withOpacity(0.08),
                            ]
                          : [
                              const Color(0xFFEF4444).withOpacity(0.15),
                              const Color(0xFFEF4444).withOpacity(0.08),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF10B981).withOpacity(0.4)
                          : const Color(0xFFEF4444).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isActive
                                  ? const Color(0xFF10B981).withOpacity(0.5)
                                  : const Color(0xFFEF4444).withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        employee["status"],
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
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