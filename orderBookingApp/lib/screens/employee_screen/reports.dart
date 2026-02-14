
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String _dateFilter = 'today'; // 'today', 'tomorrow', 'custom'

  // Sample order data
  final List<Order> _allOrders = [
    Order(
      id: '001',
      productName: 'Samsung Galaxy S23',
      customerName: 'Rahul Sharma',
      deliveryDate: DateTime.now(),
      status: 'Delivered',
      amount: 79999,
    ),
    Order(
      id: '002',
      productName: 'iPhone 15 Pro',
      customerName: 'Priya Patel',
      deliveryDate: DateTime.now(),
      status: 'In Transit',
      amount: 134900,
    ),
    Order(
      id: '003',
      productName: 'OnePlus 11',
      customerName: 'Amit Kumar',
      deliveryDate: DateTime.now().add(const Duration(days: 1)),
      status: 'Processing',
      amount: 56999,
    ),
    Order(
      id: '004',
      productName: 'MacBook Pro',
      customerName: 'Sneha Reddy',
      deliveryDate: DateTime.now().add(const Duration(days: 1)),
      status: 'Delivered',
      amount: 199900,
    ),
    Order(
      id: '005',
      productName: 'iPad Air',
      customerName: 'Vikram Singh',
      deliveryDate: DateTime.now().add(const Duration(days: 2)),
      status: 'Pending',
      amount: 59900,
    ),
  ];

  // Sample product data
  final List<Product> _products = [
    Product(
      name: 'Samsung Galaxy S23',
      category: 'Smartphones',
      totalOrders: 45,
      revenue: 3599955,
      stock: 23,
    ),
    Product(
      name: 'iPhone 15 Pro',
      category: 'Smartphones',
      totalOrders: 67,
      revenue: 9038300,
      stock: 12,
    ),
    Product(
      name: 'OnePlus 11',
      category: 'Smartphones',
      totalOrders: 38,
      revenue: 2165962,
      stock: 45,
    ),
    Product(
      name: 'MacBook Pro',
      category: 'Laptops',
      totalOrders: 28,
      revenue: 5597200,
      stock: 8,
    ),
    Product(
      name: 'iPad Air',
      category: 'Tablets',
      totalOrders: 52,
      revenue: 3114800,
      stock: 34,
    ),
  ];

  List<Order> get _filteredOrders {
    DateTime targetDate;
    
    switch (_dateFilter) {
      case 'today':
        targetDate = DateTime.now();
        break;
      case 'tomorrow':
        targetDate = DateTime.now().add(const Duration(days: 1));
        break;
      case 'custom':
        targetDate = _selectedDate;
        break;
      default:
        targetDate = DateTime.now();
    }

    return _allOrders.where((order) {
      return order.deliveryDate.year == targetDate.year &&
          order.deliveryDate.month == targetDate.month &&
          order.deliveryDate.day == targetDate.day;
    }).toList();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateFilter = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order & Product Reports'),
        elevation: 2,
      ),
      body: _selectedIndex == 0 ? _buildOrderReports() : _buildProductReports(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.delivery_dining),
            label: 'Order Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Product Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderReports() {
    return Column(
      children: [
        // Date Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Date Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip('Today', 'today'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip('Tomorrow', 'tomorrow'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      _dateFilter == 'custom'
                          ? DateFormat('dd MMM').format(_selectedDate)
                          : 'Custom',
                      'custom',
                      onTap: _selectDate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Summary Cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Orders',
                  _filteredOrders.length.toString(),
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Revenue',
                  '₹${_calculateTotalRevenue()}',
                  Icons.currency_rupee,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: _filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders for this date',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_filteredOrders[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductReports() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Product Performance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._products.map((product) => _buildProductCard(product)).toList(),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, {VoidCallback? onTap}) {
    final isSelected = _dateFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (onTap != null && value == 'custom') {
          onTap();
        } else {
          setState(() {
            _dateFilter = value;
          });
        }
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue.shade100,
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status) {
      case 'Delivered':
        statusColor = Colors.green;
        break;
      case 'In Transit':
        statusColor = Colors.orange;
        break;
      case 'Processing':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.productName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  order.customerName,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(order.deliveryDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  '₹${order.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.stock > 20
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      color: product.stock > 20 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProductStat(
                  'Total Orders',
                  product.totalOrders.toString(),
                  Icons.shopping_cart,
                ),
                _buildProductStat(
                  'Revenue',
                  '₹${(product.revenue / 100000).toStringAsFixed(1)}L',
                  Icons.currency_rupee,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _calculateTotalRevenue() {
    double total = _filteredOrders.fold(0, (sum, order) => sum + order.amount);
    if (total >= 100000) {
      return '${(total / 100000).toStringAsFixed(1)}L';
    }
    return total.toStringAsFixed(0);
  }
}

// Data Models
class Order {
  final String id;
  final String productName;
  final String customerName;
  final DateTime deliveryDate;
  final String status;
  final double amount;

  Order({
    required this.id,
    required this.productName,
    required this.customerName,
    required this.deliveryDate,
    required this.status,
    required this.amount,
  });

  get items => null;
}

class Product {
  final String name;
  final String category;
  final int totalOrders;
  final double revenue;
  final int stock;

  Product({
    required this.name,
    required this.category,
    required this.totalOrders,
    required this.revenue,
    required this.stock,
  });
}