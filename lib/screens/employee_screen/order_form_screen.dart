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

class _AppColors {
  static const orange = Color(0xFFFF8C42);
  static const white = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2D2D2D);
  static const textGray = Color(0xFF6B7280);
  static const iconGray = Color(0xFF9CA3AF);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const border = Color(0xFFE5E7EB);
  static const orangeLight = Color(0xFFFFF4E6);
  static const bgLight = Color(0xFFF9FAFB);
}

class _ProductVariant {
  final Product product;
  final String displayLabel;
  final String unit;
  final int subItemId;
  final int? quantityPerBox;

  _ProductVariant({
    required this.product,
    required this.displayLabel,
    required this.unit,
    required this.subItemId,
    required this.quantityPerBox,
  });

  String get uniqueKey =>
      '${product.productId}_${subItemId}';
}

class _TempOrderItem {
  final int productId;
  final String productName;
  final int subItemId;
  final String unit;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  _TempOrderItem({
    required this.productId,
    required this.productName,
    required this.subItemId,
    required this.unit,
    String initialPrice = '',
    String initialQty = '',
  })  : priceController = TextEditingController(text: initialPrice),
        quantityController = TextEditingController(text: initialQty);

  double get price => double.tryParse(priceController.text) ?? 0;
  int get quantity => int.tryParse(quantityController.text) ?? 0;
  double get totalPrice => price * quantity;

  bool get isValid => price > 0 && quantity > 0;

  void dispose() {
    priceController.dispose();
    quantityController.dispose();
  }
}

class OrderFormScreen extends ConsumerStatefulWidget {
  final ShopDetails shop;
  final VisitPayload visit;

  const OrderFormScreen({Key? key, required this.shop, required this.visit})
      : super(key: key);

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late VisitPayload _visit;

  // All selected order items (keyed by uniqueKey)
  final Map<String, _TempOrderItem> _orderItems = {};
  List<_ProductVariant> _allVariants = [];
  List<_ProductVariant> _filteredVariants = [];
  final Set<String> _selectedKeys = {};

  // Tab controller for two-step UI
  late TabController _tabController;
  bool _showProductList = true; // Step 1: select products, Step 2: set prices

  @override
  void initState() {
    super.initState();
    _visit = widget.visit;
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    });
    _searchController.addListener(() {
      _filterVariants(_searchController.text);
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<_ProductVariant> _buildVariants(List<Product> products) {
    return [
      for (final p in products)
        _ProductVariant(
          product: p,
          displayLabel: p.productName ?? '',
          unit: p.productUnit ?? '',
          subItemId: 0,
          quantityPerBox: p.quantityPerBox,
        ),
    ];
  }

  void _filterVariants(String query) {
    setState(() {
      _filteredVariants = query.isEmpty
          ? _allVariants
          : _allVariants
              .where((v) =>
                  v.displayLabel.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _toggleVariant(_ProductVariant v) {
    setState(() {
      if (_selectedKeys.contains(v.uniqueKey)) {
        _selectedKeys.remove(v.uniqueKey);
        _orderItems[v.uniqueKey]?.dispose();
        _orderItems.remove(v.uniqueKey);
      } else {
        _selectedKeys.add(v.uniqueKey);
        _orderItems[v.uniqueKey] = _TempOrderItem(
          productId: v.product.productId!,
          productName: v.displayLabel,
          subItemId: v.subItemId,
          unit: v.unit,
        );
      }
    });
  }

  void _removeItem(String key) {
    setState(() {
      _selectedKeys.remove(key);
      _orderItems[key]?.dispose();
      _orderItems.remove(key);
    });
  }

  double _calculateTotal() =>
      _orderItems.values.fold(0.0, (s, i) => s + i.totalPrice);

  void _goToStep2() {
    if (_selectedKeys.isEmpty) {
      _showError('Please select at least one product');
      return;
    }
    setState(() => _showProductList = false);
    _tabController.animateTo(1);
  }

  void _goToStep1() {
    setState(() => _showProductList = true);
    _tabController.animateTo(0);
  }

  Future<void> _submitOrder() async {
    if (_orderItems.isEmpty) {
      _showError('Please select at least one product');
      return;
    }
    // Validate all items have price and quantity
    for (final item in _orderItems.values) {
      if (!item.isValid) {
        _showError(
            'Please set price and quantity for all items');
        return;
      }
    }

    final orderItems = _orderItems.values
        .map((item) => OrderItem(
              productName: item.productName,
              productId: item.productId,
              subItemId: item.subItemId,
              productUnit: item.unit,
              price: item.price,
              quantity: item.quantity,
            ))
        .toList();

    final now = DateTime.now().toLocal().toIso8601String();
    final order = Order(
      localOrderId: const Uuid().v4(),
      ownerName: widget.shop.ownerName,
      mobileNo: widget.shop.mobileNo,
      shopNamep: widget.shop.shopName,
      employeeId: ref.read(adminloginViewModelProvider).userId,
      shopId: widget.shop.shopId ?? 0,
      orderDate: now,
      items: orderItems,
      companyId: ref.read(adminloginViewModelProvider).companyId,
    );

    await ref.read(ordersViewModelProvider.notifier).addOrderLineItem(order);

    setState(() {
      _visit = VisitPayload(
        localId: _visit.localId,
        shopId: _visit.shopId,
        employeeId: _visit.employeeId,
        lat: _visit.lat,
        lng: _visit.lng,
        accuracy: _visit.accuracy,
        capturedAt: _visit.capturedAt,
        punchIn: _visit.capturedAt!.toIso8601String(),
        punchOut: now,
      );
    });

    await ref.read(visitViewModelProvider.notifier).addVisit(_visit);
    await ref.read(ordersViewModelProvider.notifier).countTodayOrders();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        shopName: widget.shop.shopName ?? '',
        itemCount: order.items.length,
        total: order.totalPrice,
        onDone: () {
          Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => const MainNavigationScreen(initialIndex: 1)),
            (route) => false,
          );
        },
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _AppColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    return Scaffold(
      backgroundColor: _AppColors.white,
      appBar: AppBar(
        backgroundColor: _AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _AppColors.textDark),
          onPressed: _showProductList
              ? () => Navigator.pop(context)
              : _goToStep1,
        ),
        title: const Text(
          'Create Order',
          style: TextStyle(
              color: _AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: _StepIndicator(
            currentStep: _showProductList ? 0 : 1,
          ),
        ),
      ),
      body: state.isLoading
          ? const _Loader()
          : state.productList!.when(
              data: (products) {
                if (_allVariants.isEmpty) {
                  _allVariants = _buildVariants(products);
                  _filteredVariants = _allVariants;
                }
                return _showProductList
                    ? _buildStep1()
                    : _buildStep2();
              },
              loading: () => const _Loader(),
              error: (err, _) => _buildError(err),
            ),
    );
  }

  // ── Step 1: Select Products ────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      children: [
        // Shop header + search
        Container(
          color: _AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // _ShopHeader(shop: widget.shop),
              // const SizedBox(height: 2),
              _buildSearchBar(),
            ],
          ),
        ),
        const Divider(height: 1, color: _AppColors.border),

        // Product list
        Expanded(
          child: _filteredVariants.isEmpty
              ? Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(color: _AppColors.textGray, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _filteredVariants.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: _AppColors.border),
                  itemBuilder: (_, i) {
                    final v = _filteredVariants[i];
                    final isSelected = _selectedKeys.contains(v.uniqueKey);
                    return _ProductSelectRow(
                      variant: v,
                      isSelected: isSelected,
                      onTap: () => _toggleVariant(v),
                    );
                  },
                ),
        ),

        // Bottom bar
        _buildStep1BottomBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 14, color: _AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Search product...',
        hintStyle: const TextStyle(color: _AppColors.iconGray, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded,
            size: 20, color: _AppColors.iconGray),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _searchController,
          builder: (_, value, __) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: _AppColors.iconGray),
                  onPressed: () => _searchController.clear(),
                  splashRadius: 16,
                )
              : const SizedBox.shrink(),
        ),
        filled: true,
        fillColor: _AppColors.bgLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _AppColors.orange, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildStep1BottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: _AppColors.white,
        border: Border(top: BorderSide(color: _AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Selected',
                      style: TextStyle(
                          fontSize: 12, color: _AppColors.textGray)),
                  Text(
                    '${_selectedKeys.length} product${_selectedKeys.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _goToStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Next'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),


      ),
    );
  }

  // ── Step 2: Set Price & Quantity ───────────────────────────────────────────

  Widget _buildStep2() {
    final items = _orderItems.values.toList();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _ShopHeader(shop: widget.shop),
                // const SizedBox(height: 20),

                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Set Price & Quantity',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.textDark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${items.length}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _AppColors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter price and quantity for each selected product',
                  style: TextStyle(fontSize: 13, color: _AppColors.textGray),
                ),
                const SizedBox(height: 16),

                // Column headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 5,
                        child: Text('Product',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _AppColors.textGray)),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: Text('Price per box',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _AppColors.textGray)),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text('Box Qty',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _AppColors.textGray)),
                      ),
                      SizedBox(width: 8),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: _AppColors.border),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: _AppColors.border),
                  itemBuilder: (_, i) => _EditableOrderRow(
                    item: items[i],
                    onRemove: () => _removeItem(items[i].productId
                        .toString() + '_' + items[i].subItemId.toString()),
                    onChanged: () => setState(() {}),
                  ),
                ),

                const Divider(height: 1, color: _AppColors.border),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        if (!isKeyboardOpen) _buildStep2BottomBar(),
      ],
    );
  }

  Widget _buildStep2BottomBar() {
    final total = _calculateTotal();
    final isSubmitDisabled = _orderItems.isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: _AppColors.white,
        border: Border(top: BorderSide(color: _AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 12, color: _AppColors.textGray)),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isSubmitDisabled ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: const Text('Submit Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: _AppColors.iconGray.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Failed to load products',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.textDark)),
            const SizedBox(height: 8),
            Text(error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: _AppColors.textGray)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref
                  .read(productViewModelProvider.notifier)
                  .fetchProductList(
                      ref.read(adminloginViewModelProvider).companyId ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Retry',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    for (final item in _orderItems.values) {
      item.dispose();
    }
    super.dispose();
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          _StepChip(
              number: 1,
              label: 'Select Products',
              isActive: currentStep == 0,
              isDone: currentStep > 0),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: currentStep > 0 ? _AppColors.orange : _AppColors.border,
            ),
          ),
          _StepChip(
              number: 2,
              label: 'Set Price & Qty',
              isActive: currentStep == 1,
              isDone: false),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepChip(
      {required this.number,
      required this.label,
      required this.isActive,
      required this.isDone});

  @override
  Widget build(BuildContext context) {
    final color = (isActive || isDone) ? _AppColors.orange : _AppColors.iconGray;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: (isActive || isDone) ? _AppColors.orange : _AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : Text(
                    '$number',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: (isActive || isDone)
                            ? Colors.white
                            : _AppColors.textGray),
                  ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color),
        ),
      ],
    );
  }
}

// ── Product Select Row (Step 1) ───────────────────────────────────────────────

class _ProductSelectRow extends StatelessWidget {
  final _ProductVariant variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductSelectRow(
      {required this.variant,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isSelected ? _AppColors.orangeLight : _AppColors.white,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? _AppColors.orange : Colors.transparent,
                border: Border.all(
                    color:
                        isSelected ? _AppColors.orange : _AppColors.iconGray,
                    width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                variant.displayLabel,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: _AppColors.textDark),
              ),
            ),
            if (variant.quantityPerBox != null &&
                variant.quantityPerBox! > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _AppColors.border),
                ),
                child: Text(
                  '${variant.quantityPerBox} per box',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.textGray,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Editable Order Row (Step 2) ───────────────────────────────────────────────

class _EditableOrderRow extends StatelessWidget {
  final _TempOrderItem item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _EditableOrderRow(
      {required this.item,
      required this.onRemove,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product name
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.textDark),
                ),
                if (item.price > 0 && item.quantity > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '= ₹${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: _AppColors.green,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Price field
          SizedBox(
            width: 80,
            child: _CompactInputField(
              controller: item.priceController,
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 8),

          // Quantity field
          SizedBox(
            width: 70,
            child: _CompactInputField(
              controller: item.quantityController,
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 8),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.delete_outline,
                size: 18, color: _AppColors.red),
          ),
        ],
      ),
    );
  }
}

class _CompactInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;

  const _CompactInputField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: _AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: _AppColors.iconGray, fontSize: 13),
        filled: true,
        fillColor: _AppColors.bgLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: _AppColors.orange, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        isDense: true,
      ),
    );
  }
}

// ── Shared Sub-widgets ────────────────────────────────────────────────────────

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(
            color: _AppColors.orange, strokeWidth: 2.5),
      );
}

class _ShopHeader extends StatelessWidget {
  final ShopDetails shop;
  const _ShopHeader({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _AppColors.orangeLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.store_rounded,
              color: _AppColors.orange, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shop.shopName ?? '',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.textDark),
              ),
              if ((shop.address ?? '').isNotEmpty)
                Text(
                  shop.address ?? '',
                  style: const TextStyle(
                      fontSize: 13, color: _AppColors.textGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String shopName;
  final int itemCount;
  final double total;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.shopName,
    required this.itemCount,
    required this.total,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _AppColors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle,
                color: _AppColors.green, size: 44),
          ),
          const SizedBox(height: 16),
          const Text('Order Submitted',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.textDark)),
          const SizedBox(height: 6),
          Text(shopName,
              style:
                  const TextStyle(fontSize: 14, color: _AppColors.textGray),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _AppColors.border),
            ),
            child: Column(children: [
              _row('Items', '$itemCount'),
              const SizedBox(height: 8),
              _row('Total', '₹${total.toStringAsFixed(2)}',
                  valueStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _AppColors.green)),
            ]),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: _AppColors.textGray, fontSize: 14)),
        Text(value,
            style: valueStyle ??
                const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _AppColors.textDark,
                    fontSize: 14)),
      ],
    );
  }
}
