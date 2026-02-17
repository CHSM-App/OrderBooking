import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/orders_viewmodel.dart';
import 'package:order_booking_app/screens/employee_screen/order_details.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFFE8720C);
const _kPrimaryLight  = Color(0xFFFFF3E8);
const _kSurface       = Color(0xFFFFFFFF);
const _kBackground    = Color(0xFFF5F5F5);
const _kTextPrimary   = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider       = Color(0xFFEEEEEE);

// ── Filter model ──────────────────────────────────────────────────────────────
enum _FilterType { today, thisMonth, custom }

class _ActiveFilter {
  final _FilterType type;
  final DateTimeRange? customRange;

  const _ActiveFilter(this.type, {this.customRange});

  String get label {
    switch (type) {
      case _FilterType.today:
        return 'Today';
      case _FilterType.thisMonth:
        return 'This Month';
      case _FilterType.custom:
        if (customRange != null) {
          final s = _fmt(customRange!.start);
          final e = _fmt(customRange!.end);
          return s == e ? s : '$s – $e';
        }
        return 'Custom';
    }
  }

  static String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];
}

class OrdersListPage extends ConsumerStatefulWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _ActiveFilter? _filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ordersViewModelProvider.notifier).getAllOrders(
            ref.read(adminloginViewModelProvider).userId,
          );
    });
  }

  Future<void> _refresh() async {
    await ref.read(ordersViewModelProvider.notifier).getAllOrders(
          ref.read(adminloginViewModelProvider).userId,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Sort by date: newest first ─────────────────────────────────────────────
  List<Order> _sortByDateDescending(List<Order> orders) {
    final list = List<Order>.from(orders);
    list.sort((a, b) {
      final da = DateTime.tryParse(a.orderDate);
      final db = DateTime.tryParse(b.orderDate);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da); // newest first
    });
    return list;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state),
            if (_filter != null) _buildFilterChip(),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(ordersState state) {
    final isFiltered = _filter != null;

    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search by order number, shop, employee...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.search_rounded,
                        color: Colors.grey[600], size: 22),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter button
          GestureDetector(
            onTap: () => _showFilter(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isFiltered ? _kPrimaryLight : _kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFiltered ? _kPrimary : _kDivider,
                      width: isFiltered ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isFiltered ? _kPrimary : _kBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.filter_list_rounded,
                            size: 18,
                            color: isFiltered
                                ? Colors.white
                                : _kTextSecondary),
                      ),
                    ],
                  ),
                ),
                if (isFiltered)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                          color: _kPrimary, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Active filter chip ─────────────────────────────────────────────────────
  Widget _buildFilterChip() {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _kPrimaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kPrimary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: _kPrimary),
                const SizedBox(width: 6),
                Text(
                  _filter!.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _filter = null),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: _kPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(ordersState state) {
    final hasOrders = state.orders?.value != null;
    if (state.isLoading && !hasOrders) return _buildLoading();
    if (state.errorMessage != null && !hasOrders) {
      return _buildError(state.errorMessage!);
    }

    if (state.orders != null) {
      return state.orders!.when(
        data: (rawOrders) {
          // 1. Sort all orders by date: newest first.
          //    After sorting, index 0 = newest, index (n-1) = oldest.
          //    Order number = position from the bottom: oldest = #1, newest = #n.
          final sorted = _sortByDateDescending(rawOrders);
          final total  = sorted.length;

          // 2. Attach a stable order number to each order based on the full
          //    sorted list (oldest = 1, newest = total). This number never
          //    changes regardless of active filters or search.
          final numbered = [
            for (var i = 0; i < total; i++)
              (order: sorted[i], number: total - i),
          ];

          // 3. Apply date filter
          final afterFilter = _filter == null
              ? numbered
              : numbered.where((e) {
                  final d = DateTime.tryParse(e.order.orderDate);
                  if (d == null) return false;
                  final now = DateTime.now();
                  switch (_filter!.type) {
                    case _FilterType.today:
                      return d.year == now.year &&
                          d.month == now.month &&
                          d.day == now.day;
                    case _FilterType.thisMonth:
                      return d.year == now.year && d.month == now.month;
                    case _FilterType.custom:
                      if (_filter!.customRange == null) return true;
                      final start = _filter!.customRange!.start;
                      final end = _filter!.customRange!.end
                          .add(const Duration(days: 1))
                          .subtract(const Duration(seconds: 1));
                      return !d.isBefore(start) && !d.isAfter(end);
                  }
                }).toList();

          // 4. Apply search filter
          final visible = _searchQuery.isEmpty
              ? afterFilter
              : afterFilter
                  .where((e) => _orderMatchesSearch(
                      e.order, e.number, _searchQuery))
                  .toList();

          if (visible.isEmpty) return _buildSearchEmpty();

          return _buildOrderList(visible);
        },
        loading: _buildLoading,
        error: (e, _) => _buildError(e.toString()),
      );
    }
    return _buildEmpty();
  }

  Widget _buildOrderList(List<({Order order, int number})> orders) {
    return RefreshIndicator(
      color: _kPrimary,
      backgroundColor: _kSurface,
      strokeWidth: 2.5,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(
          order: orders[i].order,
          orderNumber: orders[i].number,
        ),
      ),
    );
  }

  bool _orderMatchesSearch(Order order, int orderNumber, String query) {
    if (query.isEmpty) return true;
    if (orderNumber.toString().contains(query)) return true;
    if ((order.shopNamep ?? '').toLowerCase().contains(query)) return true;
    if ((order.empName  ?? '').toLowerCase().contains(query)) return true;
    if (order.totalPrice.toString().contains(query)) return true;

    final d = DateTime.tryParse(order.orderDate);
    if (d != null && _formatDateForSearch(d).toLowerCase().contains(query)) {
      return true;
    }

    for (final item in order.items) {
      if ((item.productName ?? '').toLowerCase().contains(query)) return true;
      if (item.productId.toString().contains(query)) return true;
      if (item.quantity.toString().contains(query)) return true;
      if (item.price.toString().contains(query)) return true;
    }

    return false;
  }

  String _formatDateForSearch(DateTime date) {
    const months = [
      'jan','feb','mar','apr','may','jun',
      'jul','aug','sep','oct','nov','dec',
    ];
    return '${months[date.month - 1]} ${date.day} ${date.year} '
        '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSearchEmpty() {
    if (_searchQuery.isEmpty) return _buildEmpty();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: _kPrimaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded,
                size: 34, color: _kPrimary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search term.',
            style: TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading orders…',
              style: TextStyle(
                  fontSize: 14,
                  color: _kTextSecondary.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final isFiltered = _filter != null;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: _kPrimaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined,
                size: 34, color: _kPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No orders for this period' : 'No orders yet',
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            isFiltered
                ? 'Try a different date range'
                : 'Orders will appear here once created.',
            style: const TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
          const SizedBox(height: 24),
          if (isFiltered)
            TextButton(
              onPressed: () => setState(() => _filter = null),
              child: const Text('Clear filter',
                  style: TextStyle(
                      color: _kPrimary, fontWeight: FontWeight.w600)),
            )
          else
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  size: 32, color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary)),
            const SizedBox(height: 8),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _kTextSecondary, height: 1.4)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter bottom sheet ────────────────────────────────────────────────────
  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Container(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(sheetCtx).viewInsets.bottom + 32),
          decoration: const BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _kDivider,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter by Date',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary)),
                  if (_filter != null)
                    GestureDetector(
                      onTap: () {
                        setState(() => _filter = null);
                        setSheet(() {});
                        Navigator.pop(sheetCtx);
                      },
                      child: const Text('Clear',
                          style: TextStyle(
                              fontSize: 13,
                              color: _kPrimary,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _FilterRow(
                icon: Icons.today_outlined,
                label: 'Today',
                sublabel: _todayLabel(),
                isSelected: _filter?.type == _FilterType.today,
                onTap: () {
                  setState(() =>
                      _filter = const _ActiveFilter(_FilterType.today));
                  setSheet(() {});
                  Navigator.pop(sheetCtx);
                },
              ),
              const SizedBox(height: 8),
              _FilterRow(
                icon: Icons.calendar_month_outlined,
                label: 'This Month',
                sublabel: _thisMonthLabel(),
                isSelected: _filter?.type == _FilterType.thisMonth,
                onTap: () {
                  setState(() =>
                      _filter = const _ActiveFilter(_FilterType.thisMonth));
                  setSheet(() {});
                  Navigator.pop(sheetCtx);
                },
              ),
              const SizedBox(height: 8),
              _FilterRow(
                icon: Icons.date_range_outlined,
                label: 'Custom Range',
                sublabel: _filter?.type == _FilterType.custom
                    ? _filter!.label
                    : 'Pick start & end date',
                isSelected: _filter?.type == _FilterType.custom,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (!mounted) return;

                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 2),
                    lastDate: now,
                    initialDateRange: _filter?.customRange ??
                        DateTimeRange(
                          start: now.subtract(const Duration(days: 6)),
                          end: now,
                        ),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: _kPrimary,
                          onPrimary: Colors.white,
                          surface: _kSurface,
                          onSurface: _kTextPrimary,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                              foregroundColor: _kPrimary),
                        ),
                      ),
                      child: child!,
                    ),
                  );

                  if (picked != null && mounted) {
                    setState(() => _filter = _ActiveFilter(
                          _FilterType.custom,
                          customRange: picked,
                        ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _thisMonthLabel() {
    final now = DateTime.now();
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}

// ── Filter row ─────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimaryLight : _kBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? _kPrimary : Colors.transparent,
              width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary : _kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected ? Colors.transparent : _kDivider),
              ),
              child: Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : _kTextSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? _kPrimary : _kTextPrimary)),
                  const SizedBox(height: 1),
                  Text(sublabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? _kPrimary.withOpacity(0.7)
                              : _kTextSecondary)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 18, color: _kPrimary)
            else
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: _kTextSecondary),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Order Card
// ══════════════════════════════════════════════════════════════════════════════
class _OrderCard extends StatelessWidget {
  final Order order;
  final int orderNumber;

  const _OrderCard({required this.order, required this.orderNumber});

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  String _formatTime(String raw) {
    try {
      final d = DateTime.parse(raw);
      final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final m = d.minute.toString().padLeft(2, '0');
      final p = d.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $p';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(
                order: order,
                orderNumber: orderNumber,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kDivider),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #$orderNumber',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatDate(order.orderDate)} • ${_formatTime(order.orderDate)}',
                            style: const TextStyle(
                                fontSize: 11, color: _kTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Icon(Icons.chevron_right_rounded,
                            size: 16, color: _kTextSecondary),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: _kDivider),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 13, color: _kTextSecondary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        order.shopNamep ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kTextSecondary,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.shopping_bag_outlined,
                        size: 13, color: _kTextSecondary),
                    const SizedBox(width: 5),
                    Text(
                      '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
