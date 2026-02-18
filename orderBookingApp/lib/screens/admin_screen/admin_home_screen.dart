import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/product_report.dart';
import 'admin_addProduct.dart';
import 'admin_regionDetails.dart';
import 'admin_shopDetails.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  final Function(int, {int ordersTab}) onNavigate;

  const AdminHomePage({super.key, required this.onNavigate});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage>
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

  Future<void> _onRefresh() async {
    final companyId = ref.read(adminloginViewModelProvider).companyId ?? '';
    if (companyId.isEmpty) return;

    await ref
        .read(employeeloginViewModelProvider.notifier)
        .getEmployeeList(companyId);
    await ref
        .read(ordersViewModelProvider.notifier)
        .getOrderList(companyId);
    await ref
        .read(productViewModelProvider.notifier)
        .fetchProductList(companyId);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String formatINR(num value) {
    final isNegative = value < 0;
    value = value.abs();
    String str = value.toStringAsFixed(0);
    if (str.length <= 3) return '${isNegative ? '-' : ''}\u20B9$str';
    String lastThree = str.substring(str.length - 3);
    String remaining = str.substring(0, str.length - 3);
    final reg = RegExp(r'\B(?=(\d{2})+(?!\d))');
    remaining = remaining.replaceAll(reg, ',');
    return '${isNegative ? '-' : ''}\u20B9$remaining,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adminloginViewModelProvider, (prev, next) {
      final companyId = next.companyId;
      if (companyId != null && companyId.isNotEmpty) {
        ref
            .read(employeeloginViewModelProvider.notifier)
            .getEmployeeList(companyId);
        ref.read(ordersViewModelProvider.notifier).getOrderList(companyId);
        ref
            .read(productViewModelProvider.notifier)
            .fetchProductList(companyId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        color: const Color(0xFFF57C00),
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
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      _buildStatsOverview(),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
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

  // ── Welcome / Header ────────────────────────────────────────────────────────
  Widget _buildWelcomeSection() {
    final companyName =
        ref.read(adminloginViewModelProvider).companyName ?? 'Your Company';
    final adminName =
        ref.read(adminloginViewModelProvider).name ?? 'Admin';

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF57C00), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
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
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adminName,
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

  // ── Stats Grid ───────────────────────────────────────────────────────────────
  Widget _buildStatsOverview() {
    final employeeState = ref.watch(employeeloginViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final orderState = ref.watch(ordersViewModelProvider);

    final activeEmployeesCount = employeeState.employeeList.when(
      loading: () => 0,
      error: (_, __) => 0,
      data: (employees) =>
          employees.where((e) => e.activeStatus == 1).length,
    );

    final totalProductCount = productState.productList?.when(
          loading: () => 0,
          error: (_, __) => 0,
          data: (products) => products.length,
        ) ??
        0;

    final int todaysOrdersCount = orderState.orders?.when(
          loading: () => 0,
          error: (_, __) => 0,
          data: (orders) {
            final today = DateTime.now();
            return orders
                .where((o) => isSameDay(DateTime.parse(o.orderDate), today))
                .length;
          },
        ) ??
        0;

    final double todaysRevenue = orderState.orders?.when(
          loading: () => 0.0,
          error: (_, __) => 0.0,
          data: (orders) {
            final today = DateTime.now();
            return orders
                .where((o) => isSameDay(DateTime.parse(o.orderDate), today))
                .fold<double>(0.0, (sum, o) {
              final amount = o.totalPrice;
              return sum +
                  (amount is String
                      ? double.tryParse(amount as String) ?? 0.0
                      : amount.toDouble());
            });
          },
        ) ??
        0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 380;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "Today's Orders",
                    value: todaysOrdersCount.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFF57C00),
                    isSmall: isSmallScreen,
                    onTap: () => widget.onNavigate(2, ordersTab: 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Active Employees',
                    value: activeEmployeesCount.toString(),
                    icon: Icons.people_rounded,
                    color: const Color(0xFF00897B),
                    isSmall: isSmallScreen,
                    onTap: () => widget.onNavigate(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Products',
                    value: totalProductCount.toString(),
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFF5E35B1),
                    isSmall: isSmallScreen,
                    onTap: () => widget.onNavigate(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: "Today's Revenue",
                    value: formatINR(todaysRevenue),
                    icon: Icons.currency_rupee_outlined,
                    color: const Color(0xFF1976D2),
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

  // ── Quick Actions ────────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF57C00).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFFF57C00),
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
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_box_outlined,
                label: 'Add Product',
                backgroundColor: const Color(0xFFFFECDC),
                iconColor: const Color(0xFFF57C00),
                onTap: () {
                  final adminId =
                      ref.read(adminloginViewModelProvider).userId;
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
              child: _QuickActionButton(
                icon: Icons.bar_chart_outlined,
                label: 'Reports',
                backgroundColor: const Color(0xFFD4F4EE),
                iconColor: const Color(0xFF00897B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportPage(
                        companyId: ref
                                .read(adminloginViewModelProvider)
                                .companyId ??
                            '',
                      ),
                    ),
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
              child: _QuickActionButton(
                icon: Icons.location_on_outlined,
                label: 'View Regions',
                backgroundColor: const Color(0xFFFFE5DC),
                iconColor: const Color(0xFFE64A19),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegionDetailsPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.store_outlined,
                label: 'View Shops',
                backgroundColor: const Color(0xFFEDE7F6),
                iconColor: const Color(0xFF5E35B1),
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
}

// ── Shared Stat Card ──────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmall;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isSmall = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Colors.grey[400],
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
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Button (matches employee HomePage style) ─────────────────────
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
