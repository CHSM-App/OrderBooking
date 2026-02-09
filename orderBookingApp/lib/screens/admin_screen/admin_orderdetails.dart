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

class _OrdersListPageState extends ConsumerState<OrdersListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;

  // ===== DATE FILTER =====
  static const _filterToday = 'Today';
  static const _filterYesterday = 'Yesterday';
  static const _filterThisMonth = 'This Month';
  static const _filterCustom = 'Custom';
  static const _filterAll = 'All';

  String? _selectedFilter;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersViewModelProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(context, isTablet),
              Expanded(child: _buildBody(ordersState, isTablet)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
      //  color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
       Row(
  children: [
    // 🔍 Search bar (UNCHANGED)
    Expanded(
      child: Container(
        height: isTablet ? 56 : 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? Colors.green.shade300
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          style: TextStyle(fontSize: isTablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: 'Search by order number, shop, employee...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: isTablet ? 16 : 14,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: Colors.grey[600],
                size: isTablet ? 24 : 22,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 18 : 14,
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 12),

    // 🎛 SAME filter button (reuse existing method)
    _buildFilterButton(),
  ],
),


          // Active filter chip
          if (_selectedFilter != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildActiveFilterChip(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _selectedFilter != null
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _selectedFilter != null
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.filter_list_rounded,
          color: _selectedFilter != null ? Colors.white : Colors.grey[700],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
        itemBuilder: (_) => [
          _buildPopupMenuItem(_filterAll, Icons.all_inclusive),
          _buildPopupMenuItem(_filterToday, Icons.today),
          _buildPopupMenuItem(_filterYesterday, Icons.history),
          _buildPopupMenuItem(_filterThisMonth, Icons.calendar_month),
          _buildPopupMenuItem(_filterCustom, Icons.date_range),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon) {
    final isSelected = _selectedFilter == value ||
        (value == _filterAll && _selectedFilter == null);

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip() {
    String label = _selectedFilter!;
    if (_selectedFilter == _filterCustom && _customRange != null) {
      label =
          '${_formatDateShort(_customRange!.start)} - ${_formatDateShort(_customRange!.end)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_alt, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = null;
                _customRange = null;
              });
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildBody(ordersState state, bool isTablet) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading orders...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!, isTablet);
    }

    if (state.orders != null) {
      return state.orders!.when(
        data: (orders) {
          if (orders.isEmpty) {
            return _buildEmptyState(isTablet);
          }
          return _buildOrdersList(context, orders, isTablet);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString(), isTablet),
      );
    }

    return _buildEmptyState(isTablet);
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.blue.shade50],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: isTablet ? 100 : 80,
                color: Colors.green.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders will appear here once created',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            _buildModernButton(
              onPressed: () {
                ref.read(ordersViewModelProvider.notifier).getOrderList(
                      ref.read(adminloginViewModelProvider).companyId ?? '',
                    );
              },
              icon: Icons.refresh_rounded,
              label: 'Refresh',
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: isTablet ? 80 : 64,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildModernButton(
              onPressed: () {
                ref.read(ordersViewModelProvider.notifier).getOrderList(
                      ref.read(adminloginViewModelProvider).companyId ?? '',
                    );
              },
              icon: Icons.refresh_rounded,
              label: 'Try Again',
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isTablet ? 24 : 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 24,
            vertical: isTablet ? 18 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  bool _orderMatchesSearch(Order order, int orderNumber, String query) {
    if (query.isEmpty) return true;

    final numericQuery = query.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericQuery.isNotEmpty &&
        orderNumber.toString().contains(numericQuery)) {
      return true;
    }

    final shopName = (order.shopNamep ?? '').toLowerCase();
    if (shopName.contains(query)) return true;

    final empName = (order.empName ?? '').toLowerCase();
    if (empName.contains(query)) return true;

    final totalPrice = order.totalPrice.toString();
    if (totalPrice.contains(query)) return true;

    try {
      final date = DateTime.parse(order.orderDate);
      final formattedDate = _formatDateForSearch(date).toLowerCase();
      if (formattedDate.contains(query)) return true;
    } catch (e) {
      if (order.orderDate.toLowerCase().contains(query)) return true;
    }

    for (var item in order.items) {
      if (item.productName?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (item.quantity.toString().contains(query)) {
        return true;
      }
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
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.green.shade600,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.grey.shade800,
              ),
            ),
            child: child!,
          );
        },
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

    return '${months[date.month - 1]} ${date.day} ${date.year} ${date.day}/${date.month}/${date.year}';
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders, bool isTablet) {
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: isTablet ? 100 : 80,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ordersViewModelProvider.notifier).getOrderList(
              ref.read(adminloginViewModelProvider).companyId ?? '',
            );
      },
      color: Colors.green,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid
          int crossAxisCount = 1;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 2;
          }

          if (crossAxisCount == 1) {
            // List view for mobile
            return ListView.builder(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final orderNumber = orders.length - orders.indexOf(order);
                return _OrderCard(
                  order: order,
                  orderNumber: orderNumber,
                  isTablet: isTablet,
                  animationDelay: index * 50,
                );
              },
            );
          } else {
            // Grid view for tablet/desktop
            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final orderNumber = orders.length - orders.indexOf(order);
                return _OrderCard(
                  order: order,
                  orderNumber: orderNumber,
                  isTablet: true,
                  animationDelay: index * 50,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final Order order;
  final int orderNumber;
  final bool isTablet;
  final int animationDelay;

  const _OrderCard({
    required this.order,
    required this.orderNumber,
    required this.isTablet,
    this.animationDelay = 0,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(
                      order: widget.order,
                      orderNumber: widget.orderNumber,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Header with gradient badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.receipt_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Order',
                                    style: TextStyle(
                                      fontSize: widget.isTablet ? 14 : 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade100,
                                          Colors.green.shade200,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '#${widget.orderNumber}',
                                      style: TextStyle(
                                        fontSize: widget.isTablet ? 14 : 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(widget.order.orderDate),
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 13 : 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Divider with gradient
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey.shade200,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Order Info Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModernInfoChip(
                          Icons.person_rounded,
                          widget.order.empName ?? 'Unknown',
                          Colors.blue,
                        ),
                        _buildModernInfoChip(
                          Icons.store_rounded,
                          widget.order.shopNamep ?? 'Unknown',
                          Colors.purple,
                        ),
                        _buildModernInfoChip(
                          Icons.shopping_bag_rounded,
                          '${widget.order.items.length} items',
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Price with gradient background
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade50,
                            Colors.green.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 15 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${widget.order.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
         Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: widget.isTablet ? 13 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}