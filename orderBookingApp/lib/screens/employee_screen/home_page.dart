import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/add_shop_screen.dart';
import 'package:order_booking_app/screens/employee_screen/product_report.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
 
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
@override
void initState() {
  super.initState();

  _animationController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );

  _fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutCubic,
  ));

  _animationController.forward();
 
}


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
 //Today Performance Fetch 
 //Efficiency calculation
 final efficiencyProvider = Provider<double>((ref) {
  final ordersState = ref.watch(ordersViewModelProvider);

  final ordersList = ordersState.orders?.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  ) ?? [];

  final totalShops = ordersList
      .map((order) => order.shopId)
      .toSet()
      .length;

  final visitedToday = ref.watch(ordersViewModelProvider).orders?.maybeWhen(
    data: (list) {
      final now = DateTime.now();
      final todayOrders = list.where((order) {
        try {
          final orderDate = DateTime.parse(order.orderDate).toLocal();
          return orderDate.year == now.year &&
                 orderDate.month == now.month &&
                 orderDate.day == now.day;
        } catch (_) {
          return false;
        }
      });
      return todayOrders
          .map((order) => order.shopId)
          .toSet()
          .length;
    },
    orElse: () => 0,
  ) ?? 0;

  if (totalShops == 0) return 0;

  return (visitedToday / totalShops) * 100;
});



//Sucess Rate Calculation
final successRateProvider = Provider<double>((ref) {
  final todayOrders = ref.watch(ordersViewModelProvider).orders?.maybeWhen(
    data: (list) {
      final now = DateTime.now();
      final todayOrders = list.where((order) {
        try {
          final orderDate = DateTime.parse(order.orderDate).toLocal();
          return orderDate.year == now.year &&
                 orderDate.month == now.month &&
                 orderDate.day == now.day;
        } catch (_) {
          return false;
        }
      }).toList();

      return todayOrders.length;
    },
    orElse: () => 0,
  ) ?? 0;
  final visitedShops = ref.watch(ordersViewModelProvider).orders?.maybeWhen(
    data: (list) {
      final now = DateTime.now();
      final todayOrders = list.where((order) {
        try {
          final orderDate = DateTime.parse(order.orderDate).toLocal();
          return orderDate.year == now.year &&
                 orderDate.month == now.month &&
                 orderDate.day == now.day;
        } catch (_) {
          return false;
        }
      });
      return todayOrders
          .where((order) => order.status?.toLowerCase() == 'delivered')
          .map((order) => order.shopId)
          .toSet()
          .length;
    },
    orElse: () => 0,
  ) ?? 0;

  if (visitedShops == 0) return 0;

  return (todayOrders / visitedShops) * 100;
});



//Avg time Calculation
final avgOrderTimeProvider = Provider<String>((ref) {
  final ordersState = ref.watch(ordersViewModelProvider);

  final ordersList = ordersState.orders?.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  ) ?? [];

  if (ordersList.length < 2) return "0m";

  final sortedOrders = [...ordersList];

  sortedOrders.sort((a, b) =>
      DateTime.parse(a.orderDate)
          .compareTo(DateTime.parse(b.orderDate)));

  int totalMinutes = 0;

  for (int i = 1; i < sortedOrders.length; i++) {
    final prev = DateTime.parse(sortedOrders[i - 1].orderDate);
    final curr = DateTime.parse(sortedOrders[i].orderDate);

    totalMinutes += curr.difference(prev).inMinutes;
  }

  final avgMinutes = totalMinutes ~/ (sortedOrders.length - 1);

  return "${avgMinutes}m";
});




///----------------------------------------------------//
//Today VisitedShop Count

final todayVisitsCountProvider = Provider<int>((ref) {
  final visitState = ref.watch(visitViewModelProvider);

  final visits = visitState.visits?.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  ) ?? [];

  final now = DateTime.now();

  final todayVisits = visits.where((visit) {
    if (visit.punchIn == null) return false;
    final local = visit.punchIn!.toLocal();
    return local.year == now.year &&
           local.month == now.month &&
           local.day == now.day;
  }).length;

  return todayVisits;
});

//TodayTotal order count 
final todayOrdersCountProvider = Provider<int>((ref) {
  final ordersState = ref.watch(ordersViewModelProvider);
  final ordersList = ordersState.orders?.maybeWhen(
        data: (list) => list,
        orElse: () => [],
      ) ?? [];
  final now = DateTime.now();

  final todayOrders = ordersList.where((order) {
    final orderDateStr = order.orderDate;
    if (orderDateStr == null || orderDateStr.isEmpty) return false;

    try {
      // Parse as UTC
      final orderDateUtc = DateTime.parse(orderDateStr);
      // Convert to local time
      final orderDateLocal = orderDateUtc.toLocal();

      // Compare year, month, day
      return orderDateLocal.year == now.year &&
             orderDateLocal.month == now.month &&
             orderDateLocal.day == now.day;
    } catch (e) {
      debugPrint('Error parsing order date: ${order.order_id}, $e');
      return false;
    }
  }).toList();

  debugPrint('Today orders count: ${todayOrders.length}');
  return todayOrders.length;
});

//Today Shop Visited Count
final todayRevenueProvider = Provider<double>((ref) {
  final ordersState = ref.watch(ordersViewModelProvider);
  final ordersList = ordersState.orders?.maybeWhen(
        data: (list) => list,
        orElse: () => [],
      ) ?? [];

  final today = DateTime.now();

  final todayOrders = ordersList.where((order) {
    try {
      final orderDate = DateTime.parse(order.orderDate).toLocal(); // camelCase
      return orderDate.year == today.year &&
             orderDate.month == today.month &&
             orderDate.day == today.day;
    } catch (_) {
      return false;
    }
  }).toList();

  final totalRevenue = todayOrders.fold<double>(0.0, (sum, order) {
    final price = order.totalPrice; // camelCase
    return sum + price;
  });

  debugPrint('Total revenue today: $totalRevenue');
  return totalRevenue;
});

//Monthly Product Revenue Count
final monthlyRevenueProvider = Provider<double>((ref) {
  final ordersState = ref.watch(ordersViewModelProvider);

  final ordersList = ordersState.orders?.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  ) ?? [];

  final now = DateTime.now();

  // filter current month orders
  final monthlyOrders = ordersList.where((order) {
    try {
      final orderDate = DateTime.parse(order.orderDate).toLocal();

      return orderDate.year == now.year &&
             orderDate.month == now.month;
    } catch (_) {
      return false;
    }
  });

  // sum totalPrice
  final totalRevenue = monthlyOrders.fold<double>(
    0.0,
    (sum, order) => sum + order.totalPrice,
  );

  return totalRevenue;
});
Future<void> _onRefresh() async {
  try {
    final userId = ref.read(adminloginViewModelProvider).userId ?? 0;
    await ref.read(visitViewModelProvider.notifier).fetchEmployeeVisits(userId);
    // Provider rebuild automatically → UI update
  } catch (e) {
    debugPrint("Refresh error: $e");
  }
}

@override
Widget build(BuildContext context) {
   
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    body: RefreshIndicator(
      color: const Color(0xFF6C63FF),
      backgroundColor: Colors.white,
      displacement: 70,
      onRefresh: _onRefresh,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPerformanceSection(),
                    const SizedBox(height: 24),
                    _buildStatsOverview(),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                //    _buildRecentActivity(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStatsOverview() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 380;

      final todayOrders = ref.watch(todayOrdersCountProvider);
      final todayRevenue = ref.watch(todayRevenueProvider);
      final todayVisitedShops = ref.watch(todayVisitsCountProvider);
      final monthlyRevenue = ref.watch(monthlyRevenueProvider);

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Orders',
                  value: todayOrders.toString(),
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFF6C63FF),
                //  trend: '+12%',
                  isSmall: isSmallScreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Revenue',
                  value: '₹${todayRevenue.toStringAsFixed(2)}',
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF00C853),
                 // trend: '+8%',
                  isSmall: isSmallScreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Shops',
                 value: todayVisitedShops.toString(),
                  icon: Icons.store_outlined,
                  color: const Color(0xFFFF6B6B),
                //  trend: '+5',
                  isSmall: isSmallScreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Products Revenue',
                value: '₹${monthlyRevenue.toStringAsFixed(2)}',
                  icon: Icons.production_quantity_limits_sharp,
                  color: const Color(0xFFFFA726),
                 // trend: '-2',
                  isSmall: isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FDC).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFF7C6FDC),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Expanded(
            //   child: _QuickActionButton(
            //     icon: Icons.shopping_cart_rounded,
            //     label: 'New Order',
            //     backgroundColor: const Color(0xFFE8E5FF),
            //     iconColor: const Color(0xFF7C6FDC),
            //     onTap: () {
            //       setState(() {
            //         _selectedTabIndex = 1;
            //       });
            //     },
            //   ),
            // ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_business_rounded,
                label: 'Add Shop',
                backgroundColor: const Color(0xFFD4F4E7),
                iconColor: const Color(0xFF00C853),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddShopScreen(),
                    ),
                  );
                },
              ),
            ),
             const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
                backgroundColor: const Color(0xFFD4F4E7),
                iconColor: const Color.fromARGB(255, 180, 29, 12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                     builder: (context) => ReportPage(companyId: ref.read(adminloginViewModelProvider).companyId ?? ''),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  

  Widget _buildPerformanceSection() {
    final efficiency = ref.watch(efficiencyProvider);
    final successRate = ref.watch(successRateProvider);
    final avgTime = ref.watch(avgOrderTimeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(255, 247, 107, 97), Color.fromARGB(255, 248, 45, 45)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 208, 71, 47).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Great work! Keep it up',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    _PerformanceMetric(
      label: 'Efficiency',
      value: '${efficiency.toStringAsFixed(0)}%',
      icon: Icons.speed,
    ),
    _PerformanceMetric(
      label: 'Success Rate',
      value: '${successRate.toStringAsFixed(0)}%',
      icon: Icons.check_circle,
    ),
    _PerformanceMetric(
      label: 'Avg. Time',
      value: avgTime,
      icon: Icons.access_time,
    ),
  ],
)

        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActivityItem(
          icon: Icons.check_circle_rounded,
          title: 'Order Delivered',
          subtitle: 'Green Juice Corner',
          time: '2h ago',
          color: const Color(0xFF00C853),
          badge: 'ORD#001',
        ),
        const SizedBox(height: 10),
        _ActivityItem(
          icon: Icons.shopping_cart_rounded,
          title: 'New Order Created',
          subtitle: 'Fresh Fruits Hub',
          time: '3h ago',
          color: const Color(0xFF6C63FF),
          badge: 'ORD#002',
        ),
        const SizedBox(height: 10),
        _ActivityItem(
          icon: Icons.add_business_rounded,
          title: 'Shop Added',
          subtitle: 'Health Juice Bar',
          time: '5h ago',
          color: const Color(0xFFFF6B6B),
        ),
      ],
    );
  }
}
// Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: iconColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Modern Stat Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isSmall;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
     this.trend,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isSmall ? 18 : 20),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              //   decoration: BoxDecoration(
              //     color: color.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(6),
              //   ),
              //   child: Text(
              //     trend ?? '',
              //     style: TextStyle(
              //       color: color,
              //       fontSize: 10,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: isSmall ? 10 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 22 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


// Performance Metric
class _PerformanceMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Activity Item
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final String? badge;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}