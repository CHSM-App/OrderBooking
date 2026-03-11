import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/product_report.dart';
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
  final adminData = ref.read(adminloginViewModelProvider);

  final companyName = adminData.companyName ?? 'Your Company';
  final adminName = adminData.name ?? 'Admin';
  
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

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Greeting + Role
              Text(
                '$greeting, Admin',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              /// Person Name
              Text(
                adminName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
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
    final productState  = ref.watch(productViewModelProvider);
    final orderState    = ref.watch(ordersViewModelProvider);

    // Active employees
    final activeEmployeesCount = employeeState.employeeList.when(
      loading: () => 0,
      error:   (_, __) => 0,
      data:    (employees) => employees.where((e) => e.checkinStatus == 1).length,
    );

    // Total products
    final totalProductCount = productState.productList?.when(
          loading: () => 0,
          error:   (_, __) => 0,
          data:    (products) => products.length,
        ) ?? 0;

    // Orders: type == 1 only, today
    final today = DateTime.now();

    final int takenCount = orderState.orders?.when(
          loading: () => 0,
          error:   (_, __) => 0,
          data:    (orders) => orders
              .where((o) => o.type == 1 && isSameDay(DateTime.parse(o.orderDate), today))
              .length,
        ) ?? 0;

    final double takenTotal = orderState.orders?.when(
          loading: () => 0.0,
          error:   (_, __) => 0.0,
          data:    (orders) => orders
              .where((o) => o.type == 1 && isSameDay(DateTime.parse(o.orderDate), today))
              .fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble()),
        ) ?? 0.0;

    final int delivCount = orderState.orders?.when(
          loading: () => 0,
          error:   (_, __) => 0,
          data:    (orders) => orders
              .where((o) =>
                  o.type == 1 &&
                  o.isDelivered == 1 &&
                  isSameDay(DateTime.parse(o.orderDate), today))
              .length,
        ) ?? 0;

    final double delivRevenue = orderState.orders?.when(
          loading: () => 0.0,
          error:   (_, __) => 0.0,
          data:    (orders) => orders
              .where((o) =>
                  o.type == 1 &&
                  o.isDelivered == 1 &&
                  isSameDay(DateTime.parse(o.orderDate), today))
              .fold<double>(0.0, (s, o) => s + o.totalPrice.toDouble()),
        ) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3142),
              letterSpacing: 0.2,
            ),
          ),
        ),

        // ── Top summary card: Orders Taken ────────────────────────────────
        _SummaryCard(
          label: 'Orders Taken',
          count: takenCount,
          totalLabel: 'Total Order Value',
          totalValue: formatINR(takenTotal),
          accentColor: const Color(0xFFF57C00),
          icon: Icons.receipt_long_rounded,
          onTap: () => widget.onNavigate(2, ordersTab: 1),
        ),

        const SizedBox(height: 10),

        // ── Bottom row: 3 mini cards ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Delivered',
                value: delivCount.toString(),
                sub: formatINR(delivRevenue),
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF00897B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStatCard(
                label: 'Del. Revenue',
                value: formatINR(delivRevenue),
                sub: '$delivCount orders',
                icon: Icons.payments_outlined,
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStatCard(
                label: 'Employees',
                value: activeEmployeesCount.toString(),
                sub: 'Active',
                icon: Icons.people_rounded,
                color: const Color(0xFF5E35B1),
                onTap: () => widget.onNavigate(3),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Products full-width mini card ─────────────────────────────────
        _MiniStatCardWide(
          label: 'Total Products',
          value: totalProductCount.toString(),
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFFF57C00),
          onTap: () => widget.onNavigate(1),
        ),
      ],
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withOpacity(0.15), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: iconColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Large top card: order count + total value side by side
class _SummaryCard extends StatelessWidget {
  final String    label;
  final int       count;
  final String    totalLabel;
  final String    totalValue;
  final Color     accentColor;
  final IconData  icon;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.totalLabel,
    required this.totalValue,
    required this.accentColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Count + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 40,
              color: const Color(0xFFEEEEEE),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),

            // Total value + label
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalValue,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  totalLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact 3-column mini card
class _MiniStatCard extends StatelessWidget {
  final String    label;
  final String    value;
  final String    sub;
  final IconData  icon;
  final Color     color;
  final VoidCallback? onTap;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const Spacer(),
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                height: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width mini card for products
class _MiniStatCardWide extends StatelessWidget {
  final String    label;
  final String    value;
  final IconData  icon;
  final Color     color;
  final VoidCallback? onTap;

  const _MiniStatCardWide({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}