import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/domain/models/order_item.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/main_navigation_screen.dart';
import 'package:uuid/uuid.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  final ShopDetails shop;
  final VisitPayload visit;

  const OrderFormScreen({Key? key, required this.shop, required this.visit})
    : super(key: key);

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  // Form state
  Product? _selectedProduct;
  ProductSubType? _selectedSubType;
  final TextEditingController _quantityController = TextEditingController();
  late VisitPayload _visit;

  // Order items - temporary list to build the order
  final List<_TempOrderItem> _orderItems = [];

  @override
  void initState() {
    super.initState();
    _visit = widget.visit;
    // Fetch products
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).companyId??"");
    });
  }

  String formatForApi(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');

  return '${dt.year}-'
         '${two(dt.month)}-'
         '${two(dt.day)} '
         '${two(dt.hour)}:'
         '${two(dt.minute)}:'
         '${two(dt.second)}';
}


  String _formatUnit(double? availableUnit, String? measuringUnit) {
    if (availableUnit == null || measuringUnit == null) return '';

    String format(double value) {
      return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
    }

    switch (measuringUnit.toLowerCase()) {
      case 'liter':
        if (availableUnit >= 1) {
          return '${format(availableUnit)} L';
        } else {
          return '${(availableUnit * 1000).toStringAsFixed(0)} ml';
        }
      case 'kilogram':
        if (availableUnit >= 1) {
          return '${format(availableUnit)} kg';
        } else {
          return '${(availableUnit * 1000).toStringAsFixed(0)} g';
        }
      default:
        return '${format(availableUnit)} $measuringUnit';
    }
  }

  void _addToOrder() {
    if (_selectedProduct == null) {
      _showError('Please select a product');
      return;
    }

    if (_selectedSubType == null) {
      _showError('Please select a unit');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showError('Please enter a valid quantity');
      return;
    }

    setState(() {
      // Check if same product and subtype already exists
      final existingIndex = _orderItems.indexWhere(
        (item) =>
            item.productId == _selectedProduct!.productId &&
            item.subItemId == _selectedSubType!.subItemId,
      );

      if (existingIndex >= 0) {
        // Update existing item quantity
        _orderItems[existingIndex] = _TempOrderItem(
          productId: _orderItems[existingIndex].productId,
          productName: _orderItems[existingIndex].productName,
          subItemId: _orderItems[existingIndex].subItemId,
          unit: _orderItems[existingIndex].unit,
          price: _orderItems[existingIndex].price,
          quantity: _orderItems[existingIndex].quantity + quantity,
        );
      } else {
        // Add new item
        _orderItems.add(
          _TempOrderItem(
            productId: _selectedProduct!.productId!,
            productName: _selectedProduct!.productName!,
            subItemId: _selectedSubType!.subItemId!,
            unit: _formatUnit(
              _selectedSubType!.availableUnit,
              _selectedSubType!.measuringUnit,
            ),
            price: _selectedSubType!.price!,
            quantity: quantity,
          ),
        );
      }

      // Reset form
      _selectedProduct = null;
      _selectedSubType = null;
      _quantityController.clear();
    });

    _showSuccess('Product added to order');
  }

  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  void _submitOrder() {
    if (_orderItems.isEmpty) {
      _showError('Please add at least one product to the order');
      return;
    }

    // Convert temporary items to OrderItem objects
    final List<OrderItem> orderItems = _orderItems.map((item) {
      return OrderItem(
        productName: item.productName,
        productId: item.productId,
        subItemId: item.subItemId,
        productUnit: item.unit,
        price: item.price,
        quantity: item.quantity,
      );
    }).toList();

    // Create Order object
    final Order order = Order(
      localOrderId: const Uuid().v4(),
      shopNamep: widget.shop.shopName,
      employeeId: ref.read(adminloginViewModelProvider).userId,
      shopId: widget.shop.shopId ?? 0,
      orderDate: DateTime.now().toIso8601String(),
      items: orderItems,
      companyId: ref.read(adminloginViewModelProvider).companyId,
    );

    ref.read(ordersViewModelProvider.notifier).addOrderLineItem(order);

    setState(() {
      _visit = VisitPayload(
        localId: _visit.localId,
        shopId: _visit.shopId,
        employeeId: _visit.employeeId,
        lat: _visit.lat,
        lng: _visit.lng,
        accuracy: _visit.accuracy,
        capturedAt: _visit.capturedAt,
        punchIn: formatForApi(_visit.capturedAt),
        punchOut: formatForApi(DateTime.now().toLocal()),
      );
    });

    ref.read(visitViewModelProvider.notifier).addVisit(_visit);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Submitted'),
        content: Text(
          'Order for ${widget.shop.shopName} submitted successfully!\n\n'
          '${order.items.length} products\n'
          'Total: ₹${order.totalPrice.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(
                    initialIndex: 1,
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method to pretty print JSON
  String _prettyPrintJson(Map<String, dynamic> json, {int indent = 0}) {
    final buffer = StringBuffer();
    final spacing = '  ' * indent;

    buffer.writeln('{');
    final entries = json.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;

      buffer.write('$spacing  "${entry.key}": ');

      if (entry.value is List) {
        buffer.writeln('[');
        final list = entry.value as List;
        for (int j = 0; j < list.length; j++) {
          final item = list[j];
          final isLastItem = j == list.length - 1;

          if (item is Map<String, dynamic>) {
            buffer.write('$spacing    ');
            buffer.write(_prettyPrintJson(item, indent: indent + 2).trim());
            if (!isLastItem) buffer.write(',');
            buffer.writeln();
          }
        }
        buffer.write('$spacing  ]${isLast ? '' : ','}');
      } else if (entry.value is String) {
        buffer.write('"${entry.value}"${isLast ? '' : ','}');
      } else {
        buffer.write('${entry.value}${isLast ? '' : ','}');
      }
      buffer.writeln();
    }
    buffer.write('$spacing}');

    return buffer.toString();
  }

  double _calculateTotal() {
    return _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  IconData _getProductIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'beverage':
        return Icons.local_drink;
      case 'grocery':
        return Icons.shopping_bag;
      case 'ice cream':
        return Icons.icecream;
      case 'bakery & snacks':
        return Icons.cookie;
      case 'dairy':
        return Icons.emoji_food_beverage;
      case 'personal & home care':
        return Icons.cleaning_services;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Create Order'), elevation: 0),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.productList!.when(
              data: (products) => _buildOrderForm(products),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorView(error),
            ),
    );
  }

  Widget _buildOrderForm(List<Product> products) {
    return Column(
      children: [
        // Shop Header
        _buildShopHeader(),

        // Form and Items List
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Add Product Form
                _buildAddProductForm(products),

                // Order Items List
                if (_orderItems.isNotEmpty) _buildOrderItemsList(),
              ],
            ),
          ),
        ),

        // Bottom Summary and Submit
        if (_orderItems.isNotEmpty) _buildBottomBar(),
      ],
    );
  }

  Widget _buildShopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(bottom: BorderSide(color: Colors.green[100]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shop.shopName ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.shop.address ?? "",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductForm(List<Product> products) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Add Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Product Dropdown
          const Text(
            'Select Product',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Product>(
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Choose a product'),
                ),
                value: _selectedProduct,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                items: products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Row(
                      children: [
                        Icon(
                          _getProductIcon(product.productType),
                          size: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            product.productName ?? '',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.productType ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                    _selectedSubType = null; // Reset unit selection
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Unit and Quantity Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit Dropdown
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit & Price',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedProduct == null
                              ? Colors.grey[200]!
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedProduct == null
                            ? Colors.grey[50]
                            : Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProductSubType>(
                          isExpanded: true,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Select unit'),
                          ),
                          value: _selectedSubType,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          items: _selectedProduct?.subtypes?.map((subtype) {
                            return DropdownMenuItem(
                              value: subtype,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatUnit(
                                      subtype.availableUnit,
                                      subtype.measuringUnit,
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '₹${subtype.price}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _selectedProduct == null
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedSubType = value;
                                  });
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Quantity Input
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Add Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _addToOrder,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add to Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Order Items',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_orderItems.length} items',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _orderItems.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = _orderItems[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} × ${item.unit} @ ₹${item.price}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        onPressed: () => _removeItem(index),
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _submitOrder,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Submit and Punch Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).companyId??"");
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

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}

// Temporary helper class to store items before converting to OrderItem
class _TempOrderItem {
  final int productId;
  final String productName;
  final int subItemId;
  final String unit;
  final double price;
  final int quantity;

  _TempOrderItem({
    required this.productId,
    required this.productName,
    required this.subItemId,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}
