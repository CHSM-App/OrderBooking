import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'admin_addEmployee.dart';
import 'admin_addProduct.dart';
import 'admin_regionDetails.dart';
import 'admin_shopDetails.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  final Function(int, {int ordersTab}) onNavigate;

  const AdminHomePage({super.key, required this.onNavigate});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  // Example dynamic values (replace these with your providers)
  int todaysOrders = 0;
  int totalProducts = 0;
  String totalRevenue = "₹0";

  @override
  void initState() {
    super.initState();
    // Future.microtask(() {
    //   ref
    //       .read(employeeloginViewModelProvider.notifier).getEmployeeList(ref.read(adminloginViewModelProvider).companyId ?? '',);
    // });

    // Future.microtask(() {
    //   final adminId = ref.read(adminloginViewModelProvider).userId;

    // Future.microtask(() {
    //     ref.read(ordersViewModelProvider.notifier).getOrderList(ref.read(adminloginViewModelProvider).companyId ?? '',);
    //   });

    //   if (adminId != 0) {
    //     ref.read(productViewModelProvider.notifier).fetchProductList(adminId);
    //   }
    // });


     
  }

 

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String formatINR(num value) {
    final isNegative = value < 0;
    value = value.abs();

    String str = value.toStringAsFixed(0);

    if (str.length <= 3) {
      return '${isNegative ? '-' : ''}₹$str';
    }

    String lastThree = str.substring(str.length - 3);
    String remaining = str.substring(0, str.length - 3);

    final reg = RegExp(r'\B(?=(\d{2})+(?!\d))');
    remaining = remaining.replaceAll(reg, ',');

    return '${isNegative ? '-' : ''}₹$remaining,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
      ref.listen(adminloginViewModelProvider, (prev, next) {
    final companyId = next.companyId;
    final adminId = next.userId;

    if (companyId != null && companyId.isNotEmpty) {
      ref
          .read(employeeloginViewModelProvider.notifier)
          .getEmployeeList(companyId);

      ref
          .read(ordersViewModelProvider.notifier)
          .getOrderList(companyId);
    }

    if (adminId != 0) {
      ref
          .read(productViewModelProvider.notifier)
          .fetchProductList(adminId);
    }
  });


    final employeeState = ref.watch(employeeloginViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final orderState = ref.watch(ordersViewModelProvider);

    final activeEmployeesCount = employeeState.employeeList?.when(
      loading: () => 0,
      error: (_, __) => 0,
      data: (employees) {
        return employees.where((e) => e.activeStatus == 1).length;  
      },
    );

    final totalProductCount = productState.productList?.when(
      loading: () => 0,
      error: (_, __) => 0,
      data: (products) => products.length,
    );

    final int todaysOrdersCount =
        orderState.orders?.when(
          loading: () => 0,
          error: (_, __) => 0,
          data: (orders) {
            final today = DateTime.now();

            return orders.where((order) {
              final orderDate = DateTime.parse(order.orderDate);

              return isSameDay(orderDate, today);
            }).length;
          },
        ) ??
        0;

    final double todaysRevenue =
        orderState.orders?.when(
          loading: () => 0.0,
          error: (_, __) => 0.0,
          data: (orders) {
            final today = DateTime.now();

            return orders
                .where((order) {
                  final orderDate = DateTime.parse(order.orderDate);
                  return isSameDay(orderDate, today);
                })
                .fold<double>(0.0, (sum, order) {
                  final amount = order.totalPrice;
                  return sum +
                      (amount is String
                          ? double.tryParse(amount as String) ?? 0.0
                          : amount.toDouble());
                });
          },
        ) ??
        0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
            Colors.white,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your business at a glance",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                // 🔸 Pending Orders
                _modernDashboardCard(
                  title: "Today's Orders",
                  value: todaysOrdersCount.toString(),
                  icon: Icons.pending_actions_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF57C00), Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  trend: "",
                  onTap: () => widget.onNavigate(2, ordersTab: 0),
                ),

                //Active employees count
                _modernDashboardCard(
                  title: "Active Employees",
                  value: activeEmployeesCount.toString(),
                  icon: Icons.people_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  trend: "",
                  onTap: () => widget.onNavigate(3),
                ),

                // 🔸 Products
                _modernDashboardCard(
                  title: "Products",
                  value: totalProductCount.toString(),
                  icon: Icons.inventory_2_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  trend: "",
                  onTap: () => widget.onNavigate(1),
                ),
                // 🔸 Total Revenue
                _modernDashboardCard(
                  title: "Today's Revenue",
                  value: formatINR(todaysRevenue),
                  icon: Icons.attach_money_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  trend: "",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _quickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _modernDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required String trend,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: -15,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: Colors.white, size: 16),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                title: "Add Product",
                icon: Icons.add_box_outlined,
                color: const Color(0xFFF57C00),
                onTap: () {
                  // Read the provider value
                  final adminId = ref.read(adminloginViewModelProvider).userId;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductPage(adminId: adminId),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                title: "New Employee",
                icon: Icons.person_add_outlined,
                color: const Color(0xFF00897B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEmployeeForm()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                title: "View Regions",
                icon: Icons.location_on_outlined,
                color: const Color(0xFFE64A19),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegionListPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                title: "View Shops",
                icon: Icons.store_outlined,
                color: const Color(0xFF5E35B1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopListPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
