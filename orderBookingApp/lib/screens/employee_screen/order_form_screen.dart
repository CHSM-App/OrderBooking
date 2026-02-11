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

// Minimal Theme Colors
class MinimalTheme {
  static const primaryOrange = Color(0xFFFF8C42);
  static const backgroundGray = Color(0xFFF5F5F5);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2D2D2D);
  static const textGray = Color(0xFF6B7280);
  static const iconGray = Color(0xFF9CA3AF);
  static const successGreen = Color(0xFF10B981);
  static const errorRed = Color(0xFFEF4444);
}

class OrderFormScreen extends ConsumerStatefulWidget {
  final ShopDetails shop;
  final VisitPayload visit;

  const OrderFormScreen({Key? key, required this.shop, required this.visit})
      : super(key: key);

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  Product? _selectedProduct;
  ProductSubType? _selectedSubType;
  final TextEditingController _quantityController = TextEditingController();
  late VisitPayload _visit;
  final List<_TempOrderItem> _orderItems = [];

  @override
  void initState() {
    super.initState();
    _visit = widget.visit;
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(
          ref.read(adminloginViewModelProvider).companyId ?? "");
    });
  }

  String formatForApi(DateTime dt) => VisitPayload.formatForApi(dt);

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
      final existingIndex = _orderItems.indexWhere(
        (item) =>
            item.productId == _selectedProduct!.productId &&
            item.subItemId == _selectedSubType!.subItemId,
      );

      if (existingIndex >= 0) {
        _orderItems[existingIndex] = _TempOrderItem(
          productId: _orderItems[existingIndex].productId,
          productName: _orderItems[existingIndex].productName,
          subItemId: _orderItems[existingIndex].subItemId,
          unit: _orderItems[existingIndex].unit,
          price: _orderItems[existingIndex].price,
          quantity: _orderItems[existingIndex].quantity + quantity,
        );
      } else {
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

      _selectedProduct = null;
      _selectedSubType = null;
      _quantityController.clear();
    });

    _showSuccess('Product added');
  }

  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  void _submitOrder() {
    if (_orderItems.isEmpty) {
      _showError('Add at least one product');
      return;
    }

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
        punchIn: formatForApi(_visit.capturedAt ?? DateTime.now()),
        punchOut: formatForApi(DateTime.now().toLocal()),
      );
    });
    ref.read(visitViewModelProvider.notifier).addVisit(_visit);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MinimalTheme.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: MinimalTheme.successGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Submitted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MinimalTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.shop.shopName ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: MinimalTheme.textGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalTheme.backgroundGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(color: MinimalTheme.textGray),
                      ),
                      Text(
                        '${order.items.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(color: MinimalTheme.textGray),
                      ),
                      Text(
                        '₹${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MinimalTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainNavigationScreen(
                      initialIndex: 1,
                    ),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MinimalTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MinimalTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MinimalTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: MinimalTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: MinimalTheme.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MinimalTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Order',
          style: TextStyle(
            color: MinimalTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: MinimalTheme.primaryOrange,
                strokeWidth: 2.5,
              ),
            )
          : state.productList!.when(
              data: (products) => _buildOrderForm(products),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: MinimalTheme.primaryOrange,
                  strokeWidth: 2.5,
                ),
              ),
              error: (error, _) => _buildErrorView(error),
            ),
    );
  }

  Widget _buildOrderForm(List<Product> products) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    return Column(
      children: [
        _buildShopHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset + 24),
            child: Column(
              children: [
                _buildAddProductForm(products),
                if (_orderItems.isNotEmpty) _buildOrderItemsList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        if (_orderItems.isNotEmpty && !isKeyboardOpen) _buildBottomBar(),
      ],
    );
  }

  Widget _buildShopHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: MinimalTheme.primaryOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shop.shopName ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MinimalTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.shop.address ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: MinimalTheme.textGray,
                  ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Product',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MinimalTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Product Dropdown
          const Text(
            'Product',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MinimalTheme.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
              color: MinimalTheme.cardWhite,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Product>(
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Select product',
                    style: TextStyle(
                      color: MinimalTheme.iconGray,
                      fontSize: 14,
                    ),
                  ),
                ),
                value: _selectedProduct,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                items: products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(
                      product.productName ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: MinimalTheme.textDark,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                    _selectedSubType = null;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: MinimalTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedProduct == null
                              ? Colors.grey[100]!
                              : Colors.grey[200]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedProduct == null
                            ? Colors.grey[50]
                            : MinimalTheme.cardWhite,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProductSubType>(
                          isExpanded: true,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Select unit',
                              style: TextStyle(
                                color: MinimalTheme.iconGray,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          value: _selectedSubType,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          items: _selectedProduct?.subtypes?.map((subtype) {
                            return DropdownMenuItem(
                              value: subtype,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatUnit(
                                      subtype.availableUnit,
                                      subtype.measuringUnit,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: MinimalTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    '₹${subtype.price}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: MinimalTheme.primaryOrange,
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
              const SizedBox(width: 12),

              // Quantity Input
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: MinimalTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: const TextStyle(
                          color: MinimalTheme.iconGray,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: MinimalTheme.primaryOrange,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: MinimalTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addToOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: MinimalTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Add to Order'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
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
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MinimalTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_orderItems.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MinimalTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: MinimalTheme.primaryOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MinimalTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity} × ${item.unit}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: MinimalTheme.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: MinimalTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _removeItem(index),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: MinimalTheme.errorRed,
                        ),
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
        color: MinimalTheme.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: MinimalTheme.textGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MinimalTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MinimalTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Submit Order'),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: MinimalTheme.iconGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MinimalTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: MinimalTheme.textGray,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(productViewModelProvider.notifier).fetchProductList(
                    ref.read(adminloginViewModelProvider).companyId ?? "");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MinimalTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Retry'),
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
