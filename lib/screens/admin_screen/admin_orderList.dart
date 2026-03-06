import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/orders_viewmodel.dart';
import 'package:order_booking_app/screens/employee_screen/order_details.dart';
import 'package:order_booking_app/screens/admin_screen/widgets/admin_retry_widgets.dart';
import 'package:order_booking_app/widgets/app_search_bar.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFFE8720C);
const _kPrimaryLight = Color(0xFFFFF3E8);
const _kSurface = Color(0xFFFFFFFF);
const _kBackground = Color(0xFFF5F5F5);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider = Color(0xFFEEEEEE);

// ── Responsive breakpoints ────────────────────────────────────────────────────
class _Responsive {
  final double width;
  const _Responsive(this.width);

  bool get isSmall => width < 360;
  bool get isTablet => width >= 600;

  double get horizontalPadding => isTablet ? 24 : (isSmall ? 12 : 16);
  double get cardPadding => isTablet ? 18 : (isSmall ? 11 : 14);
  double get searchBarHeight => isSmall ? 42 : 46;
  double get filterButtonSize => isSmall ? 42 : 46;
  double get titleFontSize => isTablet ? 17 : (isSmall ? 13 : 15);
  double get bodyFontSize => isTablet ? 14 : (isSmall ? 11 : 12);
  double get dateFontSize => isTablet ? 13 : (isSmall ? 10 : 11);
  double get priceFontSize => isTablet ? 18 : (isSmall ? 14 : 16);
  double get chipFontSize => isTablet ? 14 : (isSmall ? 11 : 12);
  double get badgeFontSize => isTablet ? 12 : (isSmall ? 9 : 10);
}

// ── Filter model ──────────────────────────────────────────────────────────────
enum OrdersFilterType { today, yesterday, thisMonth, custom }

class _ActiveFilter {
  final OrdersFilterType type;
  final DateTimeRange? customRange;
  const _ActiveFilter(this.type, {this.customRange});

  String get label {
    switch (type) {
      case OrdersFilterType.today:
        return 'Today';
      case OrdersFilterType.yesterday:
        return 'Yesterday';
      case OrdersFilterType.thisMonth:
        return 'This Month';
      case OrdersFilterType.custom:
        if (customRange != null) {
          return '${_d(customRange!.start)} – ${_d(customRange!.end)}';
        }
        return 'Custom';
    }
  }

  static String _d(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }
}

class OrdersListPage extends ConsumerStatefulWidget {
  final OrdersFilterType? initialFilter;
  final int filterRequestId;

  const OrdersListPage({Key? key, this.initialFilter, this.filterRequestId = 0})
    : super(key: key);

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  _ActiveFilter? _filter;
  String? _selectedRegion;

  // Populated synchronously inside _buildBody every time data arrives.
  // By the time the user taps the filter button, this is already filled.
  List<String> _availableRegions = [];

  int _lastAppliedRequestId = 0;

  @override
  void initState() {
    super.initState();
    _lastAppliedRequestId = widget.filterRequestId;
    if (widget.initialFilter != null) {
      _filter = _ActiveFilter(widget.initialFilter!);
    }
    Future.microtask(() {
      ref
          .read(ordersViewModelProvider.notifier)
          .getOrderList(ref.read(adminloginViewModelProvider).companyId ?? '');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrdersListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterRequestId != _lastAppliedRequestId &&
        widget.initialFilter != null) {
      setState(() => _filter = _ActiveFilter(widget.initialFilter!));
      _lastAppliedRequestId = widget.filterRequestId;
    }
  }

  Future<void> _refresh() async {
    await ref
        .read(ordersViewModelProvider.notifier)
        .getOrderList(
          ref.read(adminloginViewModelProvider).companyId ?? '',
          useCacheFirst: false,
        );
  }

  // ── Extract unique regions ─────────────────────────────────────────────────
  List<String> _extractRegions(List<Order> orders) {
    return orders
        .map((o) => o.regionName)
        .where((r) => r != null && r.trim().isNotEmpty)
        .map((r) => r!.trim())
        .toSet()
        .toList()
      ..sort();
  }

  // ── Filters ────────────────────────────────────────────────────────────────
  bool _passesFilter(Order o) {
    if (_filter == null) return true;
    DateTime d;
    try {
      d = _day(DateTime.parse(o.orderDate));
    } catch (_) {
      return false;
    }
    final today = _day(DateTime.now());
    switch (_filter!.type) {
      case OrdersFilterType.today:
        return d == today;
      case OrdersFilterType.yesterday:
        return d == today.subtract(const Duration(days: 1));
      case OrdersFilterType.thisMonth:
        return d.year == today.year && d.month == today.month;
      case OrdersFilterType.custom:
        if (_filter!.customRange == null) return true;
        final s = _day(_filter!.customRange!.start);
        final e = _day(_filter!.customRange!.end);
        return !d.isBefore(s) && !d.isAfter(e);
    }
  }

  bool _passesRegion(Order o) {
    if (_selectedRegion == null) return true;
    return (o.regionName?.trim() ?? '') == _selectedRegion;
  }

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? _parseOrderDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed;
    final re = RegExp(
      r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?$',
    );
    final m = re.firstMatch(raw.trim());
    if (m == null) return null;
    final p1 = int.tryParse(m.group(1) ?? '');
    final p2 = int.tryParse(m.group(2) ?? '');
    final year = int.tryParse(m.group(3) ?? '');
    if (p1 == null || p2 == null || year == null) return null;
    final hour = int.tryParse(m.group(4) ?? '') ?? 0;
    final minute = int.tryParse(m.group(5) ?? '') ?? 0;
    final second = int.tryParse(m.group(6) ?? '') ?? 0;
    int day = p1, month = p2;
    if (p1 > 12 && p2 <= 12) {
      day = p1;
      month = p2;
    } else if (p2 > 12 && p1 <= 12) {
      day = p2;
      month = p1;
    }
    try {
      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  bool _passesSearch(Order o, int number, String q) {
    if (q.isEmpty) return true;
    final qLower = q.toLowerCase();
    final fields = [
      number.toString(),
      o.serverOrderId?.toString() ?? '',
      o.employeeId.toString(),
      o.shopId.toString(),
      o.empName ?? '',
      o.shopNamep ?? '',
      o.address ?? '',
      o.regionName ?? '',
      o.totalPrice.toString(),
      o.orderDate,
      '${o.items.length} item${o.items.length == 1 ? '' : 's'}',
      _fmt(o.orderDate),
    ];
    if (fields.any((f) => f.toLowerCase().contains(qLower))) return true;
    for (final item in o.items) {
      final itemFields = [
        item.productName ?? '',
        item.productUnit,
        item.productId.toString(),
        item.subItemId.toString(),
        item.quantity.toString(),
        item.price.toString(),
        item.totalPrice.toString(),
      ];
      if (itemFields.any((f) => f.toLowerCase().contains(qLower))) return true;
    }
    return false;
  }

  String _orderKey(Order o) {
    if (o.serverOrderId != null) return 'srv-${o.serverOrderId}';
    if (o.localOrderId != null) return 'loc-${o.localOrderId}';
    return 'fallback-${o.shopId}-${o.orderDate}-${o.totalPrice}';
  }

  bool _isNetworkError(String? msg) {
    if (msg == null) return false;
    return [
      'network',
      'internet',
      'connection',
      'socket',
      'failed host',
      'no address',
      'timeout',
      'unreachable',
    ].any((k) => msg.toLowerCase().contains(k));
  }

  String _fmt(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final min = d.minute.toString().padLeft(2, '0');
      final p = d.hour >= 12 ? 'PM' : 'AM';
      return '${months[d.month - 1]} ${d.day}, ${d.year} • $h:$min $p';
    } catch (_) {
      return iso;
    }
  }

  bool get _hasActiveFilters => _filter != null || _selectedRegion != null;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final r = _Responsive(constraints.maxWidth);
        return Scaffold(
          backgroundColor: _kBackground,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(r),
                Expanded(child: _buildBody(state, r)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(_Responsive r) {
    return Container(
      color: _kSurface,
      padding: EdgeInsets.fromLTRB(
        r.horizontalPadding,
        12,
        r.horizontalPadding,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: r.searchBarHeight,
              child: AppSearchBar(
                controller: _searchCtrl,
                hintText: r.isSmall
                    ? 'Search orders…'
                    : 'Search orders, shops, employees…',
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase().trim()),
              ),
            ),
          ),
          SizedBox(width: r.isSmall ? 8 : 10),
          GestureDetector(
            onTap: () => _showFilter(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: r.filterButtonSize,
                  height: r.filterButtonSize,
                  decoration: BoxDecoration(
                    color: _hasActiveFilters ? _kPrimaryLight : _kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasActiveFilters ? _kPrimary : _kDivider,
                      width: _hasActiveFilters ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    size: r.isSmall ? 18 : 20,
                    color: _hasActiveFilters ? _kPrimary : _kTextSecondary,
                  ),
                ),
                if (_hasActiveFilters)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: _kPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────
  Widget _buildFilterChips(_Responsive r, int count, double totalAmount) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 8, left: 15),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          if (_filter != null)
            _FilterChip(
              icon: Icons.calendar_today_outlined,
              label: _filter!.label,
              count: _selectedRegion == null ? count : null,
              onRemove: () => setState(() => _filter = null),
              fontSize: r.chipFontSize,
            ),
          if (_selectedRegion != null)
            _FilterChip(
              icon: Icons.location_on_outlined,
              label: _selectedRegion!,
              count: _filter == null ? count : null,
              onRemove: () => setState(() => _selectedRegion = null),
              fontSize: r.chipFontSize,
            ),
          _AmountBadge(amount: totalAmount, fontSize: r.chipFontSize),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(ordersState state, _Responsive r) {
    if (state.isLoading) return _buildLoading();

    if (state.orders != null) {
      return state.orders!.when(
        data: (orders) {
          // ── THE FIX ──────────────────────────────────────────────────────
          // Assign directly (no setState) — this is safe inside build().
          // _availableRegions is updated every rebuild so it's always current
          // before the user opens the filter sheet.
          _availableRegions = _extractRegions(orders);
          // ─────────────────────────────────────────────────────────────────

          final sorted = List<Order>.from(orders)
            ..sort((a, b) {
              final da = _parseOrderDate(a.orderDate);
              final db = _parseOrderDate(b.orderDate);
              if (da == null && db == null) return 0;
              if (da == null) return 1;
              if (db == null) return -1;
              return db.compareTo(da);
            });

          final numberMap = <String, int>{};
          for (var i = 0; i < sorted.length; i++) {
            numberMap[_orderKey(sorted[i])] = sorted.length - i;
          }

          final visible = sorted
              .where(
                (o) =>
                    _passesFilter(o) &&
                    _passesRegion(o) &&
                    _passesSearch(
                      o,
                      numberMap[_orderKey(o)] ?? 0,
                      _searchQuery,
                    ),
              )
              .toList();

          final totalAmount = visible.fold<double>(
            0.0,
            (s, o) => s + _orderAmount(o),
          );

          if (visible.isEmpty) {
            return Column(
              children: [
                if (_hasActiveFilters) _buildFilterChips(r, 0, 0.0),
                Expanded(child: _buildEmpty()),
              ],
            );
          }

          return Column(
            children: [
              if (_hasActiveFilters)
                _buildFilterChips(r, visible.length, totalAmount),
              Expanded(child: _buildList(visible, numberMap, r)),
            ],
          );
        },
        loading: _buildLoading,
        error: (e, _) => _isNetworkError(e.toString())
            ? _buildNoInternet()
            : _buildError(e.toString()),
      );
    }

    if (state.errorMessage != null) {
      return _isNetworkError(state.errorMessage)
          ? _buildNoInternet()
          : _buildError(state.errorMessage!);
    }

    return _buildEmpty();
  }

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildList(
    List<Order> orders,
    Map<String, int> numberMap,
    _Responsive r,
  ) {
    return RefreshIndicator(
      color: _kPrimary,
      backgroundColor: _kSurface,
      strokeWidth: 2.5,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          r.horizontalPadding,
          12,
          r.horizontalPadding,
          24,
        ),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(
          order: orders[i],
          orderNumber: numberMap[_orderKey(orders[i])] ?? (i + 1),
          responsive: r,
        ),
      ),
    );
  }

  Widget _wrapRefresh(Widget child) {
    return RefreshIndicator(
      color: _kPrimary,
      backgroundColor: _kSurface,
      strokeWidth: 2.5,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 220),
          Center(child: child),
        ],
      ),
    );
  }

  Widget _buildLoading() => _wrapRefresh(
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(
            'Loading orders…',
            style: TextStyle(
              fontSize: 14,
              color: _kTextSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmpty() {
    final isFiltered = _hasActiveFilters || _searchQuery.isNotEmpty;
    return _wrapRefresh(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                size: 34,
                color: _kPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No matching orders' : 'No orders yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                isFiltered
                    ? 'Try a different search or filter'
                    : 'Orders will appear here once created.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _kTextSecondary),
              ),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() {
                  _filter = null;
                  _selectedRegion = null;
                  _searchCtrl.clear();
                  _searchQuery = '';
                }),
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    color: _kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternet() =>
      _wrapRefresh(AdminNoInternetRetry(onRetry: _refresh));
  Widget _buildError(String _) =>
      _wrapRefresh(AdminSomethingWentWrongRetry(onRetry: _refresh));

  String _formatINR(num value) {
    final isNegative = value < 0;
    value = value.abs();
    final parts = value.toStringAsFixed(2).split('.');
    var intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';
    if (intPart.length <= 3)
      return '${isNegative ? '-' : ''}₹$intPart.$decPart';
    final lastThree = intPart.substring(intPart.length - 3);
    var remaining = intPart.substring(0, intPart.length - 3);
    remaining = remaining.replaceAll(RegExp(r'\B(?=(\d{2})+(?!\d))'), ',');
    return '${isNegative ? '-' : ''}₹$remaining,$lastThree.$decPart';
  }

  double _orderAmount(Order o) {
    final amount = o.totalPrice;
    if (amount is String) return double.tryParse(amount as String) ?? 0.0;
    return amount.toDouble();
  }

  // ── Filter bottom sheet ────────────────────────────────────────────────────
  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          final r = _Responsive(MediaQuery.of(sheetCtx).size.width);
          // Read straight from the instance field — always the latest value
          final regions = _availableRegions;

          return Container(
            padding: EdgeInsets.fromLTRB(
              r.horizontalPadding,
              20,
              r.horizontalPadding,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 32,
            ),
            decoration: const BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _kDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title + clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                        ),
                      ),
                      if (_hasActiveFilters)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _filter = null;
                              _selectedRegion = null;
                            });
                            setSheet(() {});
                            Navigator.pop(sheetCtx);
                          },
                          child: const Text(
                            'Clear all',
                            style: TextStyle(
                              fontSize: 13,
                              color: _kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── Region section ────────────────────────────────────────
                  if (regions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionLabel(label: 'Region'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: regions.map((region) {
                        final isSelected = _selectedRegion == region;
                        return GestureDetector(
                          onTap: () {
                            setState(
                              () =>
                                  _selectedRegion = isSelected ? null : region,
                            );
                            setSheet(() {});
                            Navigator.pop(sheetCtx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _kPrimary : _kBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? _kPrimary : _kDivider,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : _kTextSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  region,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : _kTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // ── Date section ──────────────────────────────────────────
                  const _SectionLabel(label: 'Date'),
                  const SizedBox(height: 10),
                  _FilterSheetRow(
                    icon: Icons.today_outlined,
                    label: 'Today',
                    sublabel: _todayLabel(),
                    isSelected: _filter?.type == OrdersFilterType.today,
                    onTap: () {
                      setState(
                        () => _filter = const _ActiveFilter(
                          OrdersFilterType.today,
                        ),
                      );
                      setSheet(() {});
                      Navigator.pop(sheetCtx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _FilterSheetRow(
                    icon: Icons.history_outlined,
                    label: 'Yesterday',
                    sublabel: _yesterdayLabel(),
                    isSelected: _filter?.type == OrdersFilterType.yesterday,
                    onTap: () {
                      setState(
                        () => _filter = const _ActiveFilter(
                          OrdersFilterType.yesterday,
                        ),
                      );
                      setSheet(() {});
                      Navigator.pop(sheetCtx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _FilterSheetRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'This Month',
                    sublabel: _thisMonthLabel(),
                    isSelected: _filter?.type == OrdersFilterType.thisMonth,
                    onTap: () {
                      setState(
                        () => _filter = const _ActiveFilter(
                          OrdersFilterType.thisMonth,
                        ),
                      );
                      setSheet(() {});
                      Navigator.pop(sheetCtx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _FilterSheetRow(
                    icon: Icons.date_range_outlined,
                    label: 'Custom Range',
                    sublabel: _filter?.type == OrdersFilterType.custom
                        ? _filter!.label
                        : 'Pick start & end date',
                    isSelected: _filter?.type == OrdersFilterType.custom,
                    onTap: () async {
                      Navigator.pop(sheetCtx);
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (!mounted) return;
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 5),
                        lastDate: now,
                        initialDateRange:
                            _filter?.customRange ??
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
                                foregroundColor: _kPrimary,
                              ),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null && mounted) {
                        setState(
                          () => _filter = _ActiveFilter(
                            OrdersFilterType.custom,
                            customRange: picked,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _todayLabel() {
    final d = DateTime.now();
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  String _yesterdayLabel() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  String _thisMonthLabel() {
    final d = DateTime.now();
    const m = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${m[d.month - 1]} ${d.year}';
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _kTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(child: Divider(color: _kDivider, height: 1)),
    ],
  );
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onRemove;
  final double fontSize;

  const _FilterChip({
    required this.icon,
    required this.label,
    this.count,
    required this.onRemove,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _kPrimaryLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kPrimary.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _kPrimary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: _kPrimary,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _kPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close_rounded, size: 14, color: _kPrimary),
        ),
      ],
    ),
  );
}

// ── Amount badge ──────────────────────────────────────────────────────────────
class _AmountBadge extends StatelessWidget {
  final double amount;
  final double fontSize;
  const _AmountBadge({required this.amount, this.fontSize = 12});

  String _fmt(num value) {
    final neg = value < 0;
    value = value.abs();
    final parts = value.toStringAsFixed(2).split('.');
    var int_ = parts[0];
    final dec = parts.length > 1 ? parts[1] : '00';
    if (int_.length <= 3) return '${neg ? '-' : ''}₹$int_.$dec';
    final last3 = int_.substring(int_.length - 3);
    var rest = int_
        .substring(0, int_.length - 3)
        .replaceAll(RegExp(r'\B(?=(\d{2})+(?!\d))'), ',');
    return '${neg ? '-' : ''}₹$rest,$last3.$dec';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kDivider),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.currency_rupee_rounded,
          size: 12,
          color: _kTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          _fmt(amount).replaceFirst('₹', ''),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: _kTextPrimary,
          ),
        ),
      ],
    ),
  );
}

// ── Filter sheet row ──────────────────────────────────────────────────────────
class _FilterSheetRow extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterSheetRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? _kPrimaryLight : _kBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _kPrimary : Colors.transparent,
          width: 1.5,
        ),
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
                color: isSelected ? Colors.transparent : _kDivider,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : _kTextSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _kPrimary : _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? _kPrimary.withOpacity(0.7)
                        : _kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.check_rounded : Icons.chevron_right_rounded,
            size: 18,
            color: isSelected ? _kPrimary : _kTextSecondary,
          ),
        ],
      ),
    ),
  );
}

// ── Order Card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  final int orderNumber;
  final _Responsive responsive;

  const _OrderCard({
    required this.order,
    required this.orderNumber,
    required this.responsive,
  });

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
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
      return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderDetailsPage(order: order, orderNumber: orderNumber),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kDivider),
            ),
            padding: EdgeInsets.all(r.cardPadding),
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
                            order.shopNamep ?? 'Unknown',
                            style: TextStyle(
                              fontSize: r.titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatDate(order.orderDate)} • ${_formatTime(order.orderDate)}',
                            style: TextStyle(
                              fontSize: r.dateFontSize,
                              color: _kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${order.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: r.priceFontSize,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: _kDivider),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: r.isSmall ? 11 : 13,
                      color: _kTextSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: r.bodyFontSize,
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    if ((order.regionName ?? '').isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _kPrimaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: r.isSmall ? 9 : 10,
                              color: _kPrimary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                order.regionName!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: r.badgeFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: _kPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: r.isSmall ? 16 : 18,
                      color: _kTextSecondary,
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
