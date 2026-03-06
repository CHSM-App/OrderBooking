import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/orders_viewmodel.dart';
import 'package:order_booking_app/screens/employee_screen/order_details.dart';
import 'package:order_booking_app/screens/employee_screen/order_printPdf.dart';
import 'package:order_booking_app/widgets/app_search_bar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFFE8720C);
const _kPrimaryLight = Color(0xFFFFF3E8);
const _kSurface = Color(0xFFFFFFFF);
const _kBackground = Color(0xFFFFFFFF);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider = Color(0xFFEEEEEE);

// ── Date group label ──────────────────────────────────────────────────────────
String _groupLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final day = DateTime(d.year, d.month, d.day);

  if (day == today) return 'Today';
  if (day == yesterday) return 'Yesterday';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  if (d.year == now.year) return '${d.day} ${months[d.month - 1]}';
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// ── Grouped list item ─────────────────────────────────────────────────────────
sealed class _ListItem {}

class _HeaderItem extends _ListItem {
  final String label;
  final double totalAmount;
  final DateTime day;
  _HeaderItem(this.label, this.totalAmount, this.day);
}

class _OrderItem extends _ListItem {
  final Order order;
  final int number;
  _OrderItem(this.order, this.number);
}

// ── Page ──────────────────────────────────────────────────────────────────────
class OrdersListPage extends ConsumerStatefulWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Selection state ─────────────────────────────────────────────────────────
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  final Map<String, Order> _orderMap = {};
  final Map<String, int> _orderNumberMap = {};

  // ── Animation — nullable so there's no "not initialized" risk ───────────────
  // Both are set together in initState; neither is accessed before then.
  AnimationController? _bottomBarController;
  Animation<Offset>? _bottomBarSlide;

  @override
  void initState() {
    super.initState();
    // vsync is available after super.initState(), so this is always safe.
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _bottomBarController = controller;
    _bottomBarSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    Future.microtask(() {
      ref
          .read(ordersViewModelProvider.notifier)
          .getAllOrders(ref.read(adminloginViewModelProvider).userId);
    });
  }

  Future<void> _refresh() async {
    await ref
        .read(ordersViewModelProvider.notifier)
        .getAllOrders(ref.read(adminloginViewModelProvider).userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bottomBarController?.dispose();
    super.dispose();
  }

  // ── Selection helpers ───────────────────────────────────────────────────────
  void _enterSelectionMode(Order order) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(order.localOrderId!);
    });
    _bottomBarController?.forward();
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
    _bottomBarController?.reverse();
  }

  void _toggleOrder(Order order) {
    setState(() {
      if (_selectedIds.contains(order.localOrderId)) {
        _selectedIds.remove(order.localOrderId);
        if (_selectedIds.isEmpty) _exitSelectionMode();
      } else {
        _selectedIds.add(order.localOrderId!);
      }
    });
  }

  bool _isDayFullySelected(List<Order> dayOrders) =>
      dayOrders.every((o) => _selectedIds.contains(o.localOrderId));

  bool _isDayPartiallySelected(List<Order> dayOrders) {
    final any = dayOrders.any((o) => _selectedIds.contains(o.localOrderId));
    return any && !_isDayFullySelected(dayOrders);
  }

  void _toggleDay(List<Order> dayOrders) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_isDayFullySelected(dayOrders)) {
        for (final o in dayOrders) _selectedIds.remove(o.localOrderId);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
          _bottomBarController?.reverse();
        }
      } else {
        for (final o in dayOrders) _selectedIds.add(o.localOrderId!);
        if (!_isSelectionMode) {
          _isSelectionMode = true;
          _bottomBarController?.forward();
        }
      }
    });
  }

  void _onMarkAsDelivered() {
    final result = _selectedIds
        .map((localId) => _orderMap[localId])
        .whereType<Order>()
        .map((o) => {
              'serverId': o.serverOrderId,
              'localId': o.localOrderId,
            })
        .toList();

    // TODO: call your delivery API here with [result]
    debugPrint('Mark as delivered: $result');

    _exitSelectionMode();
  }

  void _onPrintSelected() {
    final selectedOrders = _selectedIds
        .map((localId) => _orderMap[localId])
        .whereType<Order>()
        .toList();
    if (selectedOrders.isEmpty) return;

    final orderNumbers = selectedOrders
        .map((o) => _orderNumberMap[o.localOrderId] ?? 0)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiOrderPrintPreviewPage(
          orders: selectedOrders,
          orderNumbers: orderNumbers,
        ),
      ),
    );
  }

  Future<Directory> _resolveExportDirectory() async {
    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectory();
      if (external != null) {
        final downloadDir = Directory(p.join(external.path, 'Download'));
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }
    }
    return getApplicationDocumentsDirectory();
  }

Future<void> _exportSelectedToExcel() async {
  final selectedOrders = _selectedIds
      .map((localId) => _orderMap[localId])
      .whereType<Order>()
      .toList();
  if (selectedOrders.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select at least one order to export.')),
    );
    return;
  }

  try {
    final excel = xl.Excel.createExcel();
    final sheetName =
        excel.sheets.keys.contains('Sheet1') ? 'Sheet1' : 'Orders';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    sheet.appendRow([
      "Shop Name", 'Owner Name', 'Mobile No', 'Address',
      'Employee Name', 'Order Date/Time', 'Product',
      'Quantity', 'Unit', 'Price',
    ]);

    for (final order in selectedOrders) {
      if (order.items.isEmpty) {
        sheet.appendRow([
          order.shopNamep ?? '', order.ownerName ?? '',
          order.mobileNo ?? '', order.address ?? '',
          order.empName ?? '', order.orderDate,
          '', '', '', '',
        ]);
      } else {
        for (int i = 0; i < order.items.length; i++) {
          final item = order.items[i];
          final isFirst = i == 0;
          sheet.appendRow([
            isFirst ? (order.shopNamep ?? '') : '',
            isFirst ? (order.ownerName ?? '') : '',
            isFirst ? (order.mobileNo ?? '') : '',
            isFirst ? (order.address ?? '') : '',
            isFirst ? (order.empName ?? '') : '',
            isFirst ? order.orderDate : '',
            item.productName ?? item.productId.toString(),
            item.quantity, item.productUnit, item.price,
          ]);
        }
      }
      // Empty row after every order (after all its products)
      sheet.appendRow(['', '', '', '', '', '', '', '', '', '']);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate Excel file.')),
      );
      return;
    }

    // Save to temp file, then share
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'orders_${DateTime.now().toIso8601String().replaceAll(':', '-')}.xlsx';
    final filePath = p.join(tempDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    if (!mounted) return;

    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
      subject: 'Orders Export',
    );

  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $e')),
    );
  }
}
  // ── Sort newest first ───────────────────────────────────────────────────────
  List<Order> _sortDesc(List<Order> orders) {
    final list = List<Order>.from(orders);
    list.sort((a, b) {
      final da = DateTime.tryParse(a.orderDate);
      final db = DateTime.tryParse(b.orderDate);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return list;
  }

  // ── Build grouped list items ────────────────────────────────────────────────
  final Map<DateTime, List<Order>> _dayOrdersMap = {};

  List<_ListItem> _buildItems(List<Order> rawOrders) {
    _orderMap.clear();
    _orderNumberMap.clear();
    for (final o in rawOrders) {
      if (o.localOrderId != null) _orderMap[o.localOrderId!] = o;
    }

    final sorted = _sortDesc(rawOrders);
    final total = sorted.length;
    final numbered = [
      for (var i = 0; i < total; i++) (order: sorted[i], number: total - i),
    ];
    for (final e in numbered) {
      final id = e.order.localOrderId;
      if (id != null) _orderNumberMap[id] = e.number;
    }

    final visible = _searchQuery.isEmpty
        ? numbered
        : numbered.where((e) => _matches(e.order, e.number)).toList();

    if (visible.isEmpty) return [];

    final grouped = <DateTime, List<({Order order, int number})>>{};
    for (final e in visible) {
      final d = DateTime.tryParse(e.order.orderDate);
      if (d == null) continue;
      final key = _dayOnly(d);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    _dayOrdersMap.clear();
    for (final entry in grouped.entries) {
      _dayOrdersMap[entry.key] = entry.value.map((e) => e.order).toList();
    }

    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final items = <_ListItem>[];
    for (final day in days) {
      final dayOrders = grouped[day]!;
      final dayTotal =
          dayOrders.fold<double>(0.0, (s, e) => s + e.order.totalPrice);
      items.add(_HeaderItem(_groupLabel(day), dayTotal, day));
      for (final e in dayOrders) {
        items.add(_OrderItem(e.order, e.number));
      }
    }
    return items;
  }

  bool _matches(Order order, int number) {
    final q = _searchQuery;
    if (number.toString().contains(q)) return true;
    if ((order.shopNamep ?? '').toLowerCase().contains(q)) return true;
    if ((order.empName ?? '').toLowerCase().contains(q)) return true;
    if (order.totalPrice.toString().contains(q)) return true;
    final d = DateTime.tryParse(order.orderDate);
    if (d != null) {
      const m = [
        'jan', 'feb', 'mar', 'apr', 'may', 'jun',
        'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
      ];
      final s =
          '${m[d.month - 1]} ${d.day} ${d.year} ${d.day}/${d.month}/${d.year}';
      if (s.contains(q)) return true;
    }
    for (final item in order.items) {
      if ((item.productName ?? '').toLowerCase().contains(q)) return true;
    }
    return false;
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
    final slide = _bottomBarSlide; // local copy — avoids null-check repetition

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSelectionMode) _exitSelectionMode();
      },
      child: Scaffold(
        backgroundColor: _kBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
        // Only attach the bottomNavigationBar when the animation is ready
        // AND we are in selection mode — avoids the "not initialized" crash.
        bottomNavigationBar: (slide != null && _isSelectionMode)
            ? SlideTransition(
                position: slide,
                child: _buildBottomBar(),
              )
            : null,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          if (_isSelectionMode)
            GestureDetector(
              onTap: _exitSelectionMode,
              child: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.close_rounded, color: _kPrimary, size: 22),
              ),
            ),
          Expanded(
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search by shop, product, amount…',
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase().trim()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final count = _selectedIds.length;
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kPrimaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count selected',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: count > 0 ? _onMarkAsDelivered : null,
              icon: const Icon(Icons.local_shipping_rounded, size: 18),
              label: const Text(
                'Mark as Delivered',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _kDivider,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: count > 0
                  ? () {
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (_) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.picture_as_pdf),
                                title: const Text('Export as PDF'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _onPrintSelected();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.grid_on_rounded),
                                title: const Text('Export as Excel (.xlsx)'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _exportSelectedToExcel();
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.file_download_rounded, size: 18),
              label: const Text(
                'Export',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kPrimary,
                side: const BorderSide(color: _kPrimary, width: 1.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ordersState state) {
    final hasOrders = state.orders?.value != null;
    if (state.isLoading && !hasOrders) return _buildLoading();
    if (state.errorMessage != null && !hasOrders) {
      return _buildError(state.errorMessage!);
    }
    if (state.orders == null) return _buildEmpty();

    return state.orders!.when(
      data: (rawOrders) {
        final items = _buildItems(rawOrders);
        if (items.isEmpty) return _buildEmpty();
        return _buildList(items);
      },
      loading: _buildLoading,
      error: (e, _) => _buildError(e.toString()),
    );
  }

  Widget _buildList(List<_ListItem> items) {
    return RefreshIndicator(
      color: _kPrimary,
      backgroundColor: _kSurface,
      strokeWidth: 2.5,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          if (item is _HeaderItem) {
            final dayOrders = _dayOrdersMap[item.day] ?? [];
            return _DateHeader(
              item: item,
              isSelectionMode: _isSelectionMode,
              isFullySelected: _isDayFullySelected(dayOrders),
              isPartiallySelected: _isDayPartiallySelected(dayOrders),
              onToggle: () => _toggleDay(dayOrders),
            );
          }
          if (item is _OrderItem) {
            final isSelected =
                _selectedIds.contains(item.order.localOrderId);
            return _OrderCard(
              order: item.order,
              orderNumber: item.number,
              isSelectionMode: _isSelectionMode,
              isSelected: isSelected,
              onLongPress: () => _enterSelectionMode(item.order),
              onTap: () {
                if (_isSelectionMode) {
                  _toggleOrder(item.order);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsPage(
                        order: item.order,
                        orderNumber: item.number,
                      ),
                    ),
                  );
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── States ──────────────────────────────────────────────────────────────────
  Widget _buildLoading() => const Center(
        child:
            CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
      );

  Widget _buildEmpty() => Center(
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
              _searchQuery.isNotEmpty ? 'No results found' : 'No orders yet',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term.'
                  : 'Orders will appear here once created.',
              style:
                  const TextStyle(fontSize: 13, color: _kTextSecondary),
            ),
          ],
        ),
      );

  Widget _buildError(String msg) => Center(
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

// ── Date section header ───────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final _HeaderItem item;
  final bool isSelectionMode;
  final bool isFullySelected;
  final bool isPartiallySelected;
  final VoidCallback onToggle;

  const _DateHeader({
    required this.item,
    required this.isSelectionMode,
    required this.isFullySelected,
    required this.isPartiallySelected,
    required this.onToggle,
  });

  String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    var intPart = parts[0];
    final dec = parts[1];
    if (intPart.length > 3) {
      final last3 = intPart.substring(intPart.length - 3);
      var rem = intPart.substring(0, intPart.length - 3);
      rem = rem.replaceAll(RegExp(r'\B(?=(\d{2})+(?!\d))'), ',');
      intPart = '$rem,$last3';
    }
    return '₹$intPart.$dec';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: isSelectionMode
                ? GestureDetector(
                    onTap: onToggle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _DayCheckbox(
                        isFullySelected: isFullySelected,
                        isPartiallySelected: isPartiallySelected,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kTextSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: _kDivider)),
          const SizedBox(width: 8),
          Text(
            _fmt(item.totalAmount),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Day checkbox widget ───────────────────────────────────────────────────────
class _DayCheckbox extends StatelessWidget {
  final bool isFullySelected;
  final bool isPartiallySelected;

  const _DayCheckbox({
    required this.isFullySelected,
    required this.isPartiallySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isAnySelected = isFullySelected || isPartiallySelected;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isFullySelected ? _kPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAnySelected ? _kPrimary : _kTextSecondary,
          width: 2,
        ),
      ),
      child: isFullySelected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : isPartiallySelected
              ? Center(
                  child: Container(
                    width: 10,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
              : null,
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  final int orderNumber;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _OrderCard({
    required this.order,
    required this.orderNumber,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  String _time(String raw) {
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
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _kPrimary : _kDivider,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? _kPrimaryLight : _kSurface,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            onLongPress: isSelectionMode ? null : onLongPress,
            borderRadius: BorderRadius.circular(13),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: isSelectionMode
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _OrderCheckbox(isSelected: isSelected),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.shopNamep ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 11, color: _kTextSecondary),
                            const SizedBox(width: 3),
                            Text(_time(order.orderDate),
                                style: const TextStyle(
                                    fontSize: 11, color: _kTextSecondary)),
                            const SizedBox(width: 10),
                            const Icon(Icons.inventory_2_outlined,
                                size: 11, color: _kTextSecondary),
                            const SizedBox(width: 3),
                            Text(
                              '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  fontSize: 11, color: _kTextSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${order.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? _kPrimary : _kTextPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        size: 18,
                        color: isSelected ? _kPrimary : _kTextSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Order checkbox ────────────────────────────────────────────────────────────
class _OrderCheckbox extends StatelessWidget {
  final bool isSelected;
  const _OrderCheckbox({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? _kPrimary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _kPrimary : _kTextSecondary,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}
