import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/token_provider.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/add_shop_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    Future.microtask(() {
      ref
          .read(regionofflineViewModelProvider.notifier)
          .fetchRegionList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
      ref.read(visitViewModelProvider.notifier).purgeOldSyncedVisits();
      ref.read(visitViewModelProvider.notifier).getTodayVisitCount(ref.read(adminloginViewModelProvider).userId);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

 
  Future<void> _onRefresh() async {
    try {
      final userId = ref.read(adminloginViewModelProvider).userId;
      await ref
          .read(visitViewModelProvider.notifier)
          .fetchEmployeeVisits(userId);

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
        final roleId = ref.watch(tokenProvider).roleId ?? 0;
        final locationLabel = roleId == 3 ? 'Godown' : 'Shops';

        final todayOrders = ref.watch(ordersViewModelProvider).todayOrdars ?? 0;
        final todayRevenue = ref.watch(ordersViewModelProvider).todayRevenue ?? 0;
        final todayVisitedShops =  ref.watch(visitViewModelProvider).visitedShops ?? 0;
        final monthlyRevenue = ref.watch(ordersViewModelProvider).monthlyRevenue ?? 0;

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
                    title: locationLabel,
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

  // Widget _buildQuickActions(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF7C6FDC).withOpacity(0.15),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: const Icon(
  //               Icons.flash_on_rounded,
  //               color: Color(0xFF7C6FDC),
  //               size: 20,
  //             ),
  //           ),
  //           const SizedBox(width: 10),
  //           const Text(
  //             'Quick Actions',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF2D3142),
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 16),
  //       Row(
  //         children: [
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: _QuickActionButton(
  //               icon: Icons.add_business_rounded,
  //               label: 'Add Shop',
  //               backgroundColor: const Color(0xFFD4F4E7),
  //               iconColor: const Color(0xFF00C853),
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => AddShopScreen()),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
Widget _buildQuickActions(BuildContext context) {
  final tokenState = ref.read(tokenProvider); // Get roleId

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
          const SizedBox(width: 12),
          Expanded(
            child: tokenState.roleId == 2
                ? _QuickActionButton(
                    icon: Icons.add_business_rounded,
                    label: 'Add Shop',
                    backgroundColor: const Color(0xFFD4F4E7),
                    iconColor: const Color(0xFF00C853),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddShopScreen(isGodown: false)),
                      );
                    },
                  )
                : tokenState.roleId == 3
                    ? _QuickActionButton(
                        icon: Icons.warehouse_rounded,
                        label: 'Add Godown',
                        backgroundColor: const Color(0xFFD4E7F4),
                        iconColor: const Color(0xFF2196F3),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddShopScreen(isGodown: true)),
                          );
                        },
                      )
                    : const SizedBox(), // Hide button for other roles
          ),
        ],
      ),
    ],
  );
}
  Widget _buildPerformanceSection() {
    final employeeState = ref.watch(employeeloginViewModelProvider);
    final companyName =
        (employeeState.employeeDetails.value?.isNotEmpty ?? false)
        ? (employeeState.employeeDetails.value!.first.companyName ?? '')
        : '';

    final userName = ref.read(adminloginViewModelProvider).name ?? '';
    final roleId = ref.read(adminloginViewModelProvider).roleId ?? 0;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    
String roleName;
 if (roleId == 2) {
  roleName = "Sales Officer";
} else if (roleId == 3) {
  roleName = "ASM";
} else {
  roleName = "User";
}


    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 247, 107, 97),
            Color.fromARGB(255, 248, 45, 45),
          ],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar / Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $roleName',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.business_rounded,
                      color: Colors.white70,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        companyName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          border: Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
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
  // final String? trend;
  final bool isSmall;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall ? 11 : 13,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
