import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFFE8720C);
const _kPrimaryLight  = Color(0xFFFFF3E8);
const _kSurface       = Color(0xFFFFFFFF);
const _kBackground    = Color(0xFFF5F5F5);
const _kTextPrimary   = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider       = Color(0xFFEEEEEE);
const _kGreen         = Color(0xFF16A34A);
const _kGreenLight    = Color(0xFFDCFCE7);
const _kRed           = Color(0xFFDC2626);
const _kRedLight      = Color(0xFFFEE2E2);

class AddProductPage extends ConsumerStatefulWidget {
  final int adminId;
  final Product? initialProduct;

  const AddProductPage(
      {super.key, required this.adminId, this.initialProduct});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  String productName = '';
  String? productType;
  String? measuringUnit;

  late TextEditingController _nameCtrl;
  final TextEditingController _unitCtrl  = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();

  List<ProductSubType> addedItems = [];
  final List<int> _pendingDeleteSubItemIds = [];
  bool _hasInitializedData = false;

  final List<String> _productTypes = [
    'Beverage', 'Grocery', 'Ice Cream',
    'Bakery & Snacks', 'Dairy', 'Personal & Home Care', 'Others',
  ];
  final List<String> _units = ['Liter', 'ml', 'Box','Piece','Kilogram', 'gm'];

  bool get _isEdit => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    if (_isEdit) _initFromProduct(widget.initialProduct!);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _initFromProduct(Product p) {
    if (_hasInitializedData) return;
    _hasInitializedData = true;
    productName = p.productName ?? '';
    _nameCtrl.text = productName;
    productType = p.productType;
    measuringUnit = p.subtypes?[0].measuringUnit;
    addedItems = _normalizeSubtypes(p.subtypes);
  }

  List<ProductSubType> _normalizeSubtypes(List? raw) {
    if (raw == null) return [];
    return raw.map((item) { 
      if (item is ProductSubType) return item;
      if (item is Map) {
        return ProductSubType.fromJson(Map<String, dynamic>.from(item));
      }
      return null;
    }).whereType<ProductSubType>().toList();
  }

  void _snack(String msg,
      {Color color = _kPrimary, IconData icon = Icons.info_outline_rounded}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  void _addItem() {
    if (productName.trim().isEmpty) {
      _snack('Enter product name first',
          color: _kPrimary, icon: Icons.warning_amber_rounded);
      return;
    }
    if (measuringUnit == null) {
      _snack('Select measuring unit first',
          color: _kPrimary, icon: Icons.warning_amber_rounded);
      return;
    }
    if (_unitCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      _snack('Enter both unit value and price',
          color: _kPrimary, icon: Icons.warning_amber_rounded);
      return;
    }
    setState(() {
      addedItems.add(ProductSubType(
        localId: const Uuid().v4(),
        subItemId: null,
        measuringUnit: measuringUnit!,
        availableUnit: double.tryParse(_unitCtrl.text) ?? 0,
        price: double.tryParse(_priceCtrl.text),
      ));
      _unitCtrl.clear();
      _priceCtrl.clear();
    });
  }

  Future<bool> _ensureOnline() async {
    final ok =
        await ref.read(networkServiceProvider).checkConnection();
    if (!ok) ref.invalidate(networkStatusProvider);
    return ok;
  }

  Future<void> _submit() async {
    if (!await _ensureOnline()) {
      _snack('No internet connection',
          color: Colors.grey.shade800, icon: Icons.wifi_off_rounded);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (addedItems.isEmpty) {
      if (_isEdit) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            title: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: _kRedLight, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.warning_amber_rounded,
                          color: _kRed, size: 26),
                ),
                const SizedBox(height: 14),
                const Text('No Units Added',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
              ],
            ),
            content: const Text(
              'There are no unit and price entries for this product. '
              'Updating now may remove the product. Are you sure you want to continue?',
              style: TextStyle(
                  fontSize: 14, color: _kTextSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: _kTextSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      } else {
        _snack('Add at least one unit and price',
            color: _kPrimary, icon: Icons.info_outline_rounded);
        return;
      }
    }
    _formKey.currentState!.save();

    final product = Product(
      productId: widget.initialProduct?.productId,
      productName: productName,
      productType: productType!,
      createdBy: ref.read(adminloginViewModelProvider).userId,
      subtypes: addedItems,
      companyId:
          ref.read(adminloginViewModelProvider).companyId ?? '',
    );

    final productVM = ref.read(productViewModelProvider.notifier);

    try {
      await productVM.addOrUpdateProduct(product);

      if (_isEdit && _pendingDeleteSubItemIds.isNotEmpty) {
        try {
          await productVM
              .deleteProductSubType(_pendingDeleteSubItemIds);
        } catch (e) {
          _snack('Updated, but failed to delete items: $e',
              color: _kRed, icon: Icons.error_outline_rounded);
        }
      }

      productVM.fetchProductList(
        ref.read(adminloginViewModelProvider).companyId ?? '',
      );
      _snack(
        _isEdit
            ? 'Product updated successfully'
            : 'Product added successfully',
        color: _kGreen,
        icon: Icons.check_circle_outline_rounded,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack('Failed to save product: $e',
          color: _kRed, icon: Icons.error_outline_rounded);
    }
  }

  // ── Input decoration helper ───────────────────────────────────────────────
  InputDecoration _inputDec({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          fontSize: 14, color: _kTextSecondary, fontWeight: FontWeight.w400),
      prefixIcon: Icon(icon, size: 20, color: _kTextSecondary),
      filled: true,
      fillColor: _kBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDivider)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDivider)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kRed)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kRed, width: 1.5)),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kDivider),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product info card ────────────────────────────────────
              _SectionCard(
                title: 'Product Information',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    // Product name
                    _FieldLabel(
                        label: 'Product Name',
                        icon: Icons.shopping_bag_outlined),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(
                          fontSize: 14, color: _kTextPrimary),
                      decoration: _inputDec(
                          hint: 'Enter product name',
                          icon: Icons.shopping_bag_outlined),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter product name'
                          : null,
                      onSaved: (v) => productName = v!,
                      onChanged: (v) => productName = v,
                    ),
                    const SizedBox(height: 16),

                    // Product type
                    const _FieldLabel(
                        label: 'Product Type',
                        icon: Icons.category_outlined),
                    const SizedBox(height: 6),
                    DropdownButtonFormField2<String>(
                      decoration: _inputDec(
                          hint: 'Select type',
                          icon: Icons.category_outlined),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _kSurface),
                        elevation: 4,
                      ),
                      items: _productTypes
                          .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t,
                                  style: const TextStyle(fontSize: 14))))
                          .toList(),
                      value: productType,
                      onChanged: (v) =>
                          setState(() => productType = v),
                      validator: (v) =>
                          (v == null || v.isEmpty)
                              ? 'Select product type'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Measuring unit
                    const _FieldLabel(
                        label: 'Measuring Unit',
                        icon: Icons.straighten_outlined),
                    const SizedBox(height: 6),
                    DropdownButtonFormField2<String>(
                      decoration: _inputDec(
                          hint: 'Select unit',
                          icon: Icons.straighten_outlined),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _kSurface),
                        elevation: 4,
                      ),
                      items: _units
                          .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u,
                                  style: const TextStyle(fontSize: 14))))
                          .toList(),
                      value: measuringUnit,
                      onChanged: (v) =>
                          setState(() => measuringUnit = v),
                      validator: (v) =>
                          (v == null || v.isEmpty)
                              ? 'Select measuring unit'
                              : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Add unit & price card ────────────────────────────────
              _SectionCard(
                title: 'Add Unit & Price',
                icon: Icons.add_shopping_cart_outlined,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Unit value
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                  label: 'Unit Value',
                                  icon: Icons.scale_outlined),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _unitCtrl,
                                keyboardType:
                                    TextInputType.number,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: _kTextPrimary),
                                decoration: _inputDec(
                                    hint: 'e.g. 0.5',
                                    icon: Icons.scale_outlined),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                  label: 'Price (₹)',
                                  icon: Icons
                                      .currency_rupee_rounded),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _priceCtrl,
                                keyboardType:
                                    TextInputType.number,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: _kTextPrimary),
                                decoration: _inputDec(
                                    hint: 'e.g. 120',
                                    icon: Icons
                                        .currency_rupee_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          'Add to List',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kPrimary,
                          side: const BorderSide(color: _kPrimary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(46),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Added items list ─────────────────────────────────────
              if (addedItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Added Items (${addedItems.length})',
                  icon: Icons.playlist_add_check_rounded,
                  iconColor: _kGreen,
                  child: Column(
                    children: addedItems.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      final isLast = i == addedItems.length - 1;
                      return Column(
                        children: [
                          _AddedItemRow(
                            productName: productName,
                            item: item,
                            onDelete: () =>
                                _deleteItem(i, item),
                          ),
                          if (!isLast)
                            const Divider(
                                height: 1, color: _kDivider),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Submit button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20),
                  label: Text(
                    _isEdit
                        ? 'Update Product'
                        : 'Submit Product',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteItem(int index, ProductSubType item) async {
    final subItemId = item.subItemId;

    if (subItemId == null) {
      setState(() => addedItems.removeAt(index));
      return;
    }

    setState(() {
      if (!_pendingDeleteSubItemIds.contains(subItemId)) {
        _pendingDeleteSubItemIds.add(subItemId);
      }
      addedItems.removeAt(index);
    });
    _snack('Item removed (will delete on update)',
        color: _kGreen,
        icon: Icons.check_circle_outline_rounded);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared sub-widgets
// ══════════════════════════════════════════════════════════════════════════════

/// White card with section header
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor = _kPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary)),
              ],
            ),
          ),
          const Divider(height: 1, color: _kDivider),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Small label above a field
class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FieldLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _kTextSecondary),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary)),
      ],
    );
  }
}

/// Row for a single added item
class _AddedItemRow extends StatelessWidget {
  final String productName;
  final ProductSubType item;
  final VoidCallback onDelete;

  const _AddedItemRow({
    required this.productName,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_outlined,
                size: 18, color: _kPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$productName (${item.measuringUnit})',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kTextPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
  _formatUnit(item.availableUnit, item.measuringUnit),

                      style: const TextStyle(
                          fontSize: 11, color: _kTextSecondary),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kGreenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${item.price}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kGreen),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _kRedLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 17, color: _kRed),
            ),
          ),
        ],
      ),
    );
  }
  String _formatUnit(double? value, String? unit) {
  if (value == null || unit == null) return '';

  final u = unit.toLowerCase();

  String clean(double v) {
    // Remove .0 if whole number
    return v % 1 == 0 ? v.toInt().toString() : v.toString();
  }

  if (u == 'liter' || u == 'litre' || u == 'l') {
    return value < 1
        ? '${(value * 1000).toInt()} ml'
        : '${clean(value)} L';
  }

  if (u == 'kilogram' || u == 'kg') {
    return value < 1
        ? '${(value * 1000).toInt()} g'
        : '${clean(value)} kg';
  }

  return '${clean(value)} $unit';
}


}
