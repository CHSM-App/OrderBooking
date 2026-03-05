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
}

class _ProductVariant {
  final Product product;
  final ProductSubType subType;
  final String displayLabel;

  _ProductVariant({
    required this.product,
    required this.subType,
    required this.displayLabel,
  });
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
  _ProductVariant? _selectedVariant;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  late VisitPayload _visit;
  final List<_TempOrderItem> _orderItems = [];

  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  List<_ProductVariant> _allVariants = [];
  List<_ProductVariant> _filteredVariants = [];

  @override
  void initState() {
    super.initState();
    _visit = widget.visit;
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatUnit(double? value, String? unit) {
    if (value == null || unit == null) return '';
    String fmt(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toString();
    switch (unit.toLowerCase()) {
      case 'liter':
        return value >= 1 ? '${fmt(value)} L' : '${(value * 1000).toStringAsFixed(0)} ml';
      case 'kilogram':
        return value >= 1 ? '${fmt(value)} kg' : '${(value * 1000).toStringAsFixed(0)} g';
      default:
        return '${fmt(value)} $unit';
    }
  }

  List<_ProductVariant> _buildVariants(List<Product> products) {
    return [
      for (final p in products)
        for (final s in p.subtypes ?? [])
          _ProductVariant(
            product: p,
            subType: s,
            displayLabel:
                '${p.productName ?? ''} ${_formatUnit(s.availableUnit, s.measuringUnit)}'.trim(),
          ),
    ];
  }

  // ── Overlay dropdown ───────────────────────────────────────────────────────

  void _openDropdown(List<_ProductVariant> variants) {
    if (_isDropdownOpen) return;
    _allVariants = variants;
    _filteredVariants = variants;
    _isDropdownOpen = true;
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
    _searchFocusNode.unfocus();
  }

  void _filterVariants(String query) {
    if (_overlayEntry == null) return;
    _filteredVariants = query.isEmpty
        ? _allVariants
        : _allVariants
            .where((v) => v.displayLabel.toLowerCase().contains(query.toLowerCase()))
            .toList();
    _overlayEntry!.markNeedsBuild();
  }

  void _selectVariant(_ProductVariant v) {
    setState(() {
      _selectedVariant = v;
      _searchController.text = v.displayLabel;
    });
    _closeDropdown();
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 54),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Colors.black12,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    color: _AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _AppColors.border),
                  ),
                  child: _filteredVariants.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No products found',
                            style: TextStyle(color: _AppColors.textGray, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shrinkWrap: true,
                          itemCount: _filteredVariants.length,
                          itemBuilder: (_, i) {
                            final v = _filteredVariants[i];
                            final selected =
                                _selectedVariant?.displayLabel == v.displayLabel;
                            return InkWell(
                              onTap: () => _selectVariant(v),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                color: selected
                                    ? _AppColors.orangeLight
                                    : Colors.transparent,
                                child: Text(
                                  v.displayLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _AppColors.textDark,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _addToOrder() {
    if (_selectedVariant == null) {
      _showError('Please select a product');
      return;
    }
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showError('Please enter a valid price');
      return;
    }
    final qty = int.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) {
      _showError('Please enter a valid quantity');
      return;
    }

    setState(() {
      final idx = _orderItems.indexWhere(
        (item) =>
            item.productId == _selectedVariant!.product.productId &&
            item.subItemId == _selectedVariant!.subType.subItemId,
      );

      if (idx >= 0) {
        final existing = _orderItems[idx];
        _orderItems[idx] = _TempOrderItem(
          productId: existing.productId,
          productName: existing.productName,
          subItemId: existing.subItemId,
          unit: existing.unit,
          price: price,
          quantity: existing.quantity + qty,
        );
      } else {
        _orderItems.add(_TempOrderItem(
          productId: _selectedVariant!.product.productId!,
          productName: _selectedVariant!.displayLabel,
          subItemId: _selectedVariant!.subType.subItemId!,
          unit: _formatUnit(
            _selectedVariant!.subType.availableUnit,
            _selectedVariant!.subType.measuringUnit,
          ),
          price: price,
          quantity: qty,
        ));
      }

      _selectedVariant = null;
      _searchController.clear();
      _priceController.clear();
      _quantityController.clear();
    });
  }

  void _removeItem(int index) => setState(() => _orderItems.removeAt(index));

  Future<void> _submitOrder() async {
    if (_orderItems.isEmpty) {
      _showError('Add at least one product');
      return;
    }

    final orderItems = _orderItems
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

  double _calculateTotal() => _orderItems.fold(0.0, (s, i) => s + i.totalPrice);

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Order',
          style: TextStyle(
              color: _AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: state.isLoading
          ? const _Loader()
          : state.productList!.when(
              data: (products) => _buildBody(products),
              loading: () => const _Loader(),
              error: (err, _) => _buildError(err),
            ),
    );
  }

  Widget _buildBody(List<Product> products) {
    final allVariants = _buildVariants(products);
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
                _ShopHeader(shop: widget.shop),
                const SizedBox(height: 20),
                _buildAddForm(allVariants),
                if (_orderItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildItemsList(),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        if (_orderItems.isNotEmpty && !isKeyboardOpen) _buildBottomBar(),
      ],
    );
  }

  // ── Add product form ───────────────────────────────────────────────────────

  Widget _buildAddForm(List<_ProductVariant> allVariants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Product',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _AppColors.textDark),
        ),
        const SizedBox(height: 14),

        _fieldLabel('Product & Unit'),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: _layerLink,
          child: _SearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onTap: () => _openDropdown(allVariants),
            onChanged: (q) {
              if (!_isDropdownOpen) _openDropdown(allVariants);
              _filterVariants(q);
            },
            onClear: () {
              _searchController.clear();
              _selectedVariant = null;
              _closeDropdown();
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 14),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Price (₹)'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _priceController,
                    hint: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Quantity (box)'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _quantityController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addToOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            child: const Text('Add to Order'),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _AppColors.textGray),
      );

  // ── Order items list ───────────────────────────────────────────────────────

  Widget _buildItemsList() {
    return Column(
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
                  color: _AppColors.textDark),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _AppColors.orangeLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_orderItems.length}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.orange),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orderItems.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: _AppColors.border),
          itemBuilder: (_, i) => _OrderItemRow(
            item: _orderItems[i],
            onRemove: () => _removeItem(i),
          ),
        ),
      ],
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
                    '₹${_calculateTotal().toStringAsFixed(2)}',
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
                onPressed: _submitOrder,
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

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 56,
                color: _AppColors.iconGray.withOpacity(0.5)),
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
    _closeDropdown();
    _searchController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onTap,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTap: onTap,
      onChanged: onChanged,
      style:
          const TextStyle(fontSize: 14, color: _AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Search product...',
        hintStyle:
            const TextStyle(color: _AppColors.iconGray, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded,
            size: 20, color: _AppColors.iconGray),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: _AppColors.iconGray),
                  onPressed: onClear,
                  splashRadius: 16,
                )
              : const SizedBox.shrink(),
        ),
        filled: true,
        fillColor: _AppColors.white,
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style:
          const TextStyle(fontSize: 14, color: _AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _AppColors.iconGray),
        filled: true,
        fillColor: _AppColors.white,
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final _TempOrderItem item;
  final VoidCallback onRemove;

  const _OrderItemRow({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} × ₹${item.price}',
                  style: const TextStyle(
                      fontSize: 12, color: _AppColors.textGray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${item.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _AppColors.textDark),
          ),
          const SizedBox(width: 12),
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
              style: const TextStyle(
                  fontSize: 14, color: _AppColors.textGray),
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

// ── Model ────────────────────────────────────────────────────────────────────

class _TempOrderItem {
  final int productId;
  final String productName;
  final int subItemId;
  final String unit;
  final double price;
  final int quantity;

  const _TempOrderItem({
    required this.productId,
    required this.productName,
    required this.subItemId,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}