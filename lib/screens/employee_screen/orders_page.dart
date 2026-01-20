import 'package:flutter/material.dart';
import 'package:order_booking_app/domain/models/models.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _allOrders = [];
  List<Order> _todayOrders = [];
  List<Order> _weekOrders = [];
  List<Order> _monthOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  void _loadOrders() {
    final sampleShop = Shop(
      id: '1',
      shopName: 'Green Juice Corner',
      address: 'Shop 12, Market Street, Mumbai',
      latitude: 19.0760,
      longitude: 72.8777,
    );

    final sampleProducts = [
      Product(id: '1', name: 'Orange Juice', unit: 'Liter', price: 120),
      Product(id: '2', name: 'Apple Juice', unit: 'Liter', price: 150),
      Product(id: '3', name: 'Mango Juice', unit: 'Liter', price: 140),
    ];

    _allOrders = [
      Order(
        id: 'ORD001',
        shop: sampleShop,
        items: [
          OrderItem(product: sampleProducts[0], quantity: 5),
          OrderItem(product: sampleProducts[1], quantity: 3),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Delivered',
        punchInTime: DateTime.now().subtract(const Duration(hours: 3)),
        punchOutTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Order(
        id: 'ORD002',
        shop: sampleShop,
        items: [
          OrderItem(product: sampleProducts[2], quantity: 4),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'Delivered',
      ),
      Order(
        id: 'ORD003',
        shop: sampleShop,
        items: [
          OrderItem(product: sampleProducts[0], quantity: 10),
          OrderItem(product: sampleProducts[1], quantity: 8),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Delivered',
      ),
      Order(
        id: 'ORD004',
        shop: sampleShop,
        items: [
          OrderItem(product: sampleProducts[2], quantity: 6),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Delivered',
      ),
    ];

    _todayOrders = _allOrders.where((order) {
      final diff = DateTime.now().difference(order.createdAt);
      return diff.inHours < 24;
    }).toList();

    _weekOrders = _allOrders.where((order) {
      final diff = DateTime.now().difference(order.createdAt);
      return diff.inDays < 7;
    }).toList();

    _monthOrders = _allOrders.where((order) {
      final diff = DateTime.now().difference(order.createdAt);
      return diff.inDays < 30;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
        Material(
  color: Colors.yellow, // TAB BAR BACKGROUND
  elevation: 2,
  child: TabBar(
    controller: _tabController,
    isScrollable: true,
    indicatorColor: Colors.black,
    labelColor: Colors.black,
    unselectedLabelColor: Colors.black54,
    tabs: [
      Tab(text: 'All (${_allOrders.length})'),
      Tab(text: 'Today (${_todayOrders.length})'),
      Tab(text: 'This Week (${_weekOrders.length})'),
      Tab(text: 'This Month (${_monthOrders.length})'),
    ],
  ),
),


          // TAB VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderList(
                    orders: _allOrders,
                    formatDate: _formatDate,
                    getStatusColor: _getStatusColor),
                _OrderList(
                    orders: _todayOrders,
                    formatDate: _formatDate,
                    getStatusColor: _getStatusColor),
                _OrderList(
                    orders: _weekOrders,
                    formatDate: _formatDate,
                    getStatusColor: _getStatusColor),
                _OrderList(
                    orders: _monthOrders,
                    formatDate: _formatDate,
                    getStatusColor: _getStatusColor),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final String Function(DateTime) formatDate;
  final Color Function(String) getStatusColor;

  const _OrderList({
    required this.orders,
    required this.formatDate,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(
          order: order,
          formatDate: formatDate,
          getStatusColor: getStatusColor,
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final String Function(DateTime) formatDate;
  final Color Function(String) getStatusColor;

  const _OrderCard({
    required this.order,
    required this.formatDate,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
       color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _OrderDetailsSheet(order: order),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Shop
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.shop.shopName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Items Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${order.items.length} items',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
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
}


class _OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailsSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Order ${order.id}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Shop Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shop.shopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shop.address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_drink,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item.quantity} ${item.product.unit} × ₹${item.product.price}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const Divider(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
