import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/orders_viewmodel.dart';
import 'package:order_booking_app/screens/employee_screen/order_details.dart';

class OrdersListPage extends ConsumerStatefulWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // ===== DATE FILTER =====
  static const _filterToday = 'Today';
  static const _filterYesterday = 'Yesterday';
  static const _filterThisMonth = 'This Month';
  static const _filterCustom = 'Custom';

  String? _selectedFilter;
  DateTimeRange? _customRange;
  static const _filterAll = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch orders when page loads
    Future.microtask(() {
      ref
          .read(ordersViewModelProvider.notifier)
          .getOrderList(ref.read(adminloginViewModelProvider).companyId ?? '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the orders state
    final ordersState = ref.watch(ordersViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search orders...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: _selectedFilter != null ? Colors.green : null,
            ),
            onSelected: (value) {
              if (value == _filterAll) {
                setState(() {
                  _selectedFilter = null;
                  _customRange = null;
                });
              } else {
                _onFilterSelected(value);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: _filterAll, child: Text('All')),
              PopupMenuItem(value: _filterToday, child: Text('Today')),
              PopupMenuItem(value: _filterYesterday, child: Text('Yesterday')),
              PopupMenuItem(value: _filterThisMonth, child: Text('This Month')),
              PopupMenuItem(value: _filterCustom, child: Text('Custom')),
            ],
          ),
        ],
      ),
      body: _buildBody(ordersState),
    );
  }

  Widget _buildBody(ordersState state) {
    // Handle loading state
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error state
    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    // Handle orders data
    if (state.orders != null) {
      return state.orders!.when(
        data: (orders) {
          if (orders.isEmpty) {
            return _buildEmptyState();
          }
          return _buildOrdersList(context, orders);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      );
    }

    // Default empty state
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here once created',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(ordersViewModelProvider.notifier)
                  .getOrderList(
                    ref.read(adminloginViewModelProvider).companyId ?? '',
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(ordersViewModelProvider.notifier)
                    .getOrderList(
                      ref.read(adminloginViewModelProvider).companyId ?? '',
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _orderMatchesSearch(Order order, int orderNumber, String query) {
    if (query.isEmpty) return true;

    // Search by order number (supports "12", "Order#12", "#12")
    final numericQuery = query.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericQuery.isNotEmpty &&
        orderNumber.toString().contains(numericQuery)) {
      return true;
    }

    // Search by shop name
    final shopName = (order.shopNamep ?? '').toLowerCase();
    if (shopName.contains(query)) return true;

    // Search by employee name
    final empName = (order.empName ?? '').toLowerCase();
    if (empName.contains(query)) return true;

    // Search by total price/amount
    final totalPrice = order.totalPrice.toString();
    if (totalPrice.contains(query)) return true;

    // Search by date
    try {
      final date = DateTime.parse(order.orderDate);
      final formattedDate = _formatDateForSearch(date).toLowerCase();
      if (formattedDate.contains(query)) return true;
    } catch (e) {
      // If date parsing fails, try searching in raw date string
      if (order.orderDate.toLowerCase().contains(query)) return true;
    }

    // Search in sub-items (order items)
    for (var item in order.items) {
      // Search by product name
      if (item.productName?.toLowerCase().contains(query) ?? false) {
        return true;
      }

      // Search by quantity
      if (item.quantity.toString().contains(query)) {
        return true;
      }

      // Search by price
      if (item.price.toString().contains(query)) {
        return true;
      }
    }

    return false;
  }

  Future<void> _onFilterSelected(String label) async {
    if (label == _filterCustom) {
      final now = DateTime.now();
      final initialStart =
          _customRange?.start ?? DateTime(now.year, now.month, now.day);
      final initialEnd =
          _customRange?.end ?? DateTime(now.year, now.month, now.day);

      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 1),
        initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      );

      if (range == null) return;

      setState(() {
        _selectedFilter = label;
        _customRange = range;
      });
      return;
    }

    setState(() {
      _selectedFilter = label;
    });
  }

  bool _passesDateFilter(Order order) {
    if (_selectedFilter == null || _selectedFilter == _filterAll) {
      return true;
    }

    DateTime orderDate;
    try {
      // ⚠️ DO NOT convert toLocal blindly
      orderDate = _dateOnly(DateTime.parse(order.orderDate));
    } catch (_) {
      return false;
    }

    final today = _dateOnly(DateTime.now());

    if (_selectedFilter == _filterToday) {
      return orderDate == today;
    }

    if (_selectedFilter == _filterYesterday) {
      final yesterday = today.subtract(const Duration(days: 1));
      return orderDate == yesterday;
    }

    if (_selectedFilter == _filterThisMonth) {
      return orderDate.year == today.year && orderDate.month == today.month;
    }

    if (_selectedFilter == _filterCustom) {
      if (_customRange == null) return true;

      final start = _dateOnly(_customRange!.start);
      final end = _dateOnly(_customRange!.end);

      return !orderDate.isBefore(start) && !orderDate.isAfter(end);
    }

    return true;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _formatDateForSearch(DateTime date) {
    final months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];

    // Return multiple formats for better search matching
    return '${months[date.month - 1]} ${date.day} ${date.year} ${date.day}/${date.month}/${date.year}';
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    // sort latest order first
    orders.sort(
      (a, b) =>
          DateTime.parse(b.orderDate).compareTo(DateTime.parse(a.orderDate)),
    );

    final List<Order> filteredOrders = [];

    for (int i = 0; i < orders.length; i++) {
      final order = orders[i];
      final orderNumber = orders.length - i;

      if (!_passesDateFilter(order)) continue;

      if (_orderMatchesSearch(order, orderNumber, _searchQuery)) {
        filteredOrders.add(order);
      }
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(ordersViewModelProvider.notifier)
            .getOrderList(
              ref.read(adminloginViewModelProvider).companyId ?? '',
            );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];

          // 🔥 highest number for latest order
          final orderNumber = orders.length - orders.indexOf(order);

          return _OrderCard(order: order, orderNumber: orderNumber);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final int orderNumber;

  const _OrderCard({required this.order, required this.orderNumber});

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
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

      return '${months[date.month - 1]} ${date.day}, ${date.year} at ${_formatTime(date)}';
    } catch (e) {
      return isoDate;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsPage(order: order, orderNumber: orderNumber),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order#$orderNumber',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(order.orderDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Order Info
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInfoChip(
                    Icons.people_sharp,
                    'Employee: ${order.empName ?? 'Unknown'}',
                    Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.store,
                    'Shop: ${order.shopNamep ?? 'Unknown'}',
                    Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.shopping_bag,
                    '${order.items.length} items',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Price
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
