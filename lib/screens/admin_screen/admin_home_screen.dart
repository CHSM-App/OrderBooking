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

  final PageController _overviewPageController = PageController();
  int _overviewPage = 0; // 0 = SO, 1 = ASM

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
    _overviewPageController.dispose();
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

  // ── Welcome / Header ─────────────────────────────────────────────────────────
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
                Text(
                  '$greeting, Admin',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

  // ── Stats Overview with SO / ASM horizontal pager ────────────────────────────
  Widget _buildStatsOverview() {
    final employeeState = ref.watch(employeeloginViewModelProvider);
    final productState  = ref.watch(productViewModelProvider);
    final orderState    = ref.watch(ordersViewModelProvider);

    // Active employees by role (roleId 2 = SO, roleId 3 = ASM)
    final soActiveCount = employeeState.employeeList.when(
      loading: () => 0,
      error:   (_, __) => 0,
      data:    (employees) => employees
          .where((e) => e.checkinStatus == 1 && e.roleId == 2)
          .length,
    );
    final asmActiveCount = employeeState.employeeList.when(
      loading: () => 0,
      error:   (_, __) => 0,
      data:    (employees) => employees
          .where((e) => e.checkinStatus == 1 && e.roleId == 3)
          .length,
    );

    // Total products
    final totalProductCount = productState.productList?.when(
          loading: () => 0,
          error:   (_, __) => 0,
          data:    (products) => products.length,
        ) ??
        0;

    // ── SO stats from ViewModel ──────────────────────────────────────────────
    final soTakenCount      = orderState.soTakenCount      ?? 0;
    final soTakenTotal      = orderState.soTakenTotal      ?? 0.0;
    final soDeliveredCount  = orderState.soDeliveredCount  ?? 0;
    final soDeliveredRev    = orderState.soDeliveredRevenue ?? 0.0;

    // ── ASM stats from ViewModel ─────────────────────────────────────────────
    final asmTakenCount     = orderState.asmTakenCount     ?? 0;
    final asmTakenTotal     = orderState.asmTakenTotal     ?? 0.0;
    final asmDeliveredCount = orderState.asmDeliveredCount ?? 0;
    final asmDeliveredRev   = orderState.asmDeliveredRevenue ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header with tab indicators ──────────────────────────────
        Row(
          children: [
            const Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            // SO / ASM pill tabs
            _OverviewTabPills(
              selectedIndex: _overviewPage,
              onTap: (i) {
                _overviewPageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Horizontal pager for SO / ASM overviews ──────────────────────────
        SizedBox(
          // Height must be fixed for PageView inside a ScrollView
          height: 210,
          child: PageView(
            controller: _overviewPageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _overviewPage = i),
            children: [
              // ── SO page ───────────────────────────────────────────────────
              _OverviewPage(
                takenCount:      soTakenCount,
                takenTotal:      formatINR(soTakenTotal),
                delivCount:      soDeliveredCount,
                delivRevenue:    formatINR(soDeliveredRev),
                activeEmployees: soActiveCount,
                accentColor:     const Color(0xFFF57C00),
                typeLabel:       'SO',
                onOrdersTap:     () => widget.onNavigate(2, ordersTab: 1),
                onEmployeesTap:  () => widget.onNavigate(3),
                formatINR:       formatINR,
              ),
              // ── ASM page ──────────────────────────────────────────────────
              _OverviewPage(
                takenCount:      asmTakenCount,
                takenTotal:      formatINR(asmTakenTotal),
                delivCount:      asmDeliveredCount,
                delivRevenue:    formatINR(asmDeliveredRev),
                activeEmployees: asmActiveCount,
                accentColor:     const Color(0xFF1976D2),
                typeLabel:       'ASM',
                onOrdersTap:     () => widget.onNavigate(2, ordersTab: 2),
                onEmployeesTap:  () => widget.onNavigate(3),
                formatINR:       formatINR,
              ),
            ],
          ),
        ),

        // ── Page dot indicator ───────────────────────────────────────────────
        // const SizedBox(height: 5),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(2, (i) {
              final active = i == _overviewPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width:  active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? (_overviewPage == 0
                          ? const Color(0xFFF57C00)
                          : const Color(0xFF1976D2))
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // ── Products full-width card (always visible) ────────────────────────
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

  // ── Quick Actions ─────────────────────────────────────────────────────────────
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
                        companyId:
                            ref.read(adminloginViewModelProvider).companyId ??
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

// ── Overview Tab Pills (SO / ASM) ─────────────────────────────────────────────
class _OverviewTabPills extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _OverviewTabPills({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['SO', 'ASM'];
    const activeColors = [Color(0xFFF57C00), Color(0xFF1976D2)];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final active = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: active ? activeColors[i] : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: activeColors[i].withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Single overview page (SO or ASM) ─────────────────────────────────────────
class _OverviewPage extends StatelessWidget {
  final int    takenCount;
  final String takenTotal;
  final int    delivCount;
  final String delivRevenue;
  final int    activeEmployees;
  final Color  accentColor;
  final String typeLabel;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onEmployeesTap;
  final String Function(num) formatINR;

  const _OverviewPage({
    required this.takenCount,
    required this.takenTotal,
    required this.delivCount,
    required this.delivRevenue,
    required this.activeEmployees,
    required this.accentColor,
    required this.typeLabel,
    required this.formatINR,
    this.onOrdersTap,
    this.onEmployeesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Top summary card ──────────────────────────────────────────────
        _SummaryCard(
          label: '$typeLabel Orders Taken',
          count: takenCount,
          totalLabel: 'Total Order Value',
          totalValue: takenTotal,
          accentColor: accentColor,
          icon: Icons.receipt_long_rounded,
          onTap: onOrdersTap,
        ),
        const SizedBox(height: 10),
        // ── Bottom three mini cards ───────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Delivered',
                value: delivCount.toString(),
                sub: '',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF00897B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStatCard(
                label: 'Del. Revenue',
                value: delivRevenue,
                sub: '',
                icon: Icons.payments_outlined,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStatCard(
                label: '$typeLabel Employees',
                value: activeEmployees.toString(),
                sub: 'Active',
                icon: Icons.people_rounded,
                color: const Color(0xFF5E35B1),
                onTap: onEmployeesTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Quick Action Button ───────────────────────────────────────────────────────
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

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final String totalLabel;
  final String totalValue;
  final Color accentColor;
  final IconData icon;
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
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
            Container(
              width: 1,
              height: 40,
              color: const Color(0xFFEEEEEE),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
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
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Mini Stat Card (3-col) ────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
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
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
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

// ── Mini Stat Card Wide ───────────────────────────────────────────────────────
class _MiniStatCardWide extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
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
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}